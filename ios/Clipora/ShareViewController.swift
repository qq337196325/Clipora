//
//  ShareViewController.swift
//  Clipora
//
//  Created by zouyougui on 2025/6/15.
//

import UIKit
import MobileCoreServices
import receive_sharing_intent

class ShareViewController: RSIShareViewController {
    
    private var titleLabel: UILabel!
    private var contentLabel: UILabel!
    private var saveButton: UIButton!
    private var cancelButton: UIButton!
    
    // App Group标识符
    private let appGroupId = "group.com.guanshangyun.clipora"
    
    // 保存解析出的分享内容
    private var sharedData: [String: Any] = [:]
    
//    override func viewDidLoad() {
//        super.viewDidLoad()
//        setupUI()
//        processSharedContent()
//    }
//    
//    private func setupUI() {
//        // 兼容iOS 13以下版本的背景色
//        if #available(iOS 13.0, *) {
//            view.backgroundColor = UIColor.systemBackground
//        } else {
//            view.backgroundColor = UIColor.white
//        }
//        
//        // 创建UI元素
//        titleLabel = UILabel()
//        titleLabel.text = "保存到Clipora"
//        titleLabel.font = UIFont.boldSystemFont(ofSize: 18)
//        titleLabel.textAlignment = .center
//        titleLabel.translatesAutoresizingMaskIntoConstraints = false
//        
//        contentLabel = UILabel()
//        contentLabel.text = "正在处理分享内容..."
//        contentLabel.font = UIFont.systemFont(ofSize: 14)
//        // 兼容iOS 13以下版本的文本颜色
//        if #available(iOS 13.0, *) {
//            contentLabel.textColor = UIColor.secondaryLabel
//        } else {
//            contentLabel.textColor = UIColor.gray
//        }
//        contentLabel.numberOfLines = 0
//        contentLabel.translatesAutoresizingMaskIntoConstraints = false
//        
//        saveButton = UIButton(type: .system)
//        saveButton.setTitle("保存", for: .normal)
//        saveButton.backgroundColor = UIColor.systemBlue
//        saveButton.setTitleColor(UIColor.white, for: .normal)
//        saveButton.layer.cornerRadius = 8
//        saveButton.translatesAutoresizingMaskIntoConstraints = false
//        saveButton.addTarget(self, action: #selector(saveButtonTapped), for: .touchUpInside)
//        
//        cancelButton = UIButton(type: .system)
//        cancelButton.setTitle("取消", for: .normal)
//        cancelButton.translatesAutoresizingMaskIntoConstraints = false
//        cancelButton.addTarget(self, action: #selector(cancelButtonTapped), for: .touchUpInside)
//        
//        // 添加到视图
//        view.addSubview(titleLabel)
//        view.addSubview(contentLabel)
//        view.addSubview(saveButton)
//        view.addSubview(cancelButton)
//        
        // 设置约束
//        NSLayoutConstraint.activate([
//            titleLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 20),
//            titleLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
//            titleLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
//            
//            contentLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 20),
//            contentLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
//            contentLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
//            
//            saveButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
//            saveButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
//            saveButton.bottomAnchor.constraint(equalTo: cancelButton.topAnchor, constant: -10),
//            saveButton.heightAnchor.constraint(equalToConstant: 44),
//            
//            cancelButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
//            cancelButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
//            cancelButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -20),
//            cancelButton.heightAnchor.constraint(equalToConstant: 44)
//        ])
//    }
    
//    private func processSharedContent() {
//        guard let extensionContext = extensionContext else { return }
//        
//        for item in extensionContext.inputItems {
//            guard let inputItem = item as? NSExtensionItem else { continue }
//            guard let attachments = inputItem.attachments else { continue }
//            
//            for attachment in attachments {
//                processAttachment(attachment)
//            }
//        }
//    }
    
//    private func processAttachment(_ attachment: NSItemProvider) {
//        // 处理URL - 使用MobileCoreServices常量
//        if attachment.hasItemConformingToTypeIdentifier(kUTTypeURL as String) {
//            attachment.loadItem(forTypeIdentifier: kUTTypeURL as String, options: nil) { [weak self] (url, error) in
//                DispatchQueue.main.async {
//                    if let url = url as? URL {
//                        self?.contentLabel.text = "网址：\(url.absoluteString)"
//                        self?.sharedData = [
//                            "type": "url",
//                            "content": url.absoluteString,
//                            "timestamp": Date().timeIntervalSince1970
//                        ]
//                    }
//                }
//            }
//        }
        // 处理文本
//        else if attachment.hasItemConformingToTypeIdentifier(kUTTypePlainText as String) {
//            attachment.loadItem(forTypeIdentifier: kUTTypePlainText as String, options: nil) { [weak self] (text, error) in
//                DispatchQueue.main.async {
//                    if let text = text as? String {
//                        self?.contentLabel.text = "文本：\(text.prefix(100))\(text.count > 100 ? "..." : "")"
//                        
//                        // 检查文本中是否包含URL
//                        let urlPattern = "https?://[^\\s]+"
//                        let urlRegex = try? NSRegularExpression(pattern: urlPattern, options: .caseInsensitive)
//                        let hasURL = urlRegex?.firstMatch(in: text, options: [], range: NSRange(location: 0, length: text.count)) != nil
//                        
//                        self?.sharedData = [
//                            "type": hasURL ? "url" : "text",
//                            "content": text,
//                            "timestamp": Date().timeIntervalSince1970
//                        ]
//                    }
//                }
//            }
//        }
        // 处理图片
//        else if attachment.hasItemConformingToTypeIdentifier(kUTTypeImage as String) {
//            attachment.loadItem(forTypeIdentifier: kUTTypeImage as String, options: nil) { [weak self] (image, error) in
//                DispatchQueue.main.async {
//                    self?.contentLabel.text = "图片内容"
//                    // 对于图片，我们需要获取文件路径或处理图片数据
//                    // 这里暂时只保存类型信息
//                    self?.sharedData = [
//                        "type": "image",
//                        "content": "图片数据", // 实际使用时需要保存图片文件路径或数据
//                        "timestamp": Date().timeIntervalSince1970
//                    ]
//                }
//            }
//        }
        // 处理网页
//        else if attachment.hasItemConformingToTypeIdentifier("public.url") {
//            attachment.loadItem(forTypeIdentifier: "public.url", options: nil) { [weak self] (url, error) in
//                DispatchQueue.main.async {
//                    if let url = url as? URL {
//                        self?.contentLabel.text = "网页：\(url.absoluteString)"
//                        self?.sharedData = [
//                            "type": "url",
//                            "content": url.absoluteString,
//                            "timestamp": Date().timeIntervalSince1970
//                        ]
//                    }
//                }
//            }
//        }
//    }
    
//    @objc private func saveButtonTapped() {
//        // 保存分享内容到App Group
//        saveToAppGroup()
//        
//        // 完成分享扩展
//        extensionContext?.completeRequest(returningItems: [], completionHandler: nil)
//    }
    
//    @objc private func cancelButtonTapped() {
//        extensionContext?.cancelRequest(withError: NSError(domain: "ShareExtension", code: 0, userInfo: [NSLocalizedDescriptionKey: "用户取消"]))
//    }
    
    // MARK: - App Group数据保存
    
//    private func saveToAppGroup() {
//        guard !sharedData.isEmpty else {
//            print("❌ 没有要保存的分享内容")
//            return
//        }
//        
//        guard let containerURL = FileManager.default.containerURL(forSecurityApplicationGroupIdentifier: appGroupId) else {
//            print("❌ 无法获取App Group容器路径")
//            return
//        }
        
//        let sharedDataURL = containerURL.appendingPathComponent("SharedData.json")
//        
//        do {
//            // 读取现有数据（如果存在）
//            var existingData: [[String: Any]] = []
//            if FileManager.default.fileExists(atPath: sharedDataURL.path) {
//                let existingDataJSON = try Data(contentsOf: sharedDataURL)
//                if let decoded = try JSONSerialization.jsonObject(with: existingDataJSON, options: []) as? [[String: Any]] {
//                    existingData = decoded
//                }
//            }
//            
//            // 添加新的分享数据
//            existingData.append(sharedData)
//            
//            // 保存更新后的数据
//            let updatedDataJSON = try JSONSerialization.data(withJSONObject: existingData, options: [])
//            try updatedDataJSON.write(to: sharedDataURL)
//            
//            print("✅ 分享内容已保存到App Group: \(sharedData)")
//            
//            // 通知主应用检查新数据（通过URL Scheme）
//            notifyMainApp()
//            
//        } catch {
//            print("❌ 保存分享内容到App Group失败: \(error)")
//        }
//    }
    
//    private func notifyMainApp() {
//        // 通过URL Scheme通知主应用有新的分享数据
//        let urlString = "ShareMedia-com.guanshangyun.clipora://shareExtension"
//        if let url = URL(string: urlString) {
//            // 在Share Extension中打开URL Scheme来通知主应用
//            var responder: UIResponder? = self
//            while responder != nil {
//                if let application = responder as? UIApplication {
//                    application.open(url, options: [:], completionHandler: nil)
//                    break
//                }
//                responder = responder?.next
//            }
//            
//            // 如果上面的方法不工作，尝试使用extensionContext
//            extensionContext?.open(url, completionHandler: { success in
//                print(success ? "✅ 成功通知主应用" : "❌ 通知主应用失败")
//            })
//        }
//    }
}
