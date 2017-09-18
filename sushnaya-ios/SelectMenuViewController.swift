import Foundation
import AsyncDisplayKit
import UIKit
import CoreStore

class SelectMenuViewController: ASViewController<SelectMenuNode> {

    var menus: ListMonitor<MenuEntity> {
        return app.core.menus
    }
    
    fileprivate var tableNode: ASTableNode {
        return self.node.tableNode
    }
    
    convenience init() {
        self.init(node: SelectMenuNode())
        
        self.tableNode.delegate = self
        self.tableNode.dataSource = self
        
        self.menus.addObserver(self)
    }
    
    deinit {
        self.menus.removeObserver(self)
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

//        if let indexPath = node.tableNode.indexPathForSelectedRow {
//            node.tableNode.deselectRow(at: indexPath, animated: true)
//        }
    }
    
    private func setupTableNode() {
        
        tableNode.view.separatorStyle = .none
    }
    
    fileprivate func setTableEnabled(_ enabled: Bool) {
        UIView.animate(
            withDuration: 0.2,
            delay: 0,
            options: .beginFromCurrentState,
            animations: { [unowned self] () -> Void in
                self.tableNode.alpha = enabled ? 1.0 : 0.5
                self.tableNode.isUserInteractionEnabled = enabled
            },
            completion: nil
        )
    }
}

extension SelectMenuViewController: ListSectionObserver {
    
    func listMonitorWillChange(_ monitor: ListMonitor<MenuEntity>) {
        // tableNode.view.beginUpdates()
    }
    
    func listMonitorDidChange(_ monitor: ListMonitor<MenuEntity>) {
        // tableNode.view.endUpdates()
    }
    
    func listMonitorWillRefetch(_ monitor: ListMonitor<MenuEntity>) {
        setTableEnabled(false)
    }
    
    func listMonitorDidRefetch(_ monitor: ListMonitor<MenuEntity>) {
        tableNode.reloadData()
        setTableEnabled(true)
    }
    
    func listMonitor(_ monitor: ListMonitor<MenuCategoryEntity>, didInsertObject object: MenuEntity, toIndexPath indexPath: IndexPath) {
        
        self.tableNode.insertRows(at: [indexPath], with: .automatic)
    }
    
    func listMonitor(_ monitor: ListMonitor<MenuCategoryEntity>, didDeleteObject object: MenuEntity, fromIndexPath indexPath: IndexPath) {
        
        self.tableNode.deleteRows(at: [indexPath], with: .automatic)
    }
    
    func listMonitor(_ monitor: ListMonitor<MenuCategoryEntity>, didUpdateObject object: MenuEntity, atIndexPath indexPath: IndexPath) {
        
        if let cell = self.tableNode.nodeForRow(at: indexPath) as? MenuCellNode {
            cell.menu = object
        }
    }
    
    func listMonitor(_ monitor: ListMonitor<MenuCategoryEntity>, didMoveObject object: MenuEntity, fromIndexPath: IndexPath, toIndexPath: IndexPath) {
        
        self.tableNode.deleteRows(at: [fromIndexPath], with: .automatic)
        self.tableNode.insertRows(at: [toIndexPath], with: .automatic)
    }
    
    // MARK: ListSectionObserver
    
    func listMonitor(_ monitor: ListMonitor<MenuEntity>, didInsertSection sectionInfo: NSFetchedResultsSectionInfo, toSectionIndex sectionIndex: Int) {
        
        self.tableNode.insertSections(IndexSet(integer: sectionIndex), with: .automatic)
    }
    
    func listMonitor(_ monitor: ListMonitor<MenuEntity>, didDeleteSection sectionInfo: NSFetchedResultsSectionInfo, fromSectionIndex sectionIndex: Int) {
        
        self.tableNode.deleteSections(IndexSet(integer: sectionIndex), with: .automatic)
    }
}

extension SelectMenuViewController: ASTableDataSource, ASTableDelegate {
    func tableNode(_ tableNode: ASTableNode, numberOfRowsInSection section: Int) -> Int {
        return menus.numberOfObjectsInSection(section)
    }
    
    func tableNode(_ tableNode: ASTableNode, nodeBlockForRowAt indexPath: IndexPath) -> ASCellNodeBlock {
        let menu = self.menus.objectsInSection(indexPath.section)[indexPath.row]
        
        return {
            return MenuCellNode(menu: menu)
        }
    }
    
    func tableNode(_ tableNode: ASTableNode, didSelectRowAt indexPath: IndexPath) {
        let menu = self.menus.objectsInSection(indexPath.section)[indexPath.row]
        
        FoodServiceRest.requestSelectMenu(menuId: menu.serverId, authToken: app.authToken!)
        
        self.dismiss(animated: true, completion: nil)
    }
}
