import Foundation
import AsyncDisplayKit
import libPhoneNumber_iOS
import pop
import PromiseKit

class PhoneNumberViewController: ASViewController<ASTableNode> {
    
    lazy var phoneNumberUtil = NBPhoneNumberUtil()
    lazy var phoneNumberNode = PhoneNumberNode()
    
    var phoneNumberTextNode: ASEditableTextNode {
        return phoneNumberNode.textNode
    }
    
    var phoneNumberText: String {
        set{
            phoneNumberTextNode.setTextWhileKeepingAttributes(text: newValue)
        }
        get{
            return phoneNumberTextNode.attributedText?.string ?? ""
        }
    }
    
    override var preferredStatusBarUpdateAnimation: UIStatusBarAnimation {
        return UIStatusBarAnimation.fade
    }
    
    var tableNode: ASTableNode {
        return node
    }
    
    private var disableRightBarButtonDebouncer: Debouncer!
    
    init() {
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
        
        setupPhoneNumberNode()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        setupNavbar()
        
        EventBus.onMainThread(self, name: RequestSMSWithVerificationCodeEvent.name) { [unowned self] _ in
            self.disableRightBarButtonDebouncer.apply()
        }
        
        EventBus.onMainThread(self, name: DidRequestSMSWithVerificationCodeEvent.name) { [unowned self] notification in
            let phoneNumber = (notification.object as! DidRequestSMSWithVerificationCodeEvent).phoneNumber
            
            self.disableRightBarButtonDebouncer.cancel()
            
            self.navigationItem.rightBarButtonItem?.isEnabled = true
            
            self.pushVerificationCodeController(phoneNumber: phoneNumber)
        }
        
        EventBus.onMainThread(self, name: DidNotRequestSMSWithVerificationCodeEvent.name) {[unowned self] notification in
            print((notification.object as! DidNotRequestSMSWithVerificationCodeEvent).error)
            
            self.onInvalidPhoneNumber()
            
            self.disableRightBarButtonDebouncer.cancel()
            
            self.navigationItem.rightBarButtonItem?.isEnabled = true
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        startPhoneNumberEditing()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        phoneNumberTextNode.textView.resignFirstResponder()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        EventBus.unregister(self)
    }
    
    private func setupPhoneNumberNode() {
        phoneNumberTextNode.delegate = self
        phoneNumberNode.termsOfUseButton.addTarget(self, action: #selector(onTermsOfUseButtonTapped), forControlEvents: .touchUpInside)
    }
    
    private func setupNavbar() {        
        let nextBarButtonItem = UIBarButtonItem(title: "Дальше", style: .plain,target: self,action: #selector(onNextButtonTapped))
        navigationItem.setRightBarButton(nextBarButtonItem, animated: false)
        navigationController?.setNavigationBarHidden(false, animated: true)
        navigationItem.title = EmptyString
    }
    
    private func startPhoneNumberEditing() {
        let phoneNumberTextView = phoneNumberTextNode.textView
        phoneNumberTextView.becomeFirstResponder()
        // place cursor at the end of text
        let newPosition = phoneNumberTextView.endOfDocument
        phoneNumberTextView.selectedTextRange = phoneNumberTextView.textRange(from: newPosition, to: newPosition)
    }
    
    func onNextButtonTapped() {
        let phoneNumber = try? phoneNumberUtil.parse(phoneNumberText, defaultRegion: "RU")
        
        guard phoneNumberUtil.isValidNumber(phoneNumber) else {
            onInvalidPhoneNumber()
            return
        }
        
        let e154PhoneNumber = try! phoneNumberUtil.format(phoneNumber, numberFormat: .E164)                
        
        RequestSMSWithVerificationCodeEvent.fire(phoneNumber: e154PhoneNumber)
    }
    
    private func pushVerificationCodeController(phoneNumber: String) {
        let verificationCodeVC = VerificationCodeViewController(phoneNumber: phoneNumber)
        
        navigationController?.pushViewController(verificationCodeVC, animated: true)
    }
    
    private func onInvalidPhoneNumber() {
        guard (phoneNumberTextNode.pop_animation(forKey: "shake") == nil) else {
            return
        }
        
        let shake = POPSpringAnimation(propertyNamed: kPOPLayerPositionX)
        shake?.springBounciness = 20
        shake?.velocity = NSNumber(value: 1500)
        
        phoneNumberTextNode.pop_add(shake, forKey: "shake")
    }
    
    func onTermsOfUseButtonTapped() {
        let termsOfUserVC = TermsOfUseViewController()
        
        navigationController?.present(termsOfUserVC, animated: true, completion: nil)
    }
}

extension PhoneNumberViewController: ASTableDataSource, ASTableDelegate {
    func tableNode(_ tableNode: ASTableNode, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func tableNode(_ tableNode: ASTableNode, nodeForRowAt indexPath: IndexPath) -> ASCellNode {
        return phoneNumberNode
    }
}

extension PhoneNumberViewController: ASEditableTextNodeDelegate {
    func editableTextNode(_ editableTextNode: ASEditableTextNode, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        let countryPrefix = "+7 "
        let oldText = phoneNumberText as NSString
        let newText = oldText.replacingCharacters(in: range, with: text)
        
        guard newText.hasPrefix(countryPrefix) else {
            return false
        }
        
        let numberDigits = newText.replacingOccurrences(of: countryPrefix, with: "").digits
        
        guard numberDigits.characters.count <= 10 else {
            return false
        }
        
        let phoneNumberAsYouType = NBAsYouTypeFormatter(regionCode: "RU")!
        phoneNumberText = countryPrefix + phoneNumberAsYouType.inputString(numberDigits)
        
        return false
    }
}










