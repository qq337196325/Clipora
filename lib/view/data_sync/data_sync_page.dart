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
  bool _isSignalingConnected = false;
  String _connectionStatus = '未连接';
  String _localUserId = '';
  String _roomId = '';
  String _targetUserId = '';
  final List<String> _roomUsers = [];
  final TextEditingController _roomIdController = TextEditingController();
  final TextEditingController _targetUserController = TextEditingController();

  // 文件分块接收相关变量（旧：base64 JSON 协议）
  final Map<String, _FileReceiveInfo> _receivingFiles = {};

  // 新：二进制传输协议接收状态
  final Map<String, _BinaryReceiveState> _binaryReceiving = {};
  String? _currentBinaryUuid;

  // 发送侧：数据通道状态与同步状态
  bool _isDataChannelOpen = false;
  bool _isSyncInProgress = false;

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
    _localUserId = globalBoxStorage.read('token');
    _roomId = globalBoxStorage.read('user_id');
    _roomIdController.text = _roomId;

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
              _isSignalingConnected = true;
            });

            // 连接建立后自动加入房间
            _joinRoom();
          }

          _handleSignalingMessage(json.decode(message));
        },

        onError: (error) {
          setState(() {
            _isSignalingConnected = false;
          });
        },
        onDone: () {
          setState(() {
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
    } catch (e) {
      setState(() {
        _isSignalingConnected = false;
      });
    }
  }

  Future<void> _joinRoom() async {
    if (!_isSignalingConnected) {
      print('❌ 信令服务器未连接，无法加入房间');
      return;
    }

    if (_roomIdController.text.isEmpty) {
      print('❌ 房间ID为空，无法加入房间');
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
    } catch (e) {
      print('❌ 发送加入房间消息失败: $e');
    }
  }

  Future<void> _initializePeerConnection() async {
    try {
      if (_peerConnection != null) {
        await _peerConnection!.close();
        print('关闭旧的PeerConnection');
      }

      _peerConnection = await createPeerConnection(_rtcConfiguration);

      _peerConnection!.onIceCandidate = (RTCIceCandidate candidate) {
        _sendIceCandidate(candidate);
      };

      _peerConnection!.onConnectionState = (RTCPeerConnectionState state) {
        setState(() {
          _connectionStatus = _getConnectionStatusText(state);
        });
        print('WebRTC连接状态变化: $_connectionStatus');

      };

      _peerConnection!.onIceConnectionState = (RTCIceConnectionState state) {
        print('ICE连接状态: ${state.toString()}');
      };

      _peerConnection!.onIceGatheringState = (RTCIceGatheringState state) {
        print('ICE收集状态: ${state.toString()}');
      };

      _peerConnection!.onDataChannel = (RTCDataChannel channel) {
        print('收到数据通道: ${channel.label}');
        _setupDataChannel(channel);
      };
    } catch (e) {
      print('❌ 创建PeerConnection失败: $e');
    }
  }

  void _handleSignalingMessage(Map<String, dynamic> message) {
    final type = message['type'];

    switch (type) {
      case 'ping':
      case 'pong':
      // 处理ping/pong消息，用于连接确认
        print('收到服务器响应，连接已建立');
        break;

      case 'user-joined':
        final userId = message['user_id'];
        if (userId != _localUserId && !_roomUsers.contains(userId)) {
          setState(() {
            _roomUsers.add(userId);
          });
          print('用户加入: $userId');
        }

        for (var user in message["data"]["users"]) {
          if(user != _localUserId){
            _targetUserId = user;
            _roomUsers.add(user);
            setState(() {

            });
          }
        }

        break;

      case 'user-left':
        final userId = message['user_id'];
        setState(() {
          _roomUsers.remove(userId);
        });
        print('用户离开: $userId');
        break;

      case 'room-users':
        final users = List<String>.from(message['users'] ?? []);
        setState(() {
          _roomUsers.clear();
          _roomUsers.addAll(users.where((u) => u != _localUserId));
        });
        print('房间用户列表: ${_roomUsers.join(', ')}');
        break;

      case 'join-room-success':
        print('✅ 成功加入房间: ${message['room_id']}');
        break;

      case 'join-room-error':
        print('❌ 加入房间失败: ${message['error']}');
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
        print('未知信令消息类型: $type');
    }
  }

  Future<void> _handleOffer(Map<String, dynamic> message) async {
    try {
      print('收到Offer来自: ${message['user_id']}');
      await _initializePeerConnection();

      final offer = RTCSessionDescription(
        message['data']['sdp'],
        message['data']['type'],
      );

      await _peerConnection!.setRemoteDescription(offer);
      final answer = await _peerConnection!.createAnswer();
      await _peerConnection!.setLocalDescription(answer);

      _sendAnswer(message['user_id'], answer);
    } catch (e) {
      print('❌ 处理Offer失败: $e');
    }
  }

  Future<void> _handleAnswer(Map<String, dynamic> message) async {
    try {
      final answer = RTCSessionDescription(
        message['data']['sdp'],
        message['data']['type'],
      );

      await _peerConnection!.setRemoteDescription(answer);
    } catch (e) {
      print('❌ 处理Answer失败: $e');
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
    } catch (e) {
      print('❌ 添加ICE候选者失败: $e');
    }
  }

  void _sendOffer(String targetUserId) async {
    try {
      if (_peerConnection == null) {
        await _initializePeerConnection();
      }

      _targetUserId = targetUserId;

      // 创建数据通道
      final dataChannelInit = RTCDataChannelInit();
      _dataChannel = await _peerConnection!.createDataChannel('fileSync', dataChannelInit);
      _setupDataChannel(_dataChannel!);

      final offer = await _peerConnection!.createOffer();
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
    } catch (e) {
      print('❌ 发送Offer失败: $e');
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
      final bool opened = state == RTCDataChannelState.RTCDataChannelOpen;
      if (opened != _isDataChannelOpen) {
        setState(() {
          _isDataChannelOpen = opened;
        });
      }
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
          print('📨 收到传输完成指示: ${data['uuid'] ?? ''}');
          // 实际合并触发在 _handleBinaryData 内部（收到足够的块时）
          break;
        case 'transfer-ack':
          print('📮 收到传输确认: ${data['uuid']} 成功: ${data['success']}');
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
          print('收到文本: ${data['content']}');
          break;
        default:
          print('收到未知消息类型: $type');
      }
    } catch (e) {
      print('处理消息错误: $e');
    }
  }


  // 处理对端的库存请求：根据 uuid 判断本地是否具备对应文件（以数据库 localMhtmlPath 非空为准）
  Future<void> _handleSyncInventoryRequest(Map<String, dynamic> data) async {
    try {
      final List<dynamic> req = (data['uuids'] ?? []) as List<dynamic>;
      final List<String> requestUUIDs = req.map((e) => e.toString()).toList();

      // 查询本地存在的文章
      final existingArticles = await ArticleService.instance.getByUUIDs(requestUUIDs);
      final Map<String, dynamic> existingMap = { for (final a in existingArticles) a.uuid: a };

      final List<String> missingUUIDs = []; // 需要同步的 uuid（仅以 DB 的 localMhtmlPath 是否为空为准）
      final List<String> haveValid = [];    // 本地已有（localMhtmlPath 非空）
      final List<String> unknown = [];      // 本地不存在该 uuid（忽略）

      for (final uuid in requestUUIDs) {
        final a = existingMap[uuid];
        if (a == null) {
          unknown.add(uuid);
          continue;
        }
        final path = (a.localMhtmlPath ?? '').trim();
        if (path.isEmpty) {
          missingUUIDs.add(uuid);
        } else {
          haveValid.add(uuid);
        }
      }

      final resp = {
        'type': 'sync-inventory-response',
        'missingUUIDs': missingUUIDs,
        'missingUuids': missingUUIDs, // 兼容 web 端
        'from': _localUserId,
      };
      _dataChannel?.send(RTCDataChannelMessage(json.encode(resp)));

      if (haveValid.isNotEmpty) {
        print('✅ 本地已有（DB 路径非空）: $haveValid');
      }
      if (missingUUIDs.isNotEmpty) {
        print('❗ 本地缺失（DB 路径为空）: $missingUUIDs');
      }
      if (unknown.isNotEmpty) {
        print('ℹ️ 本地不存在这些 uuid（忽略）: $unknown');
      }
    } catch (e) {
      print('❌ 处理库存请求失败: $e');
      final resp = {
        'type': 'sync-inventory-response',
        'missingUUIDs': <String>[],
        'missingUuids': <String>[],
        'from': _localUserId,
      };
      _dataChannel?.send(RTCDataChannelMessage(json.encode(resp)));
    }
  }

  void _handleSyncInventoryResponse(Map<String, dynamic> data) {
    try {
      final List<dynamic> miss = (data['missingUUIDs'] ?? data['missingUuids'] ?? []) as List<dynamic>;
      final List<String> missingUUIDs = miss.map((e) => e.toString()).toList();
      if (missingUUIDs.isEmpty) {
        print('✅ 对端不缺文件，已同步');
        setState(() {
          _isSyncInProgress = false;
        });
      } else {
        print('❗ 对端缺失 ${missingUUIDs.length} 个文件，后续仅对这些 uuid 发送');
        // 触发发送缺失文件
        _sendMissingFiles(missingUUIDs);
      }
      // 可在此处缓存 missingUUIDs 以驱动后续文件发送管线
    } catch (e) {
      print('❌ 处理库存响应失败: $e');
      setState(() {
        _isSyncInProgress = false;
      });
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

      print('文件已保存: $fileName (${bytes.length} 字节)');
    } catch (e) {
      print('保存文件错误: $e');
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
        print('❌ 无效的文件头: uuid 或 totalChunks 缺失');
        return;
      }

      _binaryReceiving[uuid] = _BinaryReceiveState(
        uuid: uuid,
        fileName: fileName,
        size: size,
        totalChunks: totalChunks,
      );
      _currentBinaryUuid = uuid;

      print('📥 开始接收(二进制): $fileName (${size} 字节, $totalChunks 块)');
      setState(() {});
    } catch (e) {
      print('❌ 处理二进制文件头错误: $e');
    }
  }

  // 新协议：接收二进制数据块
  void _handleBinaryData(Uint8List binary) {
    try {
      if (_currentBinaryUuid == null || !_binaryReceiving.containsKey(_currentBinaryUuid)) {
        print('⚠️ 收到意外的二进制数据，未找到正在接收的文件');
        return;
      }

      final state = _binaryReceiving[_currentBinaryUuid!]!;
      state.chunks.add(binary);
      state.receivedChunks += 1;

      final progress = (state.receivedChunks / state.totalChunks * 100).clamp(0, 100).toStringAsFixed(1);
      print('📦 接收二进制块: ${state.fileName} $progress% (${state.receivedChunks}/${state.totalChunks})');

      if (state.receivedChunks >= state.totalChunks) {
        _finalizeBinaryFile(state);
      }
    } catch (e) {
      print('❌ 处理二进制数据块错误: $e');
    }
  }

  // 新协议：合并二进制并解压、写库
  Future<void> _finalizeBinaryFile(_BinaryReceiveState state) async {
    try {
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
        final bool isDirectory = file.isFile == false || file.name.endsWith('/') ||
            (file.content.isEmpty && !file.name.contains('.'));
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

      // 写库：根据 uuid 更新对应文章的本地路径
      await ArticleService.instance.dbService.isar.writeTxn(() async {
        final articles = await ArticleService.instance.getByUUIDs([state.uuid]);
        if (articles.isNotEmpty) {
          final article = articles.first;
          article.localMhtmlPath = extractDir;
          await ArticleService.instance.updateLocalMhtmlPath(article);
        } else {
          print('⚠️ 未找到对应UUID的文章: ${state.uuid}');
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

    } catch (e) {
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
      print('处理文件头错误: $e');
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
        print('收到未知文件块: $fileId');
        return;
      }

      final fileInfo = _receivingFiles[fileId]!;

      // 解码并存储块数据
      final bytes = base64Decode(chunkData);
      fileInfo.chunks[chunkIndex] = bytes;
      fileInfo.receivedChunks[chunkIndex] = true;

      final progress = (fileInfo.receivedChunks.length / fileInfo.totalChunks * 100).round();
      print('接收进度: ${fileInfo.fileName} $progress% (${fileInfo.receivedChunks.length}/${fileInfo.totalChunks})');

      // 检查是否接收完所有块
      if (fileInfo.receivedChunks.length == fileInfo.totalChunks) {
        await _assembleAndSaveFile(fileInfo);
        _receivingFiles.remove(fileId);
      }

      setState(() {});
    } catch (e) {
      print('处理文件块错误: $e');
    }
  }

  Future<void> _assembleAndSaveFile(_FileReceiveInfo fileInfo) async {
    try {
      print('开始组装文件: ${fileInfo.fileName}');

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

      print('✅ 文件接收完成: ${fileInfo.fileName} (${allBytes.length} 字节)');
      print('📁 保存路径: ${file.path}');
    } catch (e) {
      print('❌ 组装文件错误: $e');
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text('文件同步', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500)),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black87,
        elevation: 0,
        centerTitle: true,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            children: [
              // 状态卡片
              _buildStatusCard(),
              const SizedBox(height: 24),
              // 设备列表
              _buildDeviceList(),
              const Spacer(),
              // 同步按钮
              _buildSyncButton(),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }


  // 状态卡片
  Widget _buildStatusCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Icon(
            _isSignalingConnected ? Icons.cloud_done : Icons.cloud_off,
            size: 48,
            color: _isSignalingConnected ? Colors.green : Colors.grey,
          ),
          const SizedBox(height: 12),
          Text(
            _isSignalingConnected ? '已连接到同步服务' : '连接同步服务中...',
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            _isSignalingConnected ? '可以开始同步数据' : '请稍候',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[600],
            ),
          ),
        ],
      ),
    );
  }

  // 设备列表
  Widget _buildDeviceList() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.devices, color: Colors.grey[700], size: 20),
              const SizedBox(width: 8),
              const Text(
                '可同步的设备',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          if (_roomUsers.isEmpty)
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.grey[50],
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  Icon(Icons.search, color: Colors.grey[500], size: 20),
                  const SizedBox(width: 12),
                  Text(
                    '正在搜索附近的设备...',
                    style: TextStyle(color: Colors.grey[600]),
                  ),
                ],
              ),
            )
          else
            ..._roomUsers.map((user) => _buildDeviceItem(user)).toList(),
        ],
      ),
    );
  }

  // 设备项
  Widget _buildDeviceItem(String userId) {
    final isSelected = _targetUserId == userId;
    final isConnected = _isDataChannelOpen && isSelected;
    
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      child: Material(
        color: isSelected ? Colors.blue[50] : Colors.grey[50],
        borderRadius: BorderRadius.circular(12),
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: () {
            setState(() {
              _targetUserId = userId;
            });
            if (!isConnected) {
              _sendOffer(userId);
            }
          },
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Icon(
                  isConnected ? Icons.smartphone_outlined : Icons.phone_android,
                  color: isConnected ? Colors.green : Colors.grey[600],
                  size: 24,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '设备 ${userId.substring(0, 8)}...',
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        isConnected ? '已连接' : '点击连接',
                        style: TextStyle(
                          fontSize: 12,
                          color: isConnected ? Colors.green : Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ),
                if (isConnected)
                  Icon(Icons.check_circle, color: Colors.green, size: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // 同步按钮
  Widget _buildSyncButton() {
    final canSync = _isDataChannelOpen && !_isSyncInProgress;
    
    return Container(
      width: double.infinity,
      height: 56,
      child: ElevatedButton(
        onPressed: canSync ? _startSync : null,
        style: ElevatedButton.styleFrom(
          backgroundColor: canSync ? Colors.blue : Colors.grey[300],
          foregroundColor: Colors.white,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (_isSyncInProgress)
              const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              )
            else
              const Icon(Icons.sync, size: 20),
            const SizedBox(width: 12),
            Text(
              _isSyncInProgress ? '正在同步数据...' : '开始同步',
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // 发送端：开始同步（发送库存请求）
  Future<void> _startSync() async {
    if (_dataChannel == null || !_isDataChannelOpen) {
      print('❌ 数据通道未建立，无法开始同步');
      return;
    }
    if (_isSyncInProgress) {
      print('⏳ 已有同步任务进行中，请稍候');
      return;
    }

    try {
      setState(() {
        _isSyncInProgress = true;
      });
      print('🚀 开始同步文章文件...');

      // 1. 获取所有含有本地MHTML路径的文章
      final articles = await ArticleService.instance.getArticlesWithLocalMhtml();
      if (articles.isEmpty) {
        print('ℹ️ 没有找到需要同步的文章文件');
        setState(() {
          _isSyncInProgress = false;
        });
        return;
      }

      final uuids = articles.map((a) => a.uuid).toList();
      print('📋 找到 ${articles.length} 个待同步文章: $uuids');

      // 2. 发送库存请求
      final req = {
        'type': 'sync-inventory-request',
        'uuids': uuids,
        'from': _localUserId,
      };
      _dataChannel?.send(RTCDataChannelMessage(json.encode(req)));
      print('✅ 已发送库存请求，等待对方响应...');
    } catch (e) {
      print('❌ 开始同步失败: $e');
      setState(() {
        _isSyncInProgress = false;
      });
    }
  }

  // 发送端：根据对端缺失UUID发送文件
  Future<void> _sendMissingFiles(List<String> missingUUIDs) async {
    if (_dataChannel == null || !_isDataChannelOpen) {
      print('❌ 数据通道未建立，无法发送文件');
      setState(() {
        _isSyncInProgress = false;
      });
      return;
    }

    try {
      final missingArticles = await ArticleService.instance.getByUUIDs(missingUUIDs);
      print('📦 需要发送 ${missingArticles.length} 个文件');

      const int chunkSize = 65536; // 64KB

      for (int i = 0; i < missingArticles.length; i++) {
        final a = missingArticles[i];
        final titleOrUuid = (a.title.isNotEmpty ? a.title : a.uuid);
        try {
          if ((a.localMhtmlPath).isEmpty) {
            print('⚠️ 文章 ${a.uuid} 缺少本地路径，跳过');
            continue;
          }

          // 决定压缩的目录
          String dirPath = a.localMhtmlPath;
          final dir = Directory(dirPath);
          if (!await dir.exists()) {
            // 若保存的是文件路径，取父级目录
            final fileAsPath = File(dirPath);
            if (await fileAsPath.exists()) {
              dirPath = Directory(p.dirname(dirPath)).path;
            } else {
              print('⚠️ 本地目录/文件不存在，跳过: $dirPath');
              continue;
            }
          }

          print('📤 (${i + 1}/${missingArticles.length}) 压缩并发送: $titleOrUuid');
          final Uint8List zipBytes = await _zipDirectoryToBytes(dirPath);

          // 文件头
          final int totalChunks = (zipBytes.length / chunkSize).ceil();
          final header = {
            'type': 'file-binary-header',
            'uuid': a.uuid,
            'fileName': 'article_${a.uuid}.zip',
            'size': zipBytes.length,
            'totalChunks': totalChunks,
          };
          _dataChannel?.send(RTCDataChannelMessage(json.encode(header)));
          print('📨 已发送文件头: ${header['fileName']} (${zipBytes.length} 字节, $totalChunks 块)');

          // 分块发送
          for (int chunkIndex = 0; chunkIndex < totalChunks; chunkIndex++) {
            final int start = chunkIndex * chunkSize;
            final int end = (start + chunkSize > zipBytes.length) ? zipBytes.length : start + chunkSize;
            final Uint8List chunk = Uint8List.sublistView(zipBytes, start, end);

            _dataChannel?.send(RTCDataChannelMessage.fromBinary(chunk));

            if ((chunkIndex + 1) % 8 == 0) {
              // 简单节流，避免缓冲区压力
              await Future.delayed(const Duration(milliseconds: 2));
            }

            final progress = (((chunkIndex + 1) / totalChunks) * 100).clamp(0, 100).toStringAsFixed(1);
            print('📦 正在发送 ${a.uuid}: $progress% (${chunkIndex + 1}/$totalChunks)');
          }

          // 发送完成指示
          final complete = {
            'type': 'transfer-complete',
            'uuid': a.uuid,
          };
          _dataChannel?.send(RTCDataChannelMessage(json.encode(complete)));
          print('✅ 文件发送完成: ${a.uuid}');
        } catch (err) {
          print('❌ 发送文件失败(${a.uuid}): $err');
        }
      }

      print('🎉 文章文件同步完成');
      setState(() {
        _isSyncInProgress = false;
      });
    } catch (e) {
      print('❌ 处理库存响应/发送文件失败: $e');
      setState(() {
        _isSyncInProgress = false;
      });
    }
  }

  // 工具：将目录压缩为Zip字节
  Future<Uint8List> _zipDirectoryToBytes(String directoryPath) async {
    final Directory root = Directory(directoryPath);
    if (!await root.exists()) {
      throw Exception('目录不存在: $directoryPath');
    }

    final Archive archive = Archive();

    Future<void> addDirectory(Directory dir, String relative) async {
      final List<FileSystemEntity> entities = await dir.list(recursive: false, followLinks: false).toList();
      // 确保目录项存在（可选）
      if (relative.isNotEmpty && !relative.endsWith('/')) {
        archive.addFile(ArchiveFile('$relative/', 0, Uint8List(0))
          ..isFile = false);
      }
      for (final entity in entities) {
        final String name = p.basename(entity.path);
        final String relPath = relative.isEmpty ? name : '$relative/$name';
        if (entity is File) {
          final bytes = await entity.readAsBytes();
          archive.addFile(ArchiveFile(relPath.replaceAll('\\', '/'), bytes.length, bytes));
        } else if (entity is Directory) {
          await addDirectory(entity, relPath);
        }
      }
    }

    await addDirectory(root, '');

    final ZipEncoder encoder = ZipEncoder();
    final List<int>? encoded = encoder.encode(archive);
    if (encoded == null) {
      throw Exception('Zip 压缩失败');
    }
    return Uint8List.fromList(encoded);
  }
}