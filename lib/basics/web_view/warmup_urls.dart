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



import 'package:get_storage/get_storage.dart';

import '../logger.dart';

/// 需要进行预热的url
class WarmupUrls {

  final box = GetStorage();

  /// 从后端获取需要预热的url,【当前暂时先写死】
  apiUpdateWarmupUrls(){
    box.write('warmup_urls', {'www.zhihu.com': false});   // {域名：是否已经预热过}
    getLogger().i('更新预热URL列表');
  }

  /// 获取需要预热的url
  getWarmupUrls() {
    Map warmupUrls = box.read('warmup_urls') ?? {};
    getLogger().d('获取预热URL列表: $warmupUrls');
    return warmupUrls;
  }

  /// 更新指定域名的预热状态
  /// [domain] 域名
  /// [isWarmedUp] 是否已预热，默认为true
  updateWarmupStatus(String domain, {bool isWarmedUp = true}) {
    try {
      Map<String, dynamic> warmupUrls = Map<String, dynamic>.from(getWarmupUrls());
      
      // 如果域名存在，更新其预热状态
      if (warmupUrls.containsKey(domain)) {
        warmupUrls[domain] = isWarmedUp;
        box.write('warmup_urls', warmupUrls);
        getLogger().i('更新域名 $domain 预热状态为: $isWarmedUp');
      } else {
        getLogger().w('域名 $domain 不存在于预热列表中');
      }
    } catch (e) {
      getLogger().e('更新预热状态失败: $e');
    }
  }

  /// 检查指定域名是否已预热
  /// [domain] 域名
  /// 返回true表示已预热，false表示未预热
  bool isWarmedUp(String domain) {
    Map warmupUrls = getWarmupUrls();
    bool warmedUp = warmupUrls[domain] ?? false;
    getLogger().d('域名 $domain 预热状态: $warmedUp');
    return warmedUp;
  }

  /// 获取所有未预热的域名列表
  List<String> getUnwarmedDomains() {
    Map warmupUrls = getWarmupUrls();
    List<String> unwarmedDomains = [];
    
    warmupUrls.forEach((domain, isWarmed) {
      if (!isWarmed) {
        unwarmedDomains.add(domain);
      }
    });
    
    getLogger().d('未预热域名列表: $unwarmedDomains');
    return unwarmedDomains;
  }

  /// 批量更新多个域名的预热状态
  /// [domains] 域名列表
  /// [isWarmedUp] 是否已预热，默认为true
  batchUpdateWarmupStatus(List<String> domains, {bool isWarmedUp = true}) {
    try {
      Map<String, dynamic> warmupUrls = Map<String, dynamic>.from(getWarmupUrls());
      
      for (String domain in domains) {
        if (warmupUrls.containsKey(domain)) {
          warmupUrls[domain] = isWarmedUp;
        }
      }
      
      box.write('warmup_urls', warmupUrls);
      getLogger().i('批量更新 ${domains.length} 个域名预热状态为: $isWarmedUp');
    } catch (e) {
      getLogger().e('批量更新预热状态失败: $e');
    }
  }

}