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
    var boundedBy: (lowerCorner: CLLocation, upperCorner: CLLocation)
    
    convenience init(location: CLLocation, name: String, description: String, boundedBy: (CLLocation, CLLocation)) {
        self.init(location: location, name: name, description: description, boundedBy: boundedBy, coatOfArmsUrl: nil)
    }
    
    init(location: CLLocation, name: String, description: String, boundedBy: (CLLocation, CLLocation), coatOfArmsUrl: String?) {
        self.location = location
        self.name = name.capitalized
        self.description = description
        self.boundedBy = boundedBy
        self.coatOfArmsUrl = coatOfArmsUrl
    }
    
    func isIncluded(location: CLLocation) -> Bool {
        let (lower, upper) = boundedBy
        
        return lower.coordinate.latitude <= location.coordinate.latitude &&
                location.coordinate.latitude <= upper.coordinate.latitude &&
                lower.coordinate.longitude <= location.coordinate.longitude &&
                location.coordinate.longitude <= upper.coordinate.longitude
    }
}
