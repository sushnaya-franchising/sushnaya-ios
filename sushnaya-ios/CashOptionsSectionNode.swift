import Foundation
import AsyncDisplayKit

class CashOptionsSectionNode: ASDisplayNode {
    
    let currencyLocale = "ru_RU" // todo: move selected currency locale to user settings
    
    fileprivate let titleTextNode = ASTextNode()
    fileprivate let collectionNode: ASCollectionNode
    
    fileprivate let cart: Cart        
    
    fileprivate var cashCalculator:CashCalculator!
    fileprivate var cashValues: [Double]?
    
    init(cart: Cart) {
        self.cart = cart // todo: add cart sum field and observe value change to update layout
        
        let flowLayout = UICollectionViewFlowLayout()
        flowLayout.scrollDirection = .horizontal
        flowLayout.itemSize = CGSize(width: 71, height: 44)
        flowLayout.minimumInteritemSpacing = 8
        
        collectionNode = ASCollectionNode(collectionViewLayout: flowLayout)
        
        super.init()
        
        self.automaticallyManagesSubnodes = true
        
        initCashCalculator()
        
        setupNodes()
    }
    
    private func initCashCalculator() {
        DispatchQueue.global().async { [unowned self] _ in
            let cashCalculator = CashCalculator(faces: Constants.NominalValues,
                                                monetaryUnitCentsCount: 1)
            let cashValues = cashCalculator.getPossibleCashValues(price: self.cart.sum(forCurrencyLocale: self.currencyLocale))
            
            DispatchQueue.main.async { [unowned self] _ in
                self.cashCalculator = cashCalculator
                self.cashValues = cashValues
                
                self.collectionNode.reloadData()
            }
        }
    }
    
    private func setupNodes() {
        setupTitleTextNode()
        setupCollectionNode()
    }
    
    private func setupTitleTextNode() {
        let title = NSAttributedString(string: "Сдача с".uppercased(),
                                       attributes: OrderWithDeliveryFormNode.SectionTitleStringAttributes)
        titleTextNode.attributedText = title
    }
    
    private func setupCollectionNode() {
        collectionNode.delegate = self
        collectionNode.dataSource = self
        collectionNode.allowsSelection = true
    }
    
    override func didLoad() {
        super.didLoad()
        
        collectionNode.view.showsHorizontalScrollIndicator = false
        collectionNode.view.contentInset = UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 16)
    }
    
    override func layoutSpecThatFits(_ constrainedSize: ASSizeRange) -> ASLayoutSpec {
        let titleLayout = ASInsetLayoutSpec(insets: UIEdgeInsetsMake(0, 16, 0, 0), child: titleTextNode)
        
        let collectionNodeSize = CGSize(width: constrainedSize.max.width, height: 44)
        collectionNode.style.preferredSize = collectionNodeSize
        
        let layout = ASStackLayoutSpec.vertical()
        layout.spacing = 24
        layout.children = [titleLayout, collectionNode]
        
        return layout
    }
}

extension CashOptionsSectionNode: ASCollectionDataSource, ASCollectionDelegate {
    
    func collectionNode(_ collectionNode: ASCollectionNode, numberOfItemsInSection section: Int) -> Int {
        guard let numberOfItems = cashValues?.count else { return 0 }
        
        return numberOfItems + 1
    }
    
    func collectionNode(_ collectionNode: ASCollectionNode, nodeBlockForItemAt indexPath: IndexPath) -> ASCellNodeBlock {
        guard indexPath.row > 0 else {return {CashOptionCellNode(text: "Без сдачи")} }
        guard indexPath.row - 1 < (cashValues?.count ?? 0) else {return {ASCellNode()}}
        
        let cashValue = cashValues![indexPath.row - 1]
        let formattedCashValue = PriceEntity.formattedPrice(value: cashValue, currencyLocale: currencyLocale)
        
        return { CashOptionCellNode(text: "\(formattedCashValue)") }
    }
    
    func collectionNode(_ collectionNode: ASCollectionNode, didSelectItemAt indexPath: IndexPath) {
        let node = collectionNode.nodeForItem(at: indexPath)
        node?.invalidateCalculatedLayout()
        node?.setNeedsDisplay()
    }
}
