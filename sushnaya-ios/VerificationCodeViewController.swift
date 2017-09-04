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
    
    var verificationCode: String {
        set {
            verificationCodeTextNode.setTextWhileKeepingAttributes(text: newValue)
        }
        get {
            return verificationCodeTextNode.attributedText?.string ?? ""
        }
    }
    
    private var disableRightBarButtonDebouncer: Debouncer!
    
    init(phoneNumber: String) {
        self.phoneNumber = try! phoneNumberUtil.parse(phoneNumber, defaultRegion: "RU")
        self.verificationCodeNode = VerificationCodeNode(phoneNumber: try! phoneNumberUtil.format(self.phoneNumber, numberFormat: .INTERNATIONAL))
        super.init(node: ASTableNode())
        
        tableNode.delegate = self
        tableNode.dataSource = self
        tableNode.view.separatorStyle = .none
        tableNode.backgroundColor = UIColor.white
        
        disableRightBarButtonDebouncer = debounce {
            self.navigationItem.rightBarButtonItem?.isEnabled = false
        }
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
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        EventBus.onMainThread(self, name: RequestAuthenticationTokenEvent.name) { [unowned self] _ in
            self.disableRightBarButtonDebouncer.apply()
        }
        
        EventBus.onMainThread(self, name: DidRequestAuthenticationTokenEvent.name) { [unowned self] _ in
            self.disableRightBarButtonDebouncer.cancel()
            
            self.navigationItem.rightBarButtonItem?.isEnabled = true
        }
        
        EventBus.onMainThread(self, name: DidNotRequestAuthenticationTokenEvent.name) {[unowned self] notification in
            print((notification.object as! DidNotRequestAuthenticationTokenEvent).error)
            
            self.onInvalidCode(description: "Вы указали неправильный код.")
            
            self.disableRightBarButtonDebouncer.cancel()
            
            self.navigationItem.rightBarButtonItem?.isEnabled = true
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        startVerificationCodeEditing()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        verificationCodeTextNode.resignFirstResponder()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        
        EventBus.unregister(self)
    }
    
    func onNextButtonTapped() {
        guard !verificationCode.isEmpty else {
            onEmptyCode()
            return
        }
        
        let e154PhoneNumber = try! phoneNumberUtil.format(phoneNumber, numberFormat: .E164)
        
        RequestAuthenticationTokenEvent.fire(phoneNumber: e154PhoneNumber, code: verificationCode)
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
        let oldCode = verificationCode as NSString
        let newCode = oldCode.replacingCharacters(in: range, with: text).digits
        
        guard newCode.characters.count <= 10 else {
            return false
        }
        
        verificationCode = newCode
        
        return false
    }
}

