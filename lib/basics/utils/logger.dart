import 'package:logger/logger.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '/basics/config.dart';

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
      log.v(message);
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

Logger getLogger() {
  final logData = Logger(
      printer: PrettyPrinter(
        methodCount: 1,
        errorMethodCount: 8,
        lineLength: 120,
        colors: true,
        printEmojis: true,
        printTime: false,
      ),
      level: isDevelop ? Level.info : Level.warning,
      // output: ServerLogOutput()
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
