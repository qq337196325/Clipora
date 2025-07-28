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


import 'package:logger/logger.dart';
import 'package:get/get.dart';

import '../db/flutter_logger/flutter_logger_service.dart';
import 'app_config_interface.dart';

// 日志监听回调函数类型
typedef LogCallback = void Function(String level, String message, DateTime timestamp);

// 需要上传的日志级别
const Set<String> UPLOAD_LEVELS = {
  'e', // error - 错误日志，必须上传
  'w', // warning - 警告日志，建议上传
};

bool shouldUploadLog(String level) {
  return UPLOAD_LEVELS.contains(level);
}

Logger getLogger() {

  final config = Get.find<IConfig>();

  final logData = Logger(
      printer: PrettyPrinter(
        methodCount: 1,
        // errorMethodCount: 8,
        lineLength: 120,
        colors: true,
        printEmojis: true,
      ),
      level: config.isDevelop ? Level.info : Level.warning,
      output: MultiOutput([
        ConsoleOutput(), // 保持原有的控制台输出
        ServerLogOutput() // 添加我们的监听功能
      ])
    );

  return logData;
}

class ServerLogOutput extends LogOutput {
  // 静态变量存储日志监听器
  ServerLogOutput();

  final FlutterLoggerService _flutterLoggerService = FlutterLoggerService();

  @override
  void output(OutputEvent event) async {
    final String logMessage = event.lines.join("\n");
    final String level = _getLevelString(event.level);

    if(level == "warning" || level == "error"){
      _flutterLoggerService.saveLog(
        level: level,
        message: event.origin.message.toString(),
        errorMessage: event.origin.error.toString(),
        linesMessage: logMessage,
      );
    }
  }

  // 获取日志级别字符串
  String _getLevelString(Level level) {
    switch (level) {
      case Level.debug:
        return 'debug';
      case Level.info:
        return 'info';
      case Level.warning:
        return 'warning';
      case Level.error:
        return 'error';
      default:
        return 'unknown';
    }
  }

}