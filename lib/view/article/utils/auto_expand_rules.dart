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



class AutoExpandRule {
  /// A unique identifier for the rule.
  final String id;
  
  /// The pattern to match against the host of the URL.
  final String urlHostContains;
  
  /// A list of CSS selectors to find and click in sequence.
  /// For a simple "click more" button, this will have one item.
  /// For complex interactions, it can have multiple selectors.
  final List<String> sequentialSelectors;
  
  /// Maximum number of times to execute the click sequence.
  final int maxRuns;
  
  /// Delay in milliseconds before the first execution.
  final int initialDelayMs;
  
  /// Interval in milliseconds between sequence executions.
  final int runIntervalMs;

  const AutoExpandRule({
    required this.id,
    required this.urlHostContains,
    required this.sequentialSelectors,
    this.maxRuns = 3,
    this.initialDelayMs = 1000,
    this.runIntervalMs = 1500,
  });
}

/// A registry of rules for automatically expanding content on websites.
class AutoExpandRuleRegistry {
  static final List<AutoExpandRule> _rules = [
    // Rule for Toutiao articles
    const AutoExpandRule(
      id: 'toutiao-unfold',
      urlHostContains: 'm.toutiao.com',
      sequentialSelectors: ['.toggle-button', ".button-group .cancel"], // This is an example, might need adjustment
    ),
    const AutoExpandRule(
      id: 'wwwzhihucom',
      urlHostContains: 'www.zhihu.com',
      sequentialSelectors: ['.RichContent .Button'], // This is an example, might need adjustment
    ),
    

    
  ];
  
  /// Finds the first matching rule for a given URL.
  static AutoExpandRule? findRuleForUrl(Uri uri) {
    try {
      return _rules.firstWhere((rule) => uri.host.contains(rule.urlHostContains));
    } catch (e) {
      return null; // No rule found
    }
  }
} 