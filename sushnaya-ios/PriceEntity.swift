//
// Created by Igor Kurylenko on 4/8/17.
// Copyright (c) 2017 igor kurilenko. All rights reserved.
//

import Foundation
import CoreData

class PriceEntity: NSManagedObject {
    @NSManaged var serverId: Int
    @NSManaged var value: Double
    @NSManaged var modifierName: String?
    @NSManaged var currencyLocale: String
}
