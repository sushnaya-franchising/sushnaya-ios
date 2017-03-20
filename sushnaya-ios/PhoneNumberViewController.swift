//
//  PhoneNumberViewController.swift
//  sushnaya-ios
//
//  Created by Igor Kurylenko on 3/19/17.
//  Copyright © 2017 igor kurilenko. All rights reserved.
//

import Foundation
import UIKit


class PhoneNumberViewController: UIViewController {
    
    @IBOutlet weak var countryCodeTextField: UITextField!
    @IBOutlet weak var numberTextField: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationController?.setNavigationBarHidden(false, animated: true)                
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        numberTextField.becomeFirstResponder()                
    }
    
    @IBAction func nextButtonTapped(_ sender: Any) {
        let controller = storyboard?.instantiateViewController(withIdentifier: "VerificationCode") as! VerificationCodeViewController
        
        controller.phoneNumber = "+7 (999) 790-10-88"
        
        navigationController?.pushViewController(controller, animated: true)
    }
    
    // todo: phone number formatter        
}
