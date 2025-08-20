// Copyright (c) 2025 Clipora.
//
// This program is free software: you can redistribute it and/or modify
// it under the terms of the GNU Affero General Public License as published
// by the Free Software Foundation, either version 3 of the License, or
// (at your option) any later version.
//
// This program is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
// GNU Affero General Public License for more details.
//
// You should have received a copy of the GNU Affero General Public License
// along with this program. If not, see <https://www.gnu.org/licenses/>.

import 'package:flutter/material.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';
import 'dart:convert';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'package:web_socket_channel/io.dart';
import 'dart:typed_data';
import 'package:archive/archive.dart';
import 'package:path/path.dart' as p;

import '../../basics/ui.dart';
import '../../db/article/service/article_service.dart';

// 文件接收信息类
class _FileReceiveInfo {
  final String fileId;
  final String fileName;
  final int fileSize;
  final int totalChunks;
  final int chunkSize;
  final String from;
  final Map<int, bool> receivedChunks;
  final List<List<int>?> chunks;

  _FileReceiveInfo({
    required this.fileId,
    required this.fileName,
    required this.fileSize,
    required this.totalChunks,
    required this.chunkSize,
    required this.from,
    required this.receivedChunks,
    required this.chunks,
  });
}

// 新的二进制文件接收状态
class _BinaryReceiveState {
  final String uuid;
  final String fileName;
  final int size;
  final int totalChunks;
  int receivedChunks;
  final List<Uint8List> chunks;

  _BinaryReceiveState({
    required this.uuid,
    required this.fileName,
    required this.size,
    required this.totalChunks,
    this.receivedChunks = 0,
    List<Uint8List>? chunks,
  }) : chunks = chunks ?? <Uint8List>[];
}
class DataSyncPage extends StatefulWidget {
  const DataSyncPage({super.key});

  @override
  State<DataSyncPage> createState() => _DataSyncPageState();
}

class _DataSyncPageState extends State<DataSyncPage> {
  RTCPeerConnection? _peerConnection;
  RTCDataChannel? _dataChannel;
  WebSocketChannel? _signalingChannel;
  bool _isConnected = false;
  bool _isSignalingConnected = false;
  String _connectionStatus = '未连接';
  String _signalingStatus = '未连接';
  String _localUserId = '';
  String _roomId = '';
  String _targetUserId = '';
  final List<String> _syncLog = [];
  final List<String> _roomUsers = [];
  final TextEditingController _roomIdController = TextEditingController();
  final TextEditingController _targetUserController = TextEditingController();
  
  // 文件分块接收相关变量（旧：base64 JSON 协议）
  final Map<String, _FileReceiveInfo> _receivingFiles = {};

  // 新：二进制传输协议接收状态
  final Map<String, _BinaryReceiveState> _binaryReceiving = {};
  String? _currentBinaryUuid;
  
  // 信令服务器配置
  static const String _signalingServerUrl = 'wss://gzservice.clipora.cc/webrtc/ws';
  
  // STUN/TURN 服务器配置
  static const Map<String, dynamic> _rtcConfiguration = {
    'iceServers': [
      {
        'urls': 'stun:coturn.clipora.cc:23388',
      },
      {
        'urls': 'turn:coturn.clipora.cc:23388',
        'username': 'coturn',
        'credential': 'coturn',
      },
    ],
    'iceCandidatePoolSize': 10,
  };

  @override
  void initState() {
    super.initState();
    _initializeWebRTC();
  }

  @override
  void dispose() {
    _dataChannel?.close();
    _peerConnection?.close();
    _signalingChannel?.sink.close();
    _roomIdController.dispose();
    _targetUserController.dispose();
    super.dispose();
  }

  Future<void> _initializeWebRTC() async {
    // 生成本地用户ID
    _localUserId = globalBoxStorage.read('token'); //'user_${DateTime.now().millisecondsSinceEpoch}';
    _roomId = globalBoxStorage.read('user_id'); //'sync_room_${Random().nextInt(10000)}';
    _roomIdController.text = _roomId;

    _addLog('🔧 初始化WebRTC...');
    _addLog('👤 本地用户ID: $_localUserId');
    _addLog('🏠 默认房间ID: $_roomId');
    _addLog('🌐 信令服务器地址: $_signalingServerUrl');
    
    _connectToSignalingServer();
    setState(() {});
  }

  Future<void> _connectToSignalingServer() async {
    try {
      final uri = '$_signalingServerUrl/$_localUserId';
      _signalingChannel = IOWebSocketChannel.connect(uri);
      
      // 添加连接状态标志
      bool connectionEstablished = false;
      
      _signalingChannel!.stream.listen(
        (message) {
          // 如果这是第一次收到消息，说明连接已建立
          if (!connectionEstablished) {
            connectionEstablished = true;
            setState(() {
              _signalingStatus = '已连接';
              _isSignalingConnected = true;
            });
            _addLog('已连接到信令服务器');
            
            // 连接建立后自动加入房间
            _joinRoom();
          }
          
          _handleSignalingMessage(json.decode(message));
        },

        onError: (error) {
          _addLog('信令服务器错误: $error');
          setState(() {
            _signalingStatus = '连接错误';
            _isSignalingConnected = false;
          });
        },
        onDone: () {
          _addLog('信令服务器连接断开');
          setState(() {
            _signalingStatus = '连接断开';
            _isSignalingConnected = false;
          });
        },
      );

      // 发送一个ping消息来触发连接确认
      await Future.delayed(const Duration(milliseconds: 100));
      final pingMessage = {
        'type': 'ping',
        'user_id': _localUserId,
      };
      _signalingChannel!.sink.add(json.encode(pingMessage));
      _addLog('正在连接信令服务器...');
      
    } catch (e) {
      _addLog('连接信令服务器失败: $e');
      setState(() {
        _signalingStatus = '连接失败';
        _isSignalingConnected = false;
      });
    }
  }

  Future<void> _joinRoom() async {
    if (!_isSignalingConnected) {
      _addLog('❌ 信令服务器未连接，无法加入房间');
      return;
    }
    
    if (_roomIdController.text.isEmpty) {
      _addLog('❌ 房间ID为空，无法加入房间');
      return;
    }

    _roomId = _roomIdController.text;
    
    final message = {
      'type': 'join-room',
      'room_id': _roomId,
      'user_id': _localUserId,
    };
    
    try {
      _signalingChannel!.sink.add(json.encode(message));
      _addLog('🚀 正在加入房间: $_roomId');
      _addLog('📤 发送加入房间消息: ${json.encode(message)}');
    } catch (e) {
      _addLog('❌ 发送加入房间消息失败: $e');
    }
  }

  Future<void> _leaveRoom() async {
    if (!_isSignalingConnected) return;

    final message = {
      'type': 'leave-room',
      'room_id': _roomId,
      'user_id': _localUserId,
    };
    
    _signalingChannel!.sink.add(json.encode(message));
    _addLog('离开房间: $_roomId');
    
    setState(() {
      _roomUsers.clear();
    });
  }

  Future<void> _initializePeerConnection() async {
    try {
      if (_peerConnection != null) {
        await _peerConnection!.close();
        _addLog('关闭旧的PeerConnection');
      }

      _addLog('创建PeerConnection，配置: ${_rtcConfiguration.toString()}');
      _peerConnection = await createPeerConnection(_rtcConfiguration);
      _addLog('PeerConnection创建成功');
      
      _peerConnection!.onIceCandidate = (RTCIceCandidate candidate) {
        _addLog('生成ICE候选者: ${candidate.candidate?.substring(0, 50)}...');
        _sendIceCandidate(candidate);
      };

      _peerConnection!.onConnectionState = (RTCPeerConnectionState state) {
        setState(() {
          _connectionStatus = _getConnectionStatusText(state);
          _isConnected = state == RTCPeerConnectionState.RTCPeerConnectionStateConnected;
        });
        _addLog('WebRTC连接状态变化: $_connectionStatus');
        
        // 添加失败状态的详细信息
        if (state == RTCPeerConnectionState.RTCPeerConnectionStateFailed) {
          _addLog('⚠️ WebRTC连接失败，可能原因:');
          _addLog('1. STUN/TURN服务器不可达');
          _addLog('2. 网络防火墙阻止连接');
          _addLog('3. ICE候选者收集失败');
          _addLog('4. 信令交换不完整');
        }
      };

      _peerConnection!.onIceConnectionState = (RTCIceConnectionState state) {
        _addLog('ICE连接状态: ${state.toString()}');
      };

      _peerConnection!.onIceGatheringState = (RTCIceGatheringState state) {
        _addLog('ICE收集状态: ${state.toString()}');
      };

      _peerConnection!.onDataChannel = (RTCDataChannel channel) {
        _addLog('收到数据通道: ${channel.label}');
        _setupDataChannel(channel);
      };
      
    } catch (e) {
      _addLog('❌ 创建PeerConnection失败: $e');
    }
  }

  void _handleSignalingMessage(Map<String, dynamic> message) {
    final type = message['type'];
    _addLog('收到信令消息: $type');
    
    switch (type) {
      case 'ping':
      case 'pong':
        // 处理ping/pong消息，用于连接确认
        _addLog('收到服务器响应，连接已建立');
        break;
        
      case 'user-joined':
        final userId = message['user_id'];
        if (userId != _localUserId && !_roomUsers.contains(userId)) {
          setState(() {
            _roomUsers.add(userId);
          });
          _addLog('用户加入: $userId');
        }
        break;
        
      case 'user-left':
        final userId = message['user_id'];
        setState(() {
          _roomUsers.remove(userId);
        });
        _addLog('用户离开: $userId');
        break;
        
      case 'room-users':
        final users = List<String>.from(message['users'] ?? []);
        setState(() {
          _roomUsers.clear();
          _roomUsers.addAll(users.where((u) => u != _localUserId));
        });
        _addLog('房间用户列表: ${_roomUsers.join(', ')}');
        break;
        
      case 'join-room-success':
        _addLog('✅ 成功加入房间: ${message['room_id']}');
        break;
        
      case 'join-room-error':
        _addLog('❌ 加入房间失败: ${message['error']}');
        break;
        
      case 'offer':
        _handleOffer(message);
        break;
        
      case 'answer':
        _handleAnswer(message);
        break;
        
      case 'ice-candidate':
        _handleIceCandidate(message);
        break;
        
      default:
        _addLog('未知信令消息类型: $type');
    }
  }

  Future<void> _handleOffer(Map<String, dynamic> message) async {
    try {
      _addLog('收到Offer来自: ${message['user_id']}');
      await _initializePeerConnection();
      
      final offer = RTCSessionDescription(
        message['data']['sdp'],
        message['data']['type'],
      );
      
      _addLog('设置远程描述(Offer)');
      await _peerConnection!.setRemoteDescription(offer);
      
      _addLog('创建Answer');
      final answer = await _peerConnection!.createAnswer();
      
      _addLog('设置本地描述(Answer)');
      await _peerConnection!.setLocalDescription(answer);
      
      _sendAnswer(message['user_id'], answer);
      _addLog('发送Answer给: ${message['user_id']}');
    } catch (e) {
      _addLog('❌ 处理Offer失败: $e');
    }
  }

  Future<void> _handleAnswer(Map<String, dynamic> message) async {
    try {
      _addLog('收到Answer来自: ${message['user_id']}');
      final answer = RTCSessionDescription(
        message['data']['sdp'],
        message['data']['type'],
      );
      
      _addLog('设置远程描述(Answer)');
      await _peerConnection!.setRemoteDescription(answer);
      _addLog('Answer处理完成');
    } catch (e) {
      _addLog('❌ 处理Answer失败: $e');
    }
  }

  Future<void> _handleIceCandidate(Map<String, dynamic> message) async {
    try {
      final candidateData = message['data'];
      final candidate = RTCIceCandidate(
        candidateData['candidate'],
        candidateData['sdp_mid'],
        candidateData['sdp_m_line_index'],
      );
      
      await _peerConnection!.addCandidate(candidate);
      _addLog('添加ICE候选者来自: ${message['user_id']}');
      _addLog('候选者类型: ${candidateData['candidate']?.split(' ')[7] ?? 'unknown'}');
    } catch (e) {
      _addLog('❌ 添加ICE候选者失败: $e');
    }
  }

  void _sendOffer(String targetUserId) async {
    try {
      _addLog('开始建立连接到: $targetUserId');
      
      if (_peerConnection == null) {
        await _initializePeerConnection();
      }

      _targetUserId = targetUserId;

      // 创建数据通道
      _addLog('创建数据通道');
      final dataChannelInit = RTCDataChannelInit();
      _dataChannel = await _peerConnection!.createDataChannel('fileSync', dataChannelInit);
      _setupDataChannel(_dataChannel!);

      _addLog('创建Offer');
      final offer = await _peerConnection!.createOffer();
      
      _addLog('设置本地描述(Offer)');
      await _peerConnection!.setLocalDescription(offer);
      
      final message = {
        'type': 'offer',
        'room_id': _roomId,
        'user_id': _localUserId,
        'target_user_id': targetUserId,
        'data': {
          'type': offer.type,
          'sdp': offer.sdp,
        },
      };
      
      _signalingChannel!.sink.add(json.encode(message));
      _addLog('发送Offer给: $targetUserId');
      _addLog('等待对方响应...');
    } catch (e) {
      _addLog('❌ 发送Offer失败: $e');
    }
  }

  void _sendAnswer(String targetUserId, RTCSessionDescription answer) {
    _targetUserId = targetUserId;
    
    final message = {
      'type': 'answer',
      'room_id': _roomId,
      'user_id': _localUserId,
      'target_user_id': targetUserId,
      'data': {
        'type': answer.type,
        'sdp': answer.sdp,
      },
    };
    
    _signalingChannel!.sink.add(json.encode(message));
  }

  void _sendIceCandidate(RTCIceCandidate candidate) {
    if (_targetUserId.isEmpty) return;
    
    final message = {
      'type': 'ice-candidate',
      'room_id': _roomId,
      'user_id': _localUserId,
      'target_user_id': _targetUserId,
      'data': {
        'candidate': candidate.candidate,
        'sdp_mid': candidate.sdpMid,
        'sdp_m_line_index': candidate.sdpMLineIndex,
      },
    };
    
    _signalingChannel!.sink.add(json.encode(message));
  }

  void _setupDataChannel(RTCDataChannel channel) {
    _dataChannel = channel;
    
    _dataChannel!.onMessage = (RTCDataChannelMessage message) {
      _handleReceivedMessage(message);
    };

    _dataChannel!.onDataChannelState = (RTCDataChannelState state) {
      _addLog('数据通道状态: ${state.toString()}');
    };
  }

  void _handleReceivedMessage(RTCDataChannelMessage message) {
    try {
      // 兼容二进制与JSON文本两种数据
      if (message.isBinary) {
        // 二进制数据块
        _handleBinaryData(message.binary);
        return;
      }

      final data = json.decode(message.text);
      final type = data['type'];
      
      switch (type) {
        case 'file':
          _handleFileReceive(data);
          break;
        case 'file-header':
          _handleFileHeader(data);
          break;
        case 'file-chunk':
          _handleFileChunk(data);
          break;
        case 'file-binary-header':
          _handleFileBinaryHeader(data);
          break;
        case 'transfer-complete':
          _addLog('📨 收到传输完成指示: ${data['uuid'] ?? ''}');
          // 实际合并触发在 _handleBinaryData 内部（收到足够的块时）
          break;
        case 'transfer-ack':
          _addLog('📮 收到传输确认: ${data['uuid']} 成功: ${data['success']}');
          break;
        case 'sync-inventory-request':
          // 基于 uuid 的库存检查请求
          _handleSyncInventoryRequest(data);
          break;
        case 'sync-inventory-response':
          // 基于 uuid 的库存检查响应
          _handleSyncInventoryResponse(data);
          break;
        case 'text':
          _addLog('收到文本: ${data['content']}');
          break;
        default:
          _addLog('收到未知消息类型: $type');
      }
    } catch (e) {
      _addLog('处理消息错误: $e');
    }
  }

  // 发送库存请求：携带本地已具备文件的文章 uuid 列表
  Future<void> _sendSyncInventoryRequest() async {
    if (_dataChannel?.state != RTCDataChannelState.RTCDataChannelOpen) {
      _addLog('数据通道未打开，无法发送库存请求');
      return;
    }
    try {
      final articles = await ArticleService.instance.getArticlesWithLocalMhtml();
      final uuids = articles
          .where((a) => a.uuid.isNotEmpty)
          .map((a) => a.uuid)
          .toSet()
          .toList();

      final message = {
        'type': 'sync-inventory-request',
        'uuids': uuids,
        'from': _localUserId,
      };
      _dataChannel!.send(RTCDataChannelMessage(json.encode(message)));
      _addLog('📦 已发送库存请求，共 ${uuids.length} 个 uuid');
    } catch (e) {
      _addLog('❌ 发送库存请求失败: $e');
    }
  }

  // 处理对端的库存请求：根据 uuid 判断本地是否具备对应文件（localMhtmlPath 目录存在）
  Future<void> _handleSyncInventoryRequest(Map<String, dynamic> data) async {
    try {
      final List<dynamic> req = (data['uuids'] ?? []) as List<dynamic>;
      final List<String> requestUUIDs = req.map((e) => e.toString()).toList();
      _addLog('📥 收到库存请求，待检查 ${requestUUIDs.length} 个 uuid');

      // 查询本地存在的文章
      final existingArticles = await ArticleService.instance.getByUUIDs(requestUUIDs);
      final Set<String> haveValidFiles = {};
      for (final a in existingArticles) {
        final p = a.localMhtmlPath;
        if (p.isNotEmpty) {
          final dir = Directory(p);
          final exists = await dir.exists();
          if (exists) {
            haveValidFiles.add(a.uuid);
          }
        }
      }

      // 缺失的 uuid = 请求中 - 本地已具备
      final missingUUIDs = requestUUIDs.where((u) => !haveValidFiles.contains(u)).toList();

      final resp = {
        'type': 'sync-inventory-response',
        'missingUUIDs': missingUUIDs,
        'from': _localUserId,
      };
      _dataChannel?.send(RTCDataChannelMessage(json.encode(resp)));
      _addLog('📤 已返回库存响应：缺失 ${missingUUIDs.length}/${requestUUIDs.length}');
    } catch (e) {
      _addLog('❌ 处理库存请求失败: $e');
    }
  }

  void _handleSyncInventoryResponse(Map<String, dynamic> data) {
    try {
      final List<dynamic> miss = (data['missingUUIDs'] ?? []) as List<dynamic>;
      final List<String> missingUUIDs = miss.map((e) => e.toString()).toList();
      if (missingUUIDs.isEmpty) {
        _addLog('✅ 对端不缺文件，已同步');
      } else {
        _addLog('❗ 对端缺失 ${missingUUIDs.length} 个文件，后续仅对这些 uuid 发送');
      }
      // 可在此处缓存 missingUUIDs 以驱动后续文件发送管线
    } catch (e) {
      _addLog('❌ 处理库存响应失败: $e');
    }
  }

  Future<void> _sendFile() async {
    if (_dataChannel?.state != RTCDataChannelState.RTCDataChannelOpen) {
      _addLog('数据通道未打开');
      return;
    }

    try {
      // 先发起库存检查，依据 uuid 判断是否需要同步文件
      await _sendSyncInventoryRequest();
      _addLog('已发起基于 uuid 的库存同步流程');
    } catch (e) {
      _addLog('发送文件错误: $e');
    }
  }

  Future<void> _handleFileReceive(Map<String, dynamic> data) async {
    try {
      final fileName = data['fileName'];
      final fileData = data['data'];
      final bytes = base64Decode(fileData);
      
      final directory = await getApplicationDocumentsDirectory();
      final file = File('${directory.path}/$fileName');
      await file.writeAsBytes(bytes);
      
      _addLog('文件已保存: $fileName (${bytes.length} 字节)');
    } catch (e) {
      _addLog('保存文件错误: $e');
    }
  }

  // 新协议：处理二进制文件头
  void _handleFileBinaryHeader(Map<String, dynamic> data) {
    try {
      final String uuid = data['uuid']?.toString() ?? '';
      final String fileName = data['fileName']?.toString() ?? 'article_$uuid.zip';
      final int size = (data['size'] ?? 0) as int;
      final int totalChunks = (data['totalChunks'] ?? 0) as int;

      if (uuid.isEmpty || totalChunks <= 0) {
        _addLog('❌ 无效的文件头: uuid 或 totalChunks 缺失');
        return;
      }

      _binaryReceiving[uuid] = _BinaryReceiveState(
        uuid: uuid,
        fileName: fileName,
        size: size,
        totalChunks: totalChunks,
      );
      _currentBinaryUuid = uuid;

      _addLog('📥 开始接收(二进制): $fileName (${size} 字节, $totalChunks 块)');
      setState(() {});
    } catch (e) {
      _addLog('❌ 处理二进制文件头错误: $e');
    }
  }

  // 新协议：接收二进制数据块
  void _handleBinaryData(Uint8List binary) {
    try {
      if (_currentBinaryUuid == null || !_binaryReceiving.containsKey(_currentBinaryUuid)) {
        _addLog('⚠️ 收到意外的二进制数据，未找到正在接收的文件');
        return;
      }

      final state = _binaryReceiving[_currentBinaryUuid!]!;
      state.chunks.add(binary);
      state.receivedChunks += 1;

      final progress = (state.receivedChunks / state.totalChunks * 100).clamp(0, 100).toStringAsFixed(1);
      _addLog('📦 接收二进制块: ${state.fileName} $progress% (${state.receivedChunks}/${state.totalChunks})');

      if (state.receivedChunks >= state.totalChunks) {
        _finalizeBinaryFile(state);
      }
    } catch (e) {
      _addLog('❌ 处理二进制数据块错误: $e');
    }
  }

  // 新协议：合并二进制并解压、写库
  Future<void> _finalizeBinaryFile(_BinaryReceiveState state) async {
    try {
      _addLog('🔗 开始合并二进制数据: ${state.fileName}');

      // 合并字节
      int totalSize = 0;
      for (final chunk in state.chunks) {
        totalSize += chunk.length;
      }
      final Uint8List merged = Uint8List(totalSize);
      int offset = 0;
      for (final chunk in state.chunks) {
        merged.setRange(offset, offset + chunk.length, chunk);
        offset += chunk.length;
      }

      _addLog('🔗 合并完成，大小: $totalSize 字节，开始解压...');

      // 解压 zip
      final Archive archive = ZipDecoder().decodeBytes(merged);

      // 选择存储目录（优先应用支持目录，不存在则回退文档目录）
      Directory appDir;
      try {
        appDir = await getApplicationSupportDirectory();
      } catch (_) {
        appDir = await getApplicationDocumentsDirectory();
      }
      final String baseDir = p.join(appDir.path, 'article_files');
      final Directory baseDirectory = Directory(baseDir);
      if (!await baseDirectory.exists()) {
        await baseDirectory.create(recursive: true);
      }

      final String timestamp = DateTime.now().millisecondsSinceEpoch.toString();
      final String extractDir = p.join(baseDir, 'article_${state.uuid}_extracted_$timestamp');
      final Directory extractDirectory = Directory(extractDir);
      await extractDirectory.create(recursive: true);

      // 解压所有文件
      for (final ArchiveFile file in archive) {
        // 判断目录/文件
        final bool isDirectory = file.isFile == false || file.name.endsWith('/') || (file.content.isEmpty && !file.name.contains('.'));
        if (isDirectory) {
          String dirName = file.name;
          if (!dirName.endsWith('/')) {
            dirName += '/';
          }
          final String dirPath = p.join(extractDir, dirName);
          final Directory dir = Directory(dirPath);
          if (!await dir.exists()) {
            await dir.create(recursive: true);
          }
        } else {
          final String filePath = p.join(extractDir, file.name);
          final Directory parentDir = Directory(p.dirname(filePath));
          if (!await parentDir.exists()) {
            await parentDir.create(recursive: true);
          }
          final File outputFile = File(filePath);
          await outputFile.writeAsBytes(file.content as List<int>);
        }
      }

      _addLog('✅ 文件解压成功: $extractDir');

      // 写库：根据 uuid 更新对应文章的本地路径
      await ArticleService.instance.dbService.isar.writeTxn(() async {
        final articles = await ArticleService.instance.getByUUIDs([state.uuid]);
        if (articles.isNotEmpty) {
          final article = articles.first;
          article.localMhtmlPath = extractDir;
          await ArticleService.instance.updateLocalMhtmlPath(article);
          _addLog('🗂️ 已更新文章本地路径: ${article.title}');
        } else {
          _addLog('⚠️ 未找到对应UUID的文章: ${state.uuid}');
        }
      });

      // 发送ACK
      final ack = {
        'type': 'transfer-ack',
        'uuid': state.uuid,
        'success': true,
        'message': '文件接收并解压成功',
      };
      _dataChannel?.send(RTCDataChannelMessage(json.encode(ack)));

      _addLog('📮 已发送成功确认: ${state.uuid}');
    } catch (e) {
      _addLog('❌ 处理二进制文件失败: $e');
      // 发送失败ACK
      final ack = {
        'type': 'transfer-ack',
        'uuid': state.uuid,
        'success': false,
        'message': e.toString(),
      };
      _dataChannel?.send(RTCDataChannelMessage(json.encode(ack)));
    } finally {
      // 清理状态
      if (_currentBinaryUuid == state.uuid) {
        _currentBinaryUuid = null;
      }
      _binaryReceiving.remove(state.uuid);
      setState(() {});
    }
  }

  void _handleFileHeader(Map<String, dynamic> data) {
    try {
      final fileId = data['fileId'];
      final fileName = data['fileName'];
      final fileSize = data['fileSize'];
      final totalChunks = data['totalChunks'];
      final chunkSize = data['chunkSize'];
      final from = data['from'];
      
      _addLog('开始接收文件: $fileName (${fileSize} 字节, $totalChunks 块)');
      
      _receivingFiles[fileId] = _FileReceiveInfo(
        fileId: fileId,
        fileName: fileName,
        fileSize: fileSize,
        totalChunks: totalChunks,
        chunkSize: chunkSize,
        from: from,
        receivedChunks: {},
        chunks: List.filled(totalChunks, null),
      );
      
      setState(() {});
    } catch (e) {
      _addLog('处理文件头错误: $e');
    }
  }

  Future<void> _handleFileChunk(Map<String, dynamic> data) async {
    try {
      final fileId = data['fileId'];
      final chunkIndex = data['chunkIndex'];
      final totalChunks = data['totalChunks'];
      final chunkData = data['data'];
      final from = data['from'];
      
      if (!_receivingFiles.containsKey(fileId)) {
        _addLog('收到未知文件块: $fileId');
        return;
      }
      
      final fileInfo = _receivingFiles[fileId]!;
      
      // 解码并存储块数据
      final bytes = base64Decode(chunkData);
      fileInfo.chunks[chunkIndex] = bytes;
      fileInfo.receivedChunks[chunkIndex] = true;
      
      final progress = (fileInfo.receivedChunks.length / fileInfo.totalChunks * 100).round();
      _addLog('接收进度: ${fileInfo.fileName} $progress% (${fileInfo.receivedChunks.length}/${fileInfo.totalChunks})');
      
      // 检查是否接收完所有块
      if (fileInfo.receivedChunks.length == fileInfo.totalChunks) {
        await _assembleAndSaveFile(fileInfo);
        _receivingFiles.remove(fileId);
      }
      
      setState(() {});
    } catch (e) {
      _addLog('处理文件块错误: $e');
    }
  }

  Future<void> _assembleAndSaveFile(_FileReceiveInfo fileInfo) async {
    try {
      _addLog('开始组装文件: ${fileInfo.fileName}');
      
      // 组装所有块
      final allBytes = <int>[];
      for (int i = 0; i < fileInfo.totalChunks; i++) {
        if (fileInfo.chunks[i] != null) {
          allBytes.addAll(fileInfo.chunks[i]!);
        } else {
          throw Exception('缺少文件块 $i');
        }
      }
      
      // 保存文件
      final directory = await getApplicationDocumentsDirectory();
      final file = File('${directory.path}/${fileInfo.fileName}');
      await file.writeAsBytes(allBytes);
      
      _addLog('✅ 文件接收完成: ${fileInfo.fileName} (${allBytes.length} 字节)');
      _addLog('📁 保存路径: ${file.path}');
    } catch (e) {
      _addLog('❌ 组装文件错误: $e');
    }
  }

  Future<void> _sendTestMessage() async {
    if (_dataChannel?.state == RTCDataChannelState.RTCDataChannelOpen) {
      final message = {
        'type': 'text',
        'content': '测试消息 - ${DateTime.now()}',
        'from': _localUserId,
      };
      
      _dataChannel!.send(RTCDataChannelMessage(json.encode(message)));
      _addLog('发送测试消息');
    } else {
      _addLog('数据通道未打开');
    }
  }



  String _getConnectionStatusText(RTCPeerConnectionState state) {
    switch (state) {
      case RTCPeerConnectionState.RTCPeerConnectionStateNew:
        return '新建';
      case RTCPeerConnectionState.RTCPeerConnectionStateConnecting:
        return '连接中';
      case RTCPeerConnectionState.RTCPeerConnectionStateConnected:
        return '已连接';
      case RTCPeerConnectionState.RTCPeerConnectionStateDisconnected:
        return '已断开';
      case RTCPeerConnectionState.RTCPeerConnectionStateFailed:
        return '连接失败';
      case RTCPeerConnectionState.RTCPeerConnectionStateClosed:
        return '已关闭';
      default:
        return '未知状态';
    }
  }

  void _addLog(String message) {
    setState(() {
      _syncLog.insert(0, '${DateTime.now().toString().substring(11, 19)}: $message');
      if (_syncLog.length > 100) {
        _syncLog.removeLast();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('数据同步'),
        backgroundColor: Theme.of(context).primaryColor,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Theme.of(context).primaryColor.withOpacity(0.1),
              Theme.of(context).colorScheme.surface,
            ],
          ),
        ),
        child: SingleChildScrollView(
          child: Column(
            children: [

              // 状态卡片
              _buildStatusCard(),

              // 控制面板
              _buildControlPanel(),

              // 日志区域
              Container(
                height: 400,
                child: _buildLogArea(),
              ),
            ],
          ),
        )
      ),
    );
  }

  Widget _buildStatusCard() {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                width: 12,
                height: 12,
                decoration: BoxDecoration(
                  color: _isSignalingConnected ? Colors.green : Colors.red,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 8),
              Text(
                '信令服务器: $_signalingStatus',
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(width: 8),
          Row(
            children: [
              Container(
                width: 12,
                height: 12,
                decoration: BoxDecoration(
                  color: _isConnected ? Colors.green : Colors.red,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 8),
              Text(
                'WebRTC连接: $_connectionStatus',
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: Text('用户ID: $_localUserId'),
              ),
            ],
          ),
          if (_roomUsers.isNotEmpty) ...[
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: Text('房间用户: ${_roomUsers.join(', ')}'),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildControlPanel() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Text(
            '信令服务器连接',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 12),
          
          // 连接信令服务器按钮
          ElevatedButton.icon(
            onPressed: _isSignalingConnected ? null : _connectToSignalingServer,
            icon: const Icon(Icons.cloud_outlined),
            label: Text(_isSignalingConnected ? '已连接信令服务器' : '连接信令服务器'),
            style: ElevatedButton.styleFrom(
              backgroundColor: _isSignalingConnected ? Colors.green : Theme.of(context).primaryColor,
              foregroundColor: Colors.white,
            ),
          ),
          
          const SizedBox(height: 16),
          
          const Text(
            '房间管理',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          
          // 房间ID输入
          TextField(
            controller: _roomIdController,
            decoration: const InputDecoration(
              labelText: '房间ID',
              hintText: '输入房间ID',
              border: OutlineInputBorder(),
            ),
          ),
          
          const SizedBox(height: 8),
          
          Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: _isSignalingConnected ? _joinRoom : null,
                  icon: const Icon(Icons.meeting_room),
                  label: const Text('加入房间'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    foregroundColor: Colors.white,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: _isSignalingConnected ? _leaveRoom : null,
                  icon: const Icon(Icons.exit_to_app),
                  label: const Text('离开房间'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.orange,
                    foregroundColor: Colors.white,
                  ),
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 8),
          
          // 调试按钮
          ElevatedButton.icon(
            onPressed: _isSignalingConnected ? () {
              _addLog('🔄 手动重新加入房间');
              _joinRoom();
            } : null,
            icon: const Icon(Icons.refresh),
            label: const Text('重新加入房间'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.purple,
              foregroundColor: Colors.white,
            ),
          ),
          
          const SizedBox(height: 16),
          
          // WebRTC连接
          const Text(
            'WebRTC连接',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          
          // 用户选择下拉框
          if (_roomUsers.isNotEmpty)
            DropdownButtonFormField<String>(
              decoration: const InputDecoration(
                labelText: '选择目标用户',
                border: OutlineInputBorder(),
              ),
              value: _targetUserId.isEmpty ? null : _targetUserId,
              items: _roomUsers.map((user) {
                return DropdownMenuItem<String>(
                  value: user,
                  child: Text(user),
                );
              }).toList(),
              onChanged: (value) {
                setState(() {
                  _targetUserId = value ?? '';
                });
              },
            ),
          
          const SizedBox(height: 8),
          
          ElevatedButton.icon(
            onPressed: (_roomUsers.isNotEmpty && _targetUserId.isNotEmpty) ? () => _sendOffer(_targetUserId) : null,
            icon: const Icon(Icons.connect_without_contact),
            label: const Text('建立WebRTC连接'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green,
              foregroundColor: Colors.white,
            ),
          ),
          
          const SizedBox(height: 16),
          
          // 网络诊断
          const Text(
            '网络诊断',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
          
          const SizedBox(height: 16),
          
          // 同步操作
          const Text(
            '同步操作',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          
          Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: _sendTestMessage,
                  icon: const Icon(Icons.message),
                  label: const Text('发送测试'),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: _sendFile,
                  icon: const Icon(Icons.file_upload),
                  label: const Text('发送文件'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildLogArea() {
    return Container(
      margin: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Theme.of(context).primaryColor.withOpacity(0.1),
              borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
            ),
            child: Row(
              children: [
                const Icon(Icons.history),
                const SizedBox(width: 8),
                const Text(
                  '同步日志',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const Spacer(),
                IconButton(
                  onPressed: () {
                    setState(() {
                      _syncLog.clear();
                    });
                  },
                  icon: const Icon(Icons.clear),
                  tooltip: '清空日志',
                ),
              ],
            ),
          ),
          Expanded(
            child: _syncLog.isEmpty
                ? const Center(
                    child: Text(
                      '暂无日志',
                      style: TextStyle(
                        color: Colors.grey,
                        fontSize: 14,
                      ),
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.all(8),
                    itemCount: _syncLog.length,
                    itemBuilder: (context, index) {
                      return Container(
                        padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
                        margin: const EdgeInsets.symmetric(vertical: 2),
                        decoration: BoxDecoration(
                          color: Theme.of(context).colorScheme.surface,
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          _syncLog[index],
                          style: const TextStyle(
                            fontSize: 12,
                            fontFamily: 'monospace',
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}