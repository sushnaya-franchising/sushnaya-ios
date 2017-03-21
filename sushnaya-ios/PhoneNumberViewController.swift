//
//  PhoneNumberViewController.swift
//  sushnaya-ios
//
//  Created by Igor Kurylenko on 3/19/17.
//  Copyright © 2017 igor kurilenko. All rights reserved.
//

import Foundation
import UIKit
import libPhoneNumber_iOS
import pop
import AVFoundation

class PhoneNumberViewController: UIViewController, UITextFieldDelegate {
    
    @IBOutlet weak var phoneNumberContainerView: UIView!
    @IBOutlet weak var countryCodeTextField: UITextField!
    @IBOutlet weak var numberTextField: UITextField!
    
    private let phoneNumberUtil = NBPhoneNumberUtil()
    private let phoneNumberAsYouType = NBAsYouTypeFormatter(regionCode: "RU")
    
    @IBAction func coverButtonTouchUpInside(_ sender: Any) {
        numberTextField.becomeFirstResponder()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationController?.setNavigationBarHidden(false, animated: true)
        navigationItem.title = ""
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        numberTextField.becomeFirstResponder()
    }
    
    @IBAction func nextButtonTapped(_ sender: Any) {
        let phoneNumber = try? phoneNumberUtil.parse(numberTextField.text, defaultRegion: "RU")
        
        guard phoneNumberUtil.isValidNumber(phoneNumber) else {
            onInvalidPhoneNumber()
            return
        }
        
        // todo: request sms with verification code
        
        pushVerificationCodeController(phoneNumber: phoneNumber!)
    }
    
    private func pushVerificationCodeController(phoneNumber: NBPhoneNumber) {
        let controller = storyboard?.instantiateViewController(withIdentifier: "VerificationCode") as! VerificationCodeViewController
        controller.phoneNumber = phoneNumber
        navigationController?.pushViewController(controller, animated: true)
    }
    
    private func onInvalidPhoneNumber() {
        guard (phoneNumberContainerView.pop_animation(forKey: "shake") == nil) else {
            return
        }
        
        let shake = POPSpringAnimation(propertyNamed: kPOPLayerPositionX)
        shake?.springBounciness = 20
        shake?.velocity = NSNumber(value: 2000)
        
        phoneNumberContainerView.pop_add(shake, forKey: "shake")
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        let oldText = (numberTextField.text ?? "") as NSString
        let newText = oldText.replacingCharacters(in: range, with: string).digits
        
        guard newText.characters.count <= 10 else {
            return false
        }
        
        let phoneNumberAsYouType = NBAsYouTypeFormatter(regionCode: "RU")
        numberTextField.text = phoneNumberAsYouType?.inputString(newText)
        
        return false
    }
}
