import Foundation

import Foundation
import AsyncDisplayKit
import UIKit
import CoreStore

struct ProductOptionsContext {
    var product: ProductEntity
    var selectedPrice: PriceEntity
    var count: Int
    var selectedOptions: [ProductOptionEntity]?
    var comment: String?
    
    init(product: ProductEntity, selectedPrice: PriceEntity) {
        self.init(product: product, selectedPrice: selectedPrice, count: 1)
    }
    
    init(product: ProductEntity, selectedPrice: PriceEntity, count: Int) {
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
        
        selectedOptions?.forEach {
            amount += $0.price.value
        }
        
        return PriceEntity.formattedPrice(value: amount, currencyLocale: currencyLocale)
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
        
        self.view.addGestureRecognizer(tapRecognizer)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        self.view.removeGestureRecognizer(tapRecognizer)
    }
    
    func handleSingleTap(recognizer: UITapGestureRecognizer) {
        self.view.endEditing(true)
    }
}

extension ProductOptionsViewController: ProductOptionsDelegate {
    func productOptionsDidUpdateCount(count: Int) {
        if count == 0 {
            dismiss(animated: true)
        }
    }

    func productOptionsDidSubmit() {
        // todo: add to cart
    }
}

extension ProductOptionsViewController: ProductOptionCellNodeDelegate {
    func productOptionsNodeDidCheck(node: ProductOptionCellNode, option: ProductOptionEntity) {
        guard context.selectedOptions?.filter({$0.serverId == option.serverId}).first == nil else { return }
        
        var currentOptions = context.selectedOptions ?? [ProductOptionEntity]()
        currentOptions.append(option)
        
        context.selectedOptions = currentOptions
        
        self.node.context = context
    }
    
    func productOptionsNodeDidUncheck(node: ProductOptionCellNode, option: ProductOptionEntity) {
        guard let index = context.selectedOptions?.index(where: {$0.serverId == option.serverId}) else { return }
        
        var currentOptions = context.selectedOptions!
        currentOptions.remove(at: index)
        
        context.selectedOptions = currentOptions
        
        self.node.context = context
    }
}

extension ProductOptionsViewController: ASTableDelegate, ASTableDataSource {
    func tableNode(_ tableNode: ASTableNode, numberOfRowsInSection section: Int) -> Int {
        return productMonitor?.object?.options?.count ?? 0
    }
    
    func tableNode(_ tableNode: ASTableNode, nodeBlockForRowAt indexPath: IndexPath) -> ASCellNodeBlock {
        guard let productOption = productMonitor?.object?.options?[indexPath.row] else {
            return { ASCellNode() }
        }
        
        return { [unowned self] _ in
            let cellNode = ProductOptionCellNode(productOption: productOption)
            cellNode.isChecked = self.context.selectedOptions?.filter({$0.serverId == productOption.serverId}).first != nil
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
