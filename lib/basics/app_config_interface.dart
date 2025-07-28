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