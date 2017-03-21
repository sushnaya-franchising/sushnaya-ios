//
//  TermsOfServiceViewController.swift
//  sushnaya-ios
//
//  Created by Igor Kurylenko on 3/20/17.
//  Copyright © 2017 igor kurilenko. All rights reserved.
//

import Foundation
import UIKit

class TermsOfUseViewController: UIViewController {
    
    @IBOutlet weak var webView: UIWebView!    
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    lazy var termsOfUseFilePath: String? = {
        return Bundle.main.path(forResource: "TermsOfUse", ofType: "html")
    }()
    
    lazy var termsOfUseUrl:URL? = {
        guard let path = self.termsOfUseFilePath else { return nil }
        
        return  URL(fileURLWithPath: path)
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let url = termsOfUseUrl {
            webView.loadRequest(URLRequest(url: url))
            
        }else {
            NSLog("Terms of Use file not found")
        }
    }
    
    @IBAction func doneButtonTapped(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
}

extension TermsOfUseViewController: UIWebViewDelegate {
    func webViewDidStartLoad(_ webView: UIWebView) {
        activityIndicator.isHidden = false
        webView.isHidden = true
    }
    
    func webViewDidFinishLoad(_ webView: UIWebView) {
        activityIndicator.isHidden = true
        webView.isHidden = false
    }
}
