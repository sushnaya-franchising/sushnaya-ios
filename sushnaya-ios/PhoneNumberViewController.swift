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
import PromiseKit

class PhoneNumberViewController: UIViewController, UITextFieldDelegate {
    
    @IBOutlet weak var nextBarButtonItem: UIBarButtonItem!
    @IBOutlet weak var phoneNumberTextField: UITextField!
    @IBOutlet weak var termsOfUseButton: UIButton!
    
    private let phoneNumberUtil = NBPhoneNumberUtil()
    private let phoneNumberAsYouType = NBAsYouTypeFormatter(regionCode: "RU")
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationController?.setNavigationBarHidden(false, animated: true)
        navigationItem.title = ""
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        phoneNumberTextField.becomeFirstResponder()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        phoneNumberTextField.resignFirstResponder()
    }
    
    @IBAction func nextButtonTapped(_ sender: Any) {
        let phoneNumber = try? phoneNumberUtil.parse(phoneNumberTextField.text, defaultRegion: "RU")
        
        guard phoneNumberUtil.isValidNumber(phoneNumber) else {
            onInvalidPhoneNumber()
            return
        }
        
        let e154PhoneNumber = try! phoneNumberUtil.format(phoneNumber, numberFormat: .E164)
        
        let onNetworkActivity = Debouncer {
            UIApplication.shared.isNetworkActivityIndicatorVisible = true
            self.nextBarButtonItem.isEnabled = false
            self.termsOfUseButton.isEnabled = false
            
        }.onCancel {
            UIApplication.shared.isNetworkActivityIndicatorVisible = false
            self.nextBarButtonItem.isEnabled = true
            self.termsOfUseButton.isEnabled = true
        }
        
        firstly {
            onNetworkActivity.apply()
            
            return Authentication.requestSMSWithVerificationCode(phoneNumber: e154PhoneNumber)
        
        }.then { () -> () in
            self.pushVerificationCodeController(phoneNumber: phoneNumber!)
            
        }.always { () -> () in
            onNetworkActivity.cancel()
            
        }.catch { error in
            switch error {
                
            case AuthenticationError.invalidPhoneNumber:
                self.onInvalidPhoneNumber()
                
            default:
                // todo: handle other erorrs
                self.onInvalidPhoneNumber()
                break
            }
        }
    }
    
    private func pushVerificationCodeController(phoneNumber: NBPhoneNumber) {
        let controller = storyboard?.instantiateViewController(withIdentifier: "VerificationCode") as! VerificationCodeViewController
        controller.phoneNumber = phoneNumber
        navigationController?.pushViewController(controller, animated: true)
    }
    
    private func onInvalidPhoneNumber() {
        guard (phoneNumberTextField.pop_animation(forKey: "shake") == nil) else {
            return
        }
        
        let shake = POPSpringAnimation(propertyNamed: kPOPLayerPositionX)
        shake?.springBounciness = 20
        shake?.velocity = NSNumber(value: 1500)
        
        phoneNumberTextField.pop_add(shake, forKey: "shake")
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        let countryPrefix = "+7 "
        let oldText = (phoneNumberTextField.text!) as NSString
        let newText = oldText.replacingCharacters(in: range, with: string)
        
        guard newText.hasPrefix(countryPrefix) else {
            return false
        }
        
        let numberDigits = newText.replacingOccurrences(of: countryPrefix, with: "").digits
        
        guard numberDigits.characters.count <= 10 else {
            return false
        }
        
        let phoneNumberAsYouType = NBAsYouTypeFormatter(regionCode: "RU")!
        phoneNumberTextField.text = countryPrefix + phoneNumberAsYouType.inputString(numberDigits)
        
        return false
    }
}
