//
//  Locality.swift
//  sushnaya-ios
//
//  Created by Igor Kurylenko on 3/22/17.
//  Copyright © 2017 igor kurilenko. All rights reserved.
//

import Foundation
import CoreLocation

struct Locality {
    var location: CLLocation
    var name: String
    var description: String
    var boundedBy: (lowerCorner: CLLocation, upperCorner: CLLocation)
    var fiasId: String
        
    func includes(location: CLLocation) -> Bool {
        let (lower, upper) = boundedBy
        
        return lower.coordinate.latitude <= location.coordinate.latitude &&
                location.coordinate.latitude <= upper.coordinate.latitude &&
                lower.coordinate.longitude <= location.coordinate.longitude &&
                location.coordinate.longitude <= upper.coordinate.longitude
    }
}
