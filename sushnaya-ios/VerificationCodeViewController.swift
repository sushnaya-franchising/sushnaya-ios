//
//  CodeConfirmationViewController.swift
//  sushnaya-ios
//
//  Created by Igor Kurylenko on 3/20/17.
//  Copyright © 2017 igor kurilenko. All rights reserved.
//

import Foundation
import UIKit

class VerificationCodeViewController: UIViewController {
    var phoneNumber: String?
    
    @IBOutlet weak var promptLabel: UILabel!
    @IBOutlet weak var codeTextField: UITextField!
    
    override func viewWillAppear(_ animated: Bool) {        
        super.viewWillAppear(animated)
        
        promptLabel.text = "На номер \(phoneNumber!) было отправлено SMS c кодом."
        
        codeTextField.becomeFirstResponder()
    }        
}
