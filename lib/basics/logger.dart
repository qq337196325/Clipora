import 'package:logger/logger.dart';
import 'package:get/get.dart';

import '../db/flutter_logger/flutter_logger_service.dart';
import '/basics/config.dart';
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
    final DateTime timestamp = DateTime.now();

    // print(event.origin.message);
    // print(111111111111111111);
    // print(event.origin.stackTrace.toString());
    // print(event.origin.error.toString());
    // print(22222222);
    // print(logMessage);

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
