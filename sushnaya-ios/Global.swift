//
// Created by Igor Kurylenko on 3/30/17.
// Copyright (c) 2017 igor kurilenko. All rights reserved.
//

import Foundation
import SwiftEventBus
import AsyncDisplayKit

typealias EventBus = SwiftEventBus

class HashValueUtil {
    static func hashValue<T: Hashable>(of: [T?]) -> Int {
        var result = 1
        
        for x in of {
            result = 31 &* result &+ (x?.hashValue ?? 0)
        }
        
        return result
    }
}

func ImageNodePrecompositedCornerModification(cornerRadius: CGFloat) -> ((UIImage) -> UIImage) {
    return { (image: UIImage) -> UIImage in
        let rect = CGRect(origin: CGPoint.zero, size: image.size)

        UIGraphicsBeginImageContextWithOptions(image.size, false, UIScreen.main.scale)

        UIBezierPath.init(roundedRect: rect, cornerRadius: cornerRadius).addClip()
        image.draw(in: rect)
        let modifiedImage = UIGraphicsGetImageFromCurrentImageContext()

        UIGraphicsEndImageContext()

        return modifiedImage!
    }
}

func drawTabBarImage(frame: CGRect = CGRect(x: 0, y: 0, width: 375, height: 49)) -> UIImage? {
    UIGraphicsBeginImageContextWithOptions(frame.size, false, 0)
    //// Color Declarations
    let backgroundColor = UIColor(red: 1.000, green: 1.000, blue: 1.000, alpha: 0.980)
    
    //// Rectangle Drawing
    let rectanglePath = UIBezierPath(rect: CGRect(x: frame.minX, y: frame.minY, width: frame.width, height: frame.height))
    backgroundColor.setFill()
    rectanglePath.fill()
    
    let resultImage = UIGraphicsGetImageFromCurrentImageContext()
    
    UIGraphicsEndImageContext()
    
    return resultImage
}


func fireFakeChangeLocalitiesProposal() {
    SelectMenuEvent.fire(menus: [
        Menu(menuId: 1, locality: Locality(location: CLLocation(latitude: 55.753215, longitude: 37.622504),
                                           name: "Москва", description: "Россия",
                                           boundedBy: (CLLocation(latitude: 55.142627, longitude: 36.803259),
                                                       CLLocation(latitude: 56.021367, longitude: 37.967682)),
                                           fiasId: "0c5b2444-70a0-4932-980c-b4dc0d3f02b5",
                                           coatOfArmsUrl: "https://upload.wikimedia.org/wikipedia/commons/thumb/b/bb/Coat_of_Arms_of_Moscow.svg/440px-Coat_of_Arms_of_Moscow.svg.png")),
        
        Menu(menuId: 2, locality: Locality(location: CLLocation(latitude: 56.838607, longitude: 60.605514), name: "Екатеринбург", description: "Свердловская область, Россия",
                                           boundedBy: (CLLocation(latitude: 56.593795, longitude: 60.263481),
                                                       CLLocation(latitude: 56.982916, longitude: 60.943308)),
                                           fiasId: "2763c110-cb8b-416a-9dac-ad28a55b4402",
                                           coatOfArmsUrl: "https://upload.wikimedia.org/wikipedia/commons/thumb/9/9c/Coat_of_Arms_of_Yekaterinburg_%28Sverdlovsk_oblast%29.svg/600px-Coat_of_Arms_of_Yekaterinburg_%28Sverdlovsk_oblast%29.svg.png")),
        
        Menu(menuId: 3, locality: Locality(location: CLLocation(latitude: 57.000348, longitude: 40.973921),
                                           name: "Иваново", description: "Росиия",
                                           boundedBy: (CLLocation(latitude: 56.946683, longitude: 40.867911),
                                                       CLLocation(latitude: 57.07038, longitude: 41.125476)),
                                           fiasId: "40c6863e-2a5f-4033-a377-3416533948bd",
                                           coatOfArmsUrl: "https://upload.wikimedia.org/wikipedia/commons/thumb/b/b1/Coat-of-Arms-of-Ivanovo-%28Ivanovskaya_oblast%29.svg/400px-Coat-of-Arms-of-Ivanovo-%28Ivanovskaya_oblast%29.svg.png")),
        
        Menu(menuId: 4, locality: Locality(location: CLLocation(latitude: 57.767961, longitude: 40.926858), name: "Кострома", description: "Росиия",
                                           boundedBy: (CLLocation(latitude: 57.707638, longitude: 40.744482),
                                                       CLLocation(latitude: 57.838285, longitude: 41.058335)),
                                           fiasId: "14c73394-b886-40a9-9e5c-547cfd4d6aad",
                                           coatOfArmsUrl: "https://upload.wikimedia.org/wikipedia/commons/thumb/7/74/Coat_of_Arms_of_Kostroma.svg/200px-Coat_of_Arms_of_Kostroma.svg.png")),
        
        Menu(menuId: 5, locality: Locality(location: CLLocation(latitude: 58.048454, longitude: 38.858406),
                                           name: "Рыбинск", description: "Росиия, Ярославская область",
                                           boundedBy: (CLLocation(latitude: 58.001581, longitude: 38.64997),
                                                       CLLocation(latitude: 58.12118, longitude: 38.975035)),
                                           fiasId: "292c0a6a-47ce-435d-8a75-f80e9ce67fba",
                                           coatOfArmsUrl: "https://upload.wikimedia.org/wikipedia/commons/b/b9/Coat_of_Arms_of_Rybinsk_%28Yaroslavl_oblast%29.png")),
        
        Menu(menuId: 6, locality: Locality(location: CLLocation(latitude: 57.626569, longitude: 39.893787), name: "Ярославль", description: "Росиия",
                                           boundedBy: (CLLocation(latitude: 57.525615, longitude: 39.730796),
                                                       CLLocation(latitude: 57.775396, longitude: 40.003049)),
                                           fiasId: "6b1bab7d-ee45-4168-a2a6-4ce2880d90d3",
                                           coatOfArmsUrl: "https://upload.wikimedia.org/wikipedia/commons/f/f6/Coat_of_Arms_of_Yaroslavl_%281995%29.png"))
        ])
}
































