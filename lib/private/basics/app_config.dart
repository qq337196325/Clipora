import '../../basics/app_config_interface.dart';


/// App apecific configuration implementation
class AppConfig implements IConfig {
  @override
  String get wxAppId => "wx629011ac595bee08";

  @override
  String get urlAgreement => "https://clipora.guanshangyun.com/agreement";

  @override
  String get urlPrivacy => "https://clipora.guanshangyun.com/privacy";

  @override
  bool get isHuawei => false;

  @override
  bool get isDevelop => true;

  @override
  String get apiVersion => "/v130";

  @override
  String get version => "v1.4.0";

  @override
  int get clientVersion => 140;

  @override
  String get apiHost => "https://clipora-api.guanshangyun.com";

  @override
  String get recordNumber => "粤ICP备2021048632号-5A";


  @override
  bool get isCommunityEdition => false;
}
