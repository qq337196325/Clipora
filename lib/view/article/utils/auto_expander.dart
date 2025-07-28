// Copyright (c) 2025 Clipora.
//
// This work is licensed under the Creative Commons Attribution-NonCommercial-NoDerivatives 4.0 International License.
// To view a copy of this license, visit http://creativecommons.org/licenses/by-nc-nd/4.0/



import 'dart:convert';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import '../../../basics/logger.dart';
import 'auto_expand_rules.dart';

class AutoExpander {
  static void apply(InAppWebViewController controller, Uri url) {
    final rule = AutoExpandRuleRegistry.findRuleForUrl(url);

    if (rule == null) {
      return;
    }
    
    getLogger().i('🚀 Applying auto-expand rule "${rule.id}" for ${url.host}');

    final script = _generateScript(rule);
    
    controller.evaluateJavascript(source: script).catchError((e) {
      getLogger().e('❌ Failed to inject auto-expand script: $e');
    });
  }

  static String _generateScript(AutoExpandRule rule) {
    // Encode the selectors list into a JSON string to be safely embedded in JS.
    final selectorsJson = jsonEncode(rule.sequentialSelectors);

    return '''
      (function() {
        console.log('🚀 Advanced auto-expand script initiated for rule: "${rule.id}"');
        
        const selectors = ${selectorsJson};
        const maxRuns = ${rule.maxRuns};
        const runInterval = ${rule.runIntervalMs};
        const initialDelay = ${rule.initialDelayMs};
        
        let runCount = 0;

        // Helper function to find and click an element, returns a Promise
        async function findAndClick(selector, timeout = 5000) {
          console.log(`🔎 Searching for selector: ` + selector);
          const startTime = Date.now();
          
          return new Promise((resolve, reject) => {
            const intervalId = setInterval(() => {
              if (Date.now() - startTime > timeout) {
                clearInterval(intervalId);
                console.warn(`⌛️ Timed out waiting for selector: ` + selector);
                reject(new Error('Timeout for selector: ' + selector));
                return;
              }

              const element = document.querySelector(selector);
              // Check if element exists and is visible (offsetParent is a simple visibility check)
              if (element && element.offsetParent !== null) {
                clearInterval(intervalId);
                console.log(`🎯 Found, clicking: ` + selector);
                const event = new MouseEvent('click', { view: window, bubbles: true, cancelable: true });
                element.dispatchEvent(event);
                resolve();
              }
            }, 500); // Check every 500ms
          });
        }

        // Main execution logic that runs the sequence of clicks
        async function executeSequence() {
          if (runCount >= maxRuns) {
            console.log('✅ Auto-expand: Max runs reached for rule "${rule.id}". Stopping.');
            return;
          }
          
          console.log(`▶️ Starting run \${runCount + 1}/\${maxRuns} for rule "${rule.id}"`);
          
          try {
            for (const selector of selectors) {
              await findAndClick(selector);
              // Wait a bit after a click for the UI to update
              await new Promise(resolve => setTimeout(resolve, 300));
            }
            console.log(`✅ Sequence run \${runCount + 1} completed successfully.`);
            runCount++;

            // If there are more runs to go, schedule the next one
            if (runCount < maxRuns) {
              setTimeout(executeSequence, runInterval);
            }
          } catch (error) {
            console.error('⚠️ Sequence failed for rule "${rule.id}". Stopping further runs.', error.message);
            // Do not schedule the next run if a step fails.
          }
        }

        // Start the whole process after an initial delay
        setTimeout(executeSequence, initialDelay);

      })();
    ''';
  }
} 