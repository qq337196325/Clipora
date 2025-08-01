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