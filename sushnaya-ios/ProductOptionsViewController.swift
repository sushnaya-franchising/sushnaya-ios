import Foundation

import Foundation
import AsyncDisplayKit
import UIKit
import CoreStore

class ProductOptionsViewController: ASViewController<ProductOptionsNode> {
    
    var product: ProductEntity! {
        didSet {
            guard product != nil else { return }
            
            productMonitor = CoreStore.monitorObject(product)
            productMonitor?.addObserver(self)
        }
    }
    
    fileprivate var productMonitor: ObjectMonitor<ProductEntity>?
    
    convenience init() {
        self.init(node: ProductOptionsNode())
    }
    
    deinit {
        productMonitor?.removeObserver(self)
    }
}

extension ProductOptionsViewController: ObjectObserver {
    func objectMonitor(_ monitor: ObjectMonitor<ProductEntity>, willUpdateObject object: ProductEntity) {
        // nop
    }
    
    func objectMonitor(_ monitor: ObjectMonitor<ProductEntity>, didUpdateObject object: ProductEntity, changedPersistentKeys: Set<KeyPath>) {
        self.node.product = productMonitor?.object
    }
    
    
    func objectMonitor(_ monitor: ObjectMonitor<ProductEntity>, didDeleteObject object: ProductEntity) {
        self.dismiss(animated: true)
    }
}
