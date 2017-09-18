import Foundation

import Foundation
import AsyncDisplayKit
import UIKit
import CoreStore

class ProductOptionsViewController: ASViewController<ProductOptionsNode> {
    
    var product: ProductEntity! {
        didSet {
            // todo: update interface
        }
    }
    
    convenience init() {
        self.init(node: ProductOptionsNode())
    }
}
