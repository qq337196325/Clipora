import 'package:logger/logger.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:io' as io;

import '/basics/config.dart';

/// Logger工具类 - 用于处理日志输出
/// 
/// 使用说明：
/// 1. getLogger() - 默认的日志器，不限制行长度，避免截断问题
/// 2. getLogger(enableLineLimit: true) - 启用行长度限制，适应终端宽度
/// 3. getDebugLogger() - 调试专用日志器，显示详细信息和时间戳
/// 
/// 解决macOS日志截断问题：
/// - 默认使用极大的lineLength值(9999)来避免任何截断
/// - 在macOS上某些终端可能对长行处理不同，此设置确保完整显示
/// 
/// 示例：
/// ```dart
/// final log = getLogger(); // 推荐：完整显示所有内容
/// final debugLog = getDebugLogger(); // 调试时使用
/// final terminalLog = getLogger(enableLineLimit: true); // 适应终端宽度
/// ```

printLogger(String level, Map<String, dynamic> message) async {
  final log = getLogger();
  switch(level){
    case "i":
      log.i(message);
      break;
    case "d":
      log.d(message);
      break;
    case "w":
      log.w(message);
      break;
    case "e":
      log.e(message);
      break;
    case "v":
      log.t(message);
      break;
  }

  if(level == "i"){
    return;
  }

  final prefs = await SharedPreferences.getInstance();
  String? _userName = prefs.getString('userName');
  String? _token = prefs.getString('token');

  // Map<String, dynamic> param = {
  //   "level": level,
  //   "user_name": _userName == null ? "": _userName,
  //   "token" : _token == null ? "": _token,
  //   "log": message,
  //   "version": version,
  // };
  // await BaseApi.addClientLog(param);
}

Logger getLogger({bool enableLineLimit = false}) {
  int lineLength = 300; // 默认使用较大的行长度
  
  if (enableLineLimit) {
    // 动态检测终端宽度，如果无法检测则使用默认值
    try {
      // 尝试获取终端列数
      if (io.stdout.hasTerminal) {
        lineLength = io.stdout.terminalColumns;
      }
    } catch (e) {
      // 如果无法检测，使用默认值
      lineLength = 120;
    }
    
    // 确保最小行长度
    if (lineLength < 120) {
      lineLength = 120;
    }
  } else {
    // 使用一个很大的值来避免截断
    lineLength = 9999;
  }

  final logData = Logger(
      printer: PrettyPrinter(
        methodCount: 1,
        errorMethodCount: 8,
        lineLength: lineLength, 
        colors: io.stdout.supportsAnsiEscapes, // 动态检测颜色支持
        printEmojis: true,
        dateTimeFormat: DateTimeFormat.none, // 替代deprecated的printTime: false
      ),
      level: isDevelop ? Level.info : Level.warning,
      // output: ServerLogOutput()
  );

  return logData;
}

/// 专门用于调试的Logger，不限制行长度，确保完整显示所有日志内容
Logger getDebugLogger() {
  final logData = Logger(
      printer: PrettyPrinter(
        methodCount: 1,
        errorMethodCount: 8,
        lineLength: 9999, // 使用极大的值来避免任何截断
        colors: io.stdout.supportsAnsiEscapes,
        printEmojis: true,
        dateTimeFormat: DateTimeFormat.onlyTimeAndSinceStart, // 调试时显示时间戳
      ),
      level: Level.trace, // 显示所有级别的日志（替代deprecated的verbose）
  );

  return logData;
}

class ServerLogOutput extends LogOutput {
  ServerLogOutput();

  @override
  void output(OutputEvent event) async {
    final String log = event.lines.join("\n");
    print(log);
    if (event.level == Level.info){
      return ;
    }

    // final prefs = await SharedPreferences.getInstance();
    // String? _userName = prefs.getString('userName');
    // String? _token = prefs.getString('token');
    //
    // Map<String, dynamic> param = {
    //   "level": event.level.toString(),
    //   "user_name": _userName == null ? "": _userName,
    //   "token" : _token == null ? "": _token,
    //   "log": log,
    //   "version": version,
    // };
    // await BaseApi.addClientLog(param);
  }

}
