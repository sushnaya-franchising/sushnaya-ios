//
//  Locality.swift
//  sushnaya-ios
//
//  Created by Igor Kurylenko on 3/22/17.
//  Copyright © 2017 igor kurilenko. All rights reserved.
//

import Foundation
import CoreLocation

class Locality {
    var location: CLLocation
    var name: String
    var description: String
    var coatOfArmsUrl: String?
    
    convenience init(location: CLLocation, name: String, description: String) {
        self.init(location: location, name: name, description: description, coatOfArmsUrl: nil)
    }
    
    init(location: CLLocation, name: String, description: String, coatOfArmsUrl: String?) {
        self.location = location
        self.name = name
        self.description = description
        self.coatOfArmsUrl = coatOfArmsUrl
    }
}
