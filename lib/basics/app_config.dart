// Copyright (c) 2025 Clipora.
//
// This work is licensed under the Creative Commons Attribution-NonCommercial-NoDerivatives 4.0 International License.
// To view a copy of this license, visit http://creativecommons.org/licenses/by-nc-nd/4.0/


import 'app_config_interface.dart';


/// App apecific configuration implementation
class AppConfig implements IConfig {
  @override
  String get wxAppId => "";

  @override
  String get wxUniversalLink => "";

  @override
  String get urlAgreement => "";

  @override
  String get urlPrivacy => "";

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
  String get apiHost => "";

  @override
  String get recordNumber => "";

  @override
  bool get isCommunityEdition=>true;
}