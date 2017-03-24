//
//  CodeConfirmationViewController.swift
//  sushnaya-ios
//
//  Created by Igor Kurylenko on 3/20/17.
//  Copyright © 2017 igor kurilenko. All rights reserved.
//

import Foundation
import UIKit
import libPhoneNumber_iOS
import pop
import PromiseKit

class VerificationCodeViewController: UIViewController, UITextFieldDelegate {
    var phoneNumber: NBPhoneNumber!
    
    @IBOutlet weak var promptLabel: UILabel!
    @IBOutlet weak var codeTextField: UITextField!
    @IBOutlet weak var nextBarButtonItem: UIBarButtonItem!
    
    private let phoneNumberUtil = NBPhoneNumberUtil()
    
    override func viewWillAppear(_ animated: Bool) {        
        super.viewWillAppear(animated)
                        
        codeTextField.becomeFirstResponder()
    }
    
    private func configurePromptLabel() {
        let formattedPhoneNumber = try? phoneNumberUtil.format(phoneNumber, numberFormat: .INTERNATIONAL)
        promptLabel.text = "На номер \(formattedPhoneNumber!) было отправлено SMS c кодом."
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        codeTextField.resignFirstResponder()
    }
    
    @IBAction func nextButtonTapped(_ sender: Any) {
        guard !(codeTextField.text?.isEmpty ?? true) else {
            onEmptyCode()
            return
        }
        
        let onNetworkActivity = Debouncer {
            UIApplication.shared.isNetworkActivityIndicatorVisible = true
            self.nextBarButtonItem.isEnabled = false
            
        }.onCancel {
            UIApplication.shared.isNetworkActivityIndicatorVisible = false
            self.nextBarButtonItem.isEnabled = true
        }
        
        firstly {
            onNetworkActivity.apply()
            
            return API.requestAuthToken(code: codeTextField.text!)
            
        }.then { (authToken: String) -> () in
            self.app.userSession.authToken = authToken
            
            self.app.changeRootViewController(withIdentifier: "Entry")
            
        }.always { () -> () in
            onNetworkActivity.cancel()
        
        }.catch { error in
            switch error {
            case APIError.invalidVerificationCode:
                self.onInvalidCode(description: "Вы указали неправильный код.")
                
            case APIChatError.connectionError(let reason):
                debugPrint("APIChat connection error: \(reason)")
                // todo: reconnect APIChat
                
            default:
                // todo: handle open api chat error
                debugPrint(error.localizedDescription)
                // todo: show death screen
            }
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
        guard codeTextField.pop_animation(forKey: "shake") == nil else {
            return
        }
        
        let shake = POPSpringAnimation(propertyNamed: kPOPLayerPositionX)
        shake?.springBounciness = 20
        shake?.velocity = NSNumber(value: 1500)
        
        codeTextField.pop_add(shake, forKey: "shake")
    }
    
    private func presentLocalitiesViewController() {
        let controller = storyboard?.instantiateViewController(withIdentifier: "Localities") as! LocalitiesViewController
        
        present(controller, animated: true, completion: nil)
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        let oldText = (codeTextField.text ?? "") as NSString
        let newText = oldText.replacingCharacters(in: range, with: string).digits
        
        guard newText.characters.count <= 10 else {
            return false
        }
        
        codeTextField.text = newText
        
        return false
    }
}
