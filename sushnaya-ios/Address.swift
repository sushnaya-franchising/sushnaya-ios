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
}
