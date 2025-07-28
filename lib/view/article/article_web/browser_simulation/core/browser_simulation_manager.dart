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



import 'package:get/get.dart';
import '../../../../../basics/logger.dart';
import '../identity/storage_manager.dart';
import '../identity/request_header_manager.dart';
import 'simulation_config.dart';
import 'simulation_state.dart';


/// 浏览器仿真核心管理器
/// 负责协调所有仿真功能的统一管理
class BrowserSimulationManager extends GetxController {
  static BrowserSimulationManager get instance => Get.find<BrowserSimulationManager>();
  
  // 仿真配置
  late final SimulationConfig _config;
  
  // 仿真状态
  late final SimulationState _state;
  
  // 存储管理器
  late final BrowserStorageManager _storageManager;
  
  // 请求头管理器
  late final RequestHeaderManager _headerManager;
  
  // Getters
  SimulationConfig get config => _config;
  SimulationState get state => _state;
  BrowserStorageManager get storageManager => _storageManager;
  RequestHeaderManager get headerManager => _headerManager;
  
  @override
  void onInit() {
    super.onInit();
    _initializeSimulation();
  }
  
  /// 初始化仿真系统
  Future<void> _initializeSimulation() async {
    try {
      getLogger().i('🚀 开始初始化浏览器仿真系统...');
      
      // 初始化配置
      _config = SimulationConfig();
      
      // 初始化状态
      _state = SimulationState();
      
      // 初始化存储管理器
      _storageManager = BrowserStorageManager();
      await _storageManager.initialize();
      
      // 初始化请求头管理器
      _headerManager = RequestHeaderManager(_config);
      
      // 标记初始化完成
      _state.isInitialized = true;
      
      getLogger().i('✅ 浏览器仿真系统初始化完成');
    } catch (e) {
      getLogger().e('❌ 浏览器仿真系统初始化失败: $e');
      _state.isInitialized = false;
      rethrow;
    }
  }
  
  /// 重置仿真系统
  Future<void> resetSimulation() async {
    try {
      getLogger().i('🔄 开始重置浏览器仿真系统...');
      
      // 清理存储
      await _storageManager.clearAllStorage();
      
      // 重置状态
      _state.reset();
      
      // 重新初始化
      await _initializeSimulation();
      
      getLogger().i('✅ 浏览器仿真系统重置完成');
    } catch (e) {
      getLogger().e('❌ 浏览器仿真系统重置失败: $e');
      rethrow;
    }
  }
  
  /// 获取仿真状态信息
  Map<String, dynamic> getSimulationInfo() {
    return {
      'initialized': _state.isInitialized,
      'sessionId': _state.sessionId,
      'startTime': _state.startTime?.toIso8601String(),
      'cookieCount': _storageManager.getCookieCount(),
      'localStorageKeys': _storageManager.getLocalStorageKeys(),
      'sessionStorageKeys': _storageManager.getSessionStorageKeys(),
    };
  }
  
  @override
  void onClose() {
    _storageManager.dispose();
    super.onClose();
  }
} 