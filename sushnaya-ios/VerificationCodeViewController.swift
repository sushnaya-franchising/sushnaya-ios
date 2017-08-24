//
//  VerificationCodeNodeController.swift
//  Food
//
//  Created by Igor Kurylenko on 3/27/17.
//  Copyright © 2017 igor kurilenko. All rights reserved.
//

import Foundation
import AsyncDisplayKit
import libPhoneNumber_iOS
import pop
import PromiseKit

class VerificationCodeViewController: ASViewController<ASTableNode> {
    let phoneNumberUtil = NBPhoneNumberUtil()
    let phoneNumber: NBPhoneNumber
    let verificationCodeNode:VerificationCodeNode
    
    var tableNode: ASTableNode {
        return node
    }
    
    var verificationCodeTextNode:ASEditableTextNode {
        return verificationCodeNode.textNode
    }
    
    var verificationCodeText: String {
        set {
            verificationCodeTextNode.setTextWhileKeepingAttributes(text: newValue)
        }
        get {
            return verificationCodeTextNode.attributedText?.string ?? ""
        }
    }
    
    init(phoneNumber: NBPhoneNumber) {
        self.phoneNumber = phoneNumber        
        self.verificationCodeNode = VerificationCodeNode(phoneNumber: try! phoneNumberUtil.format(phoneNumber, numberFormat: .INTERNATIONAL))
        super.init(node: ASTableNode())
        
        tableNode.delegate = self
        tableNode.dataSource = self
        tableNode.view.separatorStyle = .none
        tableNode.backgroundColor = UIColor.white
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("storyboards are not supported")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        verificationCodeTextNode.delegate = self
        setupNavbar()
    }
    
    private func setupNavbar() {
        let nextBarButtonItem = UIBarButtonItem(title: "Дальше", style: .plain,target: self,action: #selector(onNextButtonTapped))
        navigationItem.setRightBarButton(nextBarButtonItem, animated: false)        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        startVerificationCodeEditing()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        verificationCodeTextNode.resignFirstResponder()
    }
    
    func onNextButtonTapped() {
        guard !verificationCodeText.isEmpty else {
            onEmptyCode()
            return
        }
        
        let e154PhoneNumber = try! phoneNumberUtil.format(phoneNumber, numberFormat: .E164)
        
        let onNetworkActivity = debounce {
            UIApplication.shared.isNetworkActivityIndicatorVisible = true
            self.navigationItem.rightBarButtonItem?.isEnabled = false
            
        }.onCancel {
            UIApplication.shared.isNetworkActivityIndicatorVisible = false
            self.navigationItem.rightBarButtonItem?.isEnabled = true
        }
        
        firstly {
            onNetworkActivity.apply()
            
            return FoodServiceAuth.requestAuthToken(phoneNumber: e154PhoneNumber, code: verificationCodeText)
            
        }.then { (authToken: String) -> () in
            DidAuthenticateEvent.fire(authToken: authToken)
                
        }.always { () -> () in
            onNetworkActivity.cancel()
                
        }.catch { error in
            // todo: handle all error cases
            self.onInvalidCode(description: "Вы указали неправильный код.")
            debugPrint(error.localizedDescription)
        }
    }
    
    private func onEmptyCode() {
        shakeCodeTextField()
    }
    
    private func onInvalidCode(description: String) {
        shakeCodeTextField()
        
        // todo: update label message with pop animation
        
        // todo: reveal resend button
    }
    
    private func shakeCodeTextField() {
        guard verificationCodeTextNode.pop_animation(forKey: "shake") == nil else {
            return
        }
        
        let shake = POPSpringAnimation(propertyNamed: kPOPLayerPositionX)
        shake?.springBounciness = 20
        shake?.velocity = NSNumber(value: 1500)
        
        verificationCodeTextNode.pop_add(shake, forKey: "shake")
    }
    
    private func startVerificationCodeEditing() {
        let phoneNumberTextView = verificationCodeTextNode.textView
        phoneNumberTextView.becomeFirstResponder()
        
        let newPosition = phoneNumberTextView.endOfDocument
        phoneNumberTextView.selectedTextRange = phoneNumberTextView.textRange(from: newPosition, to: newPosition)
    }
}

extension VerificationCodeViewController: ASTableDataSource, ASTableDelegate {
    func tableNode(_ tableNode: ASTableNode, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func tableNode(_ tableNode: ASTableNode, nodeForRowAt indexPath: IndexPath) -> ASCellNode {
        return verificationCodeNode
    }
}

extension VerificationCodeViewController: ASEditableTextNodeDelegate {
    func editableTextNode(_ editableTextNode: ASEditableTextNode, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        let oldText = verificationCodeText as NSString
        let newText = oldText.replacingCharacters(in: range, with: text).digits
        
        guard newText.characters.count <= 10 else {
            return false
        }
        
        verificationCodeText = newText
        
        return false
    }
}

