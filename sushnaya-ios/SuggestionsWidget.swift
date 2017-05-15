//
//  SuggestionsDropdownNode.swift
//  sushnaya-ios
//
//  Created by Igor Kurylenko on 5/9/17.
//  Copyright © 2017 igor kurilenko. All rights reserved.
//

import Foundation
import AsyncDisplayKit
import PromiseKit

protocol SuggestionsProvider: class {
    func requestSuggestions(forQuery query: String) -> Promise<[String]?>
    @discardableResult
    func cancelAllRequests() -> Promise<()>
}

class DadataSuggestionsProvider: SuggestionsProvider {
    var cityFiasId: String
    var suggestHouseOnly: Bool = false
    
    init(cityFiasId: String) {
        self.cityFiasId = cityFiasId
    }
    
    func requestSuggestions(forQuery query: String) -> Promise<[String]?> {
        return Dadata.requestAddressSuggestions(query: query, cityFiasId: cityFiasId, fromBound: suggestHouseOnly ? "house" : "street")
    }
    
    func cancelAllRequests() -> Promise<()> {
        return Dadata.cancelAllRequests()
    }
}

enum SuggestionsWidgetState {
    case opened, closed
}

protocol SuggestionsWidgetDelegate: class {
    func suggestionsWidget(_ widget: SuggestionsWidget, didSelectSuggestion suggestion: String)
}

class SuggestionsWidget: NSObject {
    var state: SuggestionsWidgetState = .closed {
        didSet {
            guard oldValue != state else { return }
            
            updateVisiblity()
        }
    }
    
    var provider: SuggestionsProvider?
    weak var delegate: SuggestionsWidgetDelegate?
    
    var view: UIView {
        get {
            return tableNode.view
        }
    }
    
    fileprivate var currentQuery: String?
    fileprivate var tableNode = ASTableNode()
    fileprivate var suggestions: [String]? = nil {
        didSet {
            guard suggestions != oldValue else {
                return
            }
            
            updateVisiblity()
        }
    }
    
    var suggestionsCount: Int {
        return suggestions?.count ?? 0
    }
    
    override init() {
        super.init()
        
        tableNode.isHidden = true
        tableNode.backgroundColor = PaperColor.White.withAlphaComponent(0.93)
        tableNode.dataSource = self
        tableNode.delegate = self
    }
    
    func updateSuggestions(forQuery query: String) {
        let normQuery = normalizeQuery(query: query)
        
        guard normQuery != currentQuery else {
            return
        }
        
        currentQuery = normQuery
        
        updateSuggestions()
    }

    private func updateSuggestions() {
        guard let query = currentQuery else {
            clear()
            return
        }
        
        guard !query.isEmpty else {
            clear()
            return
        }
        
        provider?.requestSuggestions(forQuery: query).then { [unowned self] suggestions -> () in
                DispatchQueue.main.async {[unowned self] in
                    if !self.requestsAreBeingCancelled {
                        self.suggestions = suggestions
                    }
                }
            }.catch { error in
                debugPrint(error)
        }
    }
    
    var requestsAreBeingCancelled: Bool = false
    
    private func clear() {
        DispatchQueue.main.async {[unowned self] in
            self.requestsAreBeingCancelled = true
        }
        
        self.provider?.cancelAllRequests().then { [unowned self] () -> () in
            DispatchQueue.main.async {[unowned self] in
                self.requestsAreBeingCancelled = false
                self.suggestions = nil
            }
            
            }.catch { error in
                debugPrint(error)
        }
    }
    
    private func normalizeQuery(query: String) -> String {
        return query.stringByReplacingMatchesInString(pattern: "^\\s*")
            .stringByReplacingMatchesInString(pattern: "\\s{2,}", replaceWith: " ")
    }
    
    func updateVisiblity() {
        DispatchQueue.main.async {[unowned self] in
            self.tableNode.reloadData()
            self.tableNode.isHidden = (self.state == .closed || self.suggestionsCount == 0)
        }
    }
    
    public func layout(inFrame frame: CGRect) -> Promise<()> {
        return Promise { fulfill, reject in
            guard frame != self.view.frame else {
                fulfill()
                return
            }
            
            DispatchQueue.global().async {[unowned self] _ in
                let _ = self.tableNode.layoutThatFits(ASSizeRangeMake(frame.size, frame.size))
                self.tableNode.frame = frame
            
                DispatchQueue.main.async { [unowned self] _ in
                    self.tableNode.view.separatorStyle = .none
                    fulfill()
                }
            }
        }
    }
}

fileprivate func !=(lhs: [String]?, rhs: [String]?) -> Bool {
    return !(lhs == rhs)
}

fileprivate func ==(lhs: [String]?, rhs: [String]?) -> Bool {
    switch (lhs, rhs) {
    case (.some(let l), .some(let r)):
        return HashValueUtil.hashValue(of: l) == HashValueUtil.hashValue(of: r)
    case (.none, .none):
        return true
    default:
        return false
    }
}

extension SuggestionsWidget: ASTableDataSource, ASTableDelegate {
    func tableNode(_ tableNode: ASTableNode, numberOfRowsInSection section: Int) -> Int {
        return suggestions?.count ?? 0
    }
    
    func tableNode(_ tableNode: ASTableNode, nodeBlockForRowAt indexPath: IndexPath) -> ASCellNodeBlock {
        guard let suggestion = suggestions?[indexPath.row] else {
            return { ASCellNode() }
        }
        
        return {
            SuggestionCellNode(suggestion: suggestion)
        }
    }
    
    func tableNode(_ tableNode: ASTableNode, didSelectRowAt indexPath: IndexPath) {
        guard let suggestion = suggestions?[indexPath.row] else {
            return
        }
        
        delegate?.suggestionsWidget(self, didSelectSuggestion: suggestion)
    }
}
