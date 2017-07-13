//
//  Address.swift
//  sushnaya-ios
//
//  Created by Igor Kurylenko on 4/29/17.
//  Copyright © 2017 igor kurilenko. All rights reserved.
//

import Foundation

struct Address {
    var locality: Locality
    var coordinate: CLLocationCoordinate2D
    var streetAndHouse: String?
    var apartment: String?
    var entrance: String?
    var floor: String?
    var comment: String?
    var displayName: String? {
        guard let streetAndHouse = streetAndHouse else { return nil }
        
        guard let apartment = apartment else {
            return streetAndHouse
        }
        
        return "\(streetAndHouse), \(apartment)"
    }
    
    init(locality: Locality, coordinate: CLLocationCoordinate2D,
         streetAndHouse: String? = nil, apartment: String? = nil,
         entrance: String? = nil, floor: String? = nil, comment: String? = nil) {
        self.locality = locality
        self.coordinate = coordinate
        self.streetAndHouse = streetAndHouse
        self.apartment = apartment
        self.entrance = entrance
        self.floor = floor
        self.comment = comment
    }
}
