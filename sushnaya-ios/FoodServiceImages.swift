//
//  FoodServiceImages.swift
//  sushnaya-ios
//
//  Created by Igor Kurylenko on 8/5/17.
//  Copyright © 2017 igor kurilenko. All rights reserved.
//

import Foundation

class FoodServiceImages {
    static let baseUrl = "http://img.sushnaya.com:8888"
    static let coatOfArmsUrl = "/coatofarms"
    
    class func getCoatOfArmsImageUrl(location: CLLocation) -> URL {
        let queryItems = [URLQueryItem(name: "lat", value: "\(location.coordinate.latitude)"),
                          URLQueryItem(name: "lon", value: "\(location.coordinate.longitude)")]
        let urlComponents = NSURLComponents(string: "\(baseUrl)\(coatOfArmsUrl)")!
        urlComponents.queryItems = queryItems
        
        return urlComponents.url!
    }
}
