import UIKit
import Social
import MobileCoreServices
import UniformTypeIdentifiers

class ShareViewController: SLComposeServiceViewController {
    
    override func isContentValid() -> Bool {
        return true
    }
    
    override func didSelectPost() {
        let group = DispatchGroup()
        
        // 处理分享内容
        if let extensionItem = extensionContext?.inputItems.first as? NSExtensionItem {
            if let itemProviders = extensionItem.attachments {
                
                for itemProvider in itemProviders {
                    group.enter()
                    
                    // 处理文本内容
                    if itemProvider.hasItemConformingToTypeIdentifier(UTType.text.identifier) {
                        itemProvider.loadItem(forTypeIdentifier: UTType.text.identifier, options: nil) { (item, error) in
                            if let text = item as? String {
                                self.handleSharedContent(content: text, type: "text")
                            }
                            group.leave()
                        }
                    }
                    // 处理URL
                    else if itemProvider.hasItemConformingToTypeIdentifier(UTType.url.identifier) {
                        itemProvider.loadItem(forTypeIdentifier: UTType.url.identifier, options: nil) { (item, error) in
                            if let url = item as? URL {
                                self.handleSharedContent(content: url.absoluteString, type: "url")
                            }
                            group.leave()
                        }
                    }
                    // 处理图片
                    else if itemProvider.hasItemConformingToTypeIdentifier(UTType.image.identifier) {
                        itemProvider.loadItem(forTypeIdentifier: UTType.image.identifier, options: nil) { (item, error) in
                            if let imageUrl = item as? URL {
                                self.handleSharedContent(content: imageUrl.path, type: "image")
                            }
                            group.leave()
                        }
                    }
                    // 处理其他文件
                    else {
                        itemProvider.loadItem(forTypeIdentifier: UTType.data.identifier, options: nil) { (item, error) in
                            if let fileUrl = item as? URL {
                                self.handleSharedContent(content: fileUrl.path, type: "file")
                            }
                            group.leave()
                        }
                    }
                }
            }
        }
        
        group.notify(queue: .main) {
            // 完成分享处理后关闭扩展
            self.extensionContext?.completeRequest(returningItems: [], completionHandler: nil)
        }
    }
    
    private func handleSharedContent(content: String, type: String) {
        // 打开主应用并传递分享内容
        let urlString = "ShareMedia-inkwell://share?content=\(content.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? "")&type=\(type)"
        
        if let url = URL(string: urlString) {
            // 使用共享的UserDefaults来传递数据
            let sharedDefaults = UserDefaults(suiteName: "group.inkwell.shared")
            sharedDefaults?.set(content, forKey: "shared_content")
            sharedDefaults?.set(type, forKey: "shared_type")
            sharedDefaults?.set(Date().timeIntervalSince1970, forKey: "shared_timestamp")
            
            var responder = self as UIResponder?
            let selectorOpenURL = sel_registerName("openURL:")
            while (responder != nil) {
                if responder?.responds(to: selectorOpenURL) == true {
                    responder?.perform(selectorOpenURL, with: url)
                }
                responder = responder!.next
            }
        }
    }
    
    override func configurationItems() -> [Any]! {
        return []
    }
} 