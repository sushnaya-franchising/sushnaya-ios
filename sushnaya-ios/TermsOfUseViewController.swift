//
//  TermsOfUseNodeController.swift
//  Food
//
//  Created by Igor Kurylenko on 3/27/17.
//  Copyright © 2017 igor kurilenko. All rights reserved.
//

import Foundation
import AsyncDisplayKit

class TermsOfUseViewController: ASViewController<ASDisplayNode> {

    lazy var termsOfUseFilePath: String? = {
        return Bundle.main.path(forResource: "TermsOfUse", ofType: "html")
    }()
    
    lazy var termsOfUseUrl:URL? = {
        guard let path = self.termsOfUseFilePath else { return nil }
        
        return  URL(fileURLWithPath: path)
    }()
    
    var activityIndicator: UIActivityIndicatorView?
    var webView: UIWebView?
    
    init() {
        //super.init(node: TermsOfUseNode())
        super.init(node: ASDisplayNode())
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupWebView()
        
        setupActivityIndicator()
        
        setupToolbar()
        
        fetchTermsOfUse()
    }
    
    private func setupActivityIndicator() {
        let activityIndicator = UIActivityIndicatorView(activityIndicatorStyle: .gray)
        self.activityIndicator = activityIndicator
        let bounds = self.node.frame
        var refreshRect = activityIndicator.frame
        refreshRect.origin = CGPoint(x: (bounds.size.width - activityIndicator.frame.size.width) / 2.0, y: (bounds.size.height - activityIndicator.frame.size.height) / 2.0)
        activityIndicator.frame = refreshRect
        
        self.node.view.addSubview(activityIndicator)
    }
    
    private func setupWebView() {
        let webView = UIWebView(frame: self.node.frame)
        webView.delegate = self
        self.webView = webView
        
        self.node.view.addSubview(webView)
    }
    
    private func setupToolbar() {
        let toolbar = UIToolbar(frame: CGRect(x: 0, y: self.view.frame.size.height - 44, width: self.view.frame.size.width, height: 44))
        toolbar.items = [
            UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.flexibleSpace, target: self, action: nil),
            UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.done, target: self, action: #selector(done)),
            UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.flexibleSpace, target: self, action: nil)
        ]
        
        self.node.view.addSubview(toolbar)
    }
    
    private func fetchTermsOfUse() {
        if let url = termsOfUseUrl {
            webView?.loadRequest(URLRequest(url: url))
            
        }else {
            NSLog("Terms of Use file not found")
        }
    }
    
    func done() {
        self.dismiss(animated: true, completion: nil)
    }
}

extension TermsOfUseViewController: UIWebViewDelegate {
    func webViewDidStartLoad(_ webView: UIWebView) {
        activityIndicator?.startAnimating()
    }
    
    func webViewDidFinishLoad(_ webView: UIWebView) {
        activityIndicator?.stopAnimating()
    }
}
