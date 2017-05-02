//
//  Address.swift
//  sushnaya-ios
//
//  Created by Igor Kurylenko on 4/29/17.
//  Copyright © 2017 igor kurilenko. All rights reserved.
//

import Foundation

struct Address {
    var coordinate: CLLocationCoordinate2D
    var countryCode: String
    var formatted: String
    var components: [AddressComponent]
    var opengisName: String?
    
    var displayName: String {
        return opengisName ?? formatted
    }
}

struct AddressComponent {
    var kind: String
    var name: String
}
