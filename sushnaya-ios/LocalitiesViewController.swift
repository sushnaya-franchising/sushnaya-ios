//
//  LocalitiesViewContoller.swift
//  sushnaya-ios
//
//  Created by Igor Kurylenko on 3/22/17.
//  Copyright © 2017 igor kurilenko. All rights reserved.
//

import Foundation
import UIKit
import CoreLocation
import PromiseKit

class LocalitiesViewController: UIViewController {
    
    @IBOutlet weak var tableView: UITableView!
    
    var localities: [Locality]!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        
    }
}

extension LocalitiesViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let locality = localities[indexPath.row]
        
        ChangeLocalityEvent.fire(locality: locality)
        
        dismiss(animated: true, completion: nil)
    }
}

extension LocalitiesViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return localities.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Locality")!
        
        cell.textLabel?.text = localities[indexPath.row].name
        
        return cell
    }
}
