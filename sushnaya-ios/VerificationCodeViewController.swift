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

class VerificationCodeViewController: UIViewController, UITextFieldDelegate {
    var phoneNumber: NBPhoneNumber!
    
    @IBOutlet weak var promptLabel: UILabel!
    @IBOutlet weak var codeTextField: UITextField!
    
    private let phoneNumberUtil = NBPhoneNumberUtil()
    
    override func viewWillAppear(_ animated: Bool) {        
        super.viewWillAppear(animated)
        
        let formattedPhoneNumber = try? phoneNumberUtil.format(phoneNumber, numberFormat: .INTERNATIONAL)
        promptLabel.text = "На номер \(formattedPhoneNumber!) было отправлено SMS c кодом."
        
        codeTextField.becomeFirstResponder()
    }
    
    @IBAction func nextButtonTapped(_ sender: Any) {
        guard isValidCode(code: codeTextField.text ?? "") else {
            onInvalidCode()
            return
        }
        
        presentVerificationCodeController()
    }
    
    private func isValidCode(code: String) -> Bool {
        // todo: verify the code
        
        return code.characters.count == 5
    }
    
    private func onInvalidCode() {
        guard (codeTextField.pop_animation(forKey: "shake") == nil) else {
            return
        }
        
        let shake = POPSpringAnimation(propertyNamed: kPOPLayerPositionX)
        shake?.springBounciness = 20
        shake?.velocity = NSNumber(value: 2000)
        
        codeTextField.pop_add(shake, forKey: "shake")
    }
    
    private func presentVerificationCodeController() {
        let controller = storyboard?.instantiateViewController(withIdentifier: "Categories") as! CategoriesViewContoller
        
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
