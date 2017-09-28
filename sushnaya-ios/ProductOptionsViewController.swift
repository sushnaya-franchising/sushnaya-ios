import Foundation

import Foundation
import AsyncDisplayKit
import UIKit
import CoreStore

struct ProductOptionsContext {
    var product: ProductEntity
    var selectedPrice: ProductPriceEntity
    var count: Int
    var selectedOptionPrices: [ProductOptionEntity : Set<ProductOptionPriceEntity>]?
    var comment: String?
    
    init(product: ProductEntity, selectedPrice: ProductPriceEntity) {
        self.init(product: product, selectedPrice: selectedPrice, count: 1)
    }
    
    init(product: ProductEntity, selectedPrice: ProductPriceEntity, count: Int) {
        self.product = product
        self.selectedPrice = selectedPrice
        self.count = count
    }
    
    func clone(withProduct product: ProductEntity) -> ProductOptionsContext {
        return ProductOptionsContext(product: product, selectedPrice: selectedPrice, count: count)
    }
    
    var formattedSumPrice: String {
        let currencyLocale = selectedPrice.currencyLocale
        var amount = selectedPrice.value
        
        selectedOptionPrices?.values.forEach {
            $0.forEach {
                amount += $0.value
            }
        }
        
        return PriceEntity.formattedPrice(value: amount * Double(count), currencyLocale: currencyLocale)
    }
}

class ProductOptionsViewController: ASViewController<ProductOptionsNode> {
    
    var context: ProductOptionsContext! {
        didSet {
            guard context != nil else { return }
            
            node.context = context
            
            productMonitor = CoreStore.monitorObject(context.product)
            productMonitor?.addObserver(self)
            node.tableNode.reloadData()
        }
    }
    
    fileprivate var productMonitor: ObjectMonitor<ProductEntity>?
    fileprivate var tapRecognizer: UITapGestureRecognizer!
    
    convenience init() {
        self.init(node: ProductOptionsNode())
        
        node.delegate = self
        node.tableNode.delegate = self
        node.tableNode.dataSource = self
        
        tapRecognizer = UITapGestureRecognizer(target: self, action: #selector(handleSingleTap(recognizer:)))
        tapRecognizer.numberOfTapsRequired = 1
    }
    
    deinit {
        productMonitor?.removeObserver(self)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        subscribeToKeyboardNotifications()
        
        self.view.addGestureRecognizer(tapRecognizer)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        unsubscribeFromKeyboardNotifications()
        
        self.view.removeGestureRecognizer(tapRecognizer)
    }
    
    func handleSingleTap(recognizer: UITapGestureRecognizer) {
        self.view.endEditing(true)
    }
}

extension ProductOptionsViewController: ProductOptionsDelegate {
    func productOptionsDidUpdateCount(count: Int) {
        guard count > 0 else {
            return dismiss(animated: true)
        }
        
        context.count = count
    }
    
    func productOptionsDidSubmit() {
        // todo: add to cart
    }
}

extension ProductOptionsViewController: ProductOptionCellNodeDelegate {
    func productOptionsNodeDidCheck(option: ProductOptionEntity, withPrice price: ProductOptionPriceEntity) {
        var selectedOptionPrices = context.selectedOptionPrices ?? [ProductOptionEntity: Set<ProductOptionPriceEntity>]()
        var selectedPrices = selectedOptionPrices[option] ?? Set<ProductOptionPriceEntity>()
        
        selectedPrices.insert(price)
        selectedOptionPrices[option] = selectedPrices
        
        context.selectedOptionPrices = selectedOptionPrices
    }
    
    func productOptionsNodeDidUncheck(option: ProductOptionEntity, withPrice price: ProductOptionPriceEntity) {
        guard var selectedOptionPrices = context.selectedOptionPrices,
            var selectedPrices = selectedOptionPrices[option] else { return }
        
        selectedPrices.remove(price)
        selectedOptionPrices[option] = selectedPrices
        
        context.selectedOptionPrices = selectedOptionPrices
    }
}

extension ProductOptionsViewController: ASTableDelegate, ASTableDataSource {
    func tableNode(_ tableNode: ASTableNode, numberOfRowsInSection section: Int) -> Int {
        return productMonitor?.object?.options?.count ?? 0
    }
    
    func tableNode(_ tableNode: ASTableNode, nodeBlockForRowAt indexPath: IndexPath) -> ASCellNodeBlock {
        guard let option = productMonitor?.object?.options?[indexPath.row] else {
            return { ASCellNode() }
        }
        
        let selectedPrices = context.selectedOptionPrices?[option]

        return { [unowned self] _ in
            let cellNode = ProductOptionCellNode(option: option, selectedPrices: selectedPrices)
            cellNode.delegate = self

            return cellNode
        }
    }
}

extension ProductOptionsViewController: ObjectObserver {
    func objectMonitor(_ monitor: ObjectMonitor<ProductEntity>, willUpdateObject object: ProductEntity) {
        // nop
    }
    
    func objectMonitor(_ monitor: ObjectMonitor<ProductEntity>, didUpdateObject object: ProductEntity, changedPersistentKeys: Set<RawKeyPath>) {
        guard let product = productMonitor!.object else { return }
        
        self.node.context = context.clone(withProduct: product)
        self.node.tableNode.reloadData()
    }
    
    
    func objectMonitor(_ monitor: ObjectMonitor<ProductEntity>, didDeleteObject object: ProductEntity) {
        self.dismiss(animated: true)
    }
}

extension ProductOptionsViewController {
    func subscribeToKeyboardNotifications() {
        notificationCenter.addObserver(self, selector: #selector(keyboardWillShow(notification:)),
                                       name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        
        notificationCenter.addObserver(self, selector: #selector(keyboardWillHide(notification:)),
                                       name: NSNotification.Name.UIKeyboardWillHide, object: nil)
    }
    
    func unsubscribeFromKeyboardNotifications() {
        notificationCenter.removeObserver(self, name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        
        notificationCenter.removeObserver(self, name: NSNotification.Name.UIKeyboardWillHide, object: nil)
    }
    
    func keyboardWillShow(notification: NSNotification) {
        let keyboardHeight = getKeyboardHeight(notification: notification)
        
        node.contentNode.toolbarOffsetBottom = keyboardHeight
        
        let frame = node.toolbarNode.frame.offsetBy(dx: 0, dy: -keyboardHeight)
        node.toolbarNode.frame = frame
    }
    
    func keyboardWillHide(notification: NSNotification) {
        let keyboardHeight = getKeyboardHeight(notification: notification)
        
        node.contentNode.toolbarOffsetBottom = 0
        
        let frame = node.toolbarNode.frame.offsetBy(dx: 0, dy: keyboardHeight)
        node.toolbarNode.frame = frame
    }
    
    func getKeyboardHeight(notification: NSNotification) -> CGFloat {
        let userInfo = notification.userInfo
        let keyboardSize = userInfo![UIKeyboardFrameEndUserInfoKey] as! NSValue
        
        return keyboardSize.cgRectValue.height
    }
}

