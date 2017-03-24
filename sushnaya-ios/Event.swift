//
//  Event.swift
//  sushnaya-ios
//
//  Created by Igor Kurylenko on 3/24/17.
//  Copyright © 2017 igor kurilenko. All rights reserved.
//

import Foundation
import SwiftEventBus


protocol Event {
    static var name: String { get }
}

//enum Event {
  //  case authenticationEvent(authToken: String)
//}
