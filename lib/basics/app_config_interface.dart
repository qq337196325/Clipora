// Copyright (c) 2025 Clipora.
//
// This work is licensed under the Creative Commons Attribution-NonCommercial-NoDerivatives 4.0 International License.
// To view a copy of this license, visit http://creativecommons.org/licenses/by-nc-nd/4.0/




abstract class IConfig {
  String get urlAgreement;
  String get urlPrivacy;
  bool get isHuawei;
  bool get isDevelop;
  String get apiVersion;
  String get version;
  int get clientVersion;
  String get apiHost;
  String get recordNumber;
  bool get isCommunityEdition;

  String get wxAppId;
  String get wxUniversalLink;
}