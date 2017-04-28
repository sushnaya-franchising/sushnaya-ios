//
// Created by Igor Kurylenko on 4/25/17.
// Copyright (c) 2017 Igor Kurylenko. All rights reserved.
//

import Foundation

class UserSettings {
    // todo: create UserSettings and move this property there
    var locality: Locality? {
        didSet {
            // todo: persist locality
        }
    }

    var isLocalitySelected: Bool {
        get {
            return locality != nil
        }
    }
}