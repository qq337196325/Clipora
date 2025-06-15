//
//  ShareViewController.swift
//  Clipora
//
//  Created by zouyougui on 2025/6/15.
//

import UIKit
import MobileCoreServices

class ShareViewController: UIViewController {
    
    private var titleLabel: UILabel!
    private var contentLabel: UILabel!
    private var saveButton: UIButton!
    private var cancelButton: UIButton!

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        processSharedContent()
    }

    private func setupUI() {
        // 兼容iOS 13以下版本的背景色
        if #available(iOS 13.0, *) {
            view.backgroundColor = UIColor.systemBackground
        } else {
            view.backgroundColor = UIColor.white
        }
        
        // 创建UI元素
        titleLabel = UILabel()
        titleLabel.text = "保存到Clipora"
        titleLabel.font = UIFont.boldSystemFont(ofSize: 18)
        titleLabel.textAlignment = .center
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        
        contentLabel = UILabel()
        contentLabel.text = "正在处理分享内容..."
        contentLabel.font = UIFont.systemFont(ofSize: 14)
        // 兼容iOS 13以下版本的文本颜色
        if #available(iOS 13.0, *) {
            contentLabel.textColor = UIColor.secondaryLabel
        } else {
            contentLabel.textColor = UIColor.gray
        }
        contentLabel.numberOfLines = 0
        contentLabel.translatesAutoresizingMaskIntoConstraints = false
        
        saveButton = UIButton(type: .system)
        saveButton.setTitle("保存", for: .normal)
        saveButton.backgroundColor = UIColor.systemBlue
        saveButton.setTitleColor(UIColor.white, for: .normal)
        saveButton.layer.cornerRadius = 8
        saveButton.translatesAutoresizingMaskIntoConstraints = false
        saveButton.addTarget(self, action: #selector(saveButtonTapped), for: .touchUpInside)
        
        cancelButton = UIButton(type: .system)
        cancelButton.setTitle("取消", for: .normal)
        cancelButton.translatesAutoresizingMaskIntoConstraints = false
        cancelButton.addTarget(self, action: #selector(cancelButtonTapped), for: .touchUpInside)
        
        // 添加到视图
        view.addSubview(titleLabel)
        view.addSubview(contentLabel)
        view.addSubview(saveButton)
        view.addSubview(cancelButton)
        
        // 设置约束
        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 20),
            titleLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            titleLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            
            contentLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 20),
            contentLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            contentLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            
            saveButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            saveButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            saveButton.bottomAnchor.constraint(equalTo: cancelButton.topAnchor, constant: -10),
            saveButton.heightAnchor.constraint(equalToConstant: 44),
            
            cancelButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            cancelButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            cancelButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -20),
            cancelButton.heightAnchor.constraint(equalToConstant: 44)
        ])
    }

    private func processSharedContent() {
        guard let extensionContext = extensionContext else { return }
        
        for item in extensionContext.inputItems {
            guard let inputItem = item as? NSExtensionItem else { continue }
            guard let attachments = inputItem.attachments else { continue }
            
            for attachment in attachments {
                processAttachment(attachment)
            }
        }
    }

    private func processAttachment(_ attachment: NSItemProvider) {
        // 处理URL - 使用MobileCoreServices常量
        if attachment.hasItemConformingToTypeIdentifier(kUTTypeURL as String) {
            attachment.loadItem(forTypeIdentifier: kUTTypeURL as String, options: nil) { [weak self] (url, error) in
                DispatchQueue.main.async {
                    if let url = url as? URL {
                        self?.contentLabel.text = "网址：\(url.absoluteString)"
                    }
                }
            }
        }
        // 处理文本
        else if attachment.hasItemConformingToTypeIdentifier(kUTTypePlainText as String) {
            attachment.loadItem(forTypeIdentifier: kUTTypePlainText as String, options: nil) { [weak self] (text, error) in
                DispatchQueue.main.async {
                    if let text = text as? String {
                        self?.contentLabel.text = "文本：\(text)"
                    }
                }
            }
        }
        // 处理图片
        else if attachment.hasItemConformingToTypeIdentifier(kUTTypeImage as String) {
            attachment.loadItem(forTypeIdentifier: kUTTypeImage as String, options: nil) { [weak self] (image, error) in
                DispatchQueue.main.async {
                    self?.contentLabel.text = "图片内容"
                }
            }
        }
        // 处理网页
        else if attachment.hasItemConformingToTypeIdentifier("public.url") {
            attachment.loadItem(forTypeIdentifier: "public.url", options: nil) { [weak self] (url, error) in
                DispatchQueue.main.async {
                    if let url = url as? URL {
                        self?.contentLabel.text = "网页：\(url.absoluteString)"
                    }
                }
            }
        }
    }

    @objc private func saveButtonTapped() {
        // 这里暂时只是关闭扩展，后续可以添加保存逻辑
        extensionContext?.completeRequest(returningItems: [], completionHandler: nil)
    }

    @objc private func cancelButtonTapped() {
        extensionContext?.cancelRequest(withError: NSError(domain: "ShareExtension", code: 0, userInfo: [NSLocalizedDescriptionKey: "用户取消"]))
    }
}
