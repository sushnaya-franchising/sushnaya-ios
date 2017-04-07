//
// Created by Igor Kurylenko on 3/30/17.
// Copyright (c) 2017 igor kurilenko. All rights reserved.
//

import Foundation
import SwiftEventBus
import AsyncDisplayKit

typealias EventBus = SwiftEventBus

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

func drawTabBarImage(frame: CGRect = CGRect(x: 0, y: 0, width: 375, height: 71)) -> UIImage? {
    UIGraphicsBeginImageContextWithOptions(frame.size, false, 0)
    //// General Declarations
    let context = UIGraphicsGetCurrentContext()!
    // This non-generic function dramatically improves compilation times of complex expressions.
    func fastFloor(_ x: CGFloat) -> CGFloat {
        return floor(x)
    }

    //// Color Declarations
    let color = UIColor(red: 0.961, green: 0.961, blue: 0.961, alpha: 0.9)

    //// Shadow Declarations
    let shadow = NSShadow()
    shadow.shadowColor = UIColor.black.withAlphaComponent(0.7)
    shadow.shadowOffset = CGSize(width: 0, height: 0)
    shadow.shadowBlurRadius = 1.5

    //// Subframes
    let frameForCircle = CGRect(x: frame.minX + fastFloor((frame.width - 72) * 0.49835 + 0.5), y: frame.minY + frame.height - 71, width: 72, height: 35)

    //// Bezier Drawing
    let bezierPath = UIBezierPath()
    bezierPath.move(to: CGPoint(x: frameForCircle.minX + 63.84, y: frameForCircle.maxY - 13))
    bezierPath.addLine(to: CGPoint(x: frame.maxX, y: frame.maxY - 49))
    bezierPath.addLine(to: CGPoint(x: frame.maxX, y: frame.maxY))
    bezierPath.addLine(to: CGPoint(x: frame.minX, y: frame.maxY))
    bezierPath.addLine(to: CGPoint(x: frame.minX, y: frame.maxY - 49))
    bezierPath.addLine(to: CGPoint(x: frameForCircle.minX + 10.16, y: frameForCircle.maxY - 13))
    bezierPath.addCurve(to: CGPoint(x: frameForCircle.minX + 37, y: frameForCircle.maxY - 31), controlPoint1: CGPoint(x: frameForCircle.minX + 14.49, y: frameForCircle.maxY - 23.56), controlPoint2: CGPoint(x: frameForCircle.minX + 24.88, y: frameForCircle.maxY - 31))
    bezierPath.addCurve(to: CGPoint(x: frameForCircle.minX + 63.84, y: frameForCircle.maxY - 13), controlPoint1: CGPoint(x: frameForCircle.minX + 49.12, y: frameForCircle.maxY - 31), controlPoint2: CGPoint(x: frameForCircle.minX + 59.51, y: frameForCircle.maxY - 23.56))
    bezierPath.close()
    context.saveGState()
    context.setShadow(offset: shadow.shadowOffset, blur: shadow.shadowBlurRadius, color: (shadow.shadowColor as! UIColor).cgColor)
    color.setFill()
    bezierPath.fill()
    context.restoreGState()

    let resultImage = UIGraphicsGetImageFromCurrentImageContext()

    UIGraphicsEndImageContext()

    return resultImage
}

func fireFakeChangeLoalitiesProposal() {
    ChangeLocalityProposalEvent.fire(localities: [

            Locality(location: CLLocation(latitude: 56.838607, longitude: 60.605514), name: "Екатеринбург", description: "Свердловская область, Россия",
                    boundedBy: (CLLocation(latitude: 56.593795, longitude: 60.263481),
                            CLLocation(latitude: 56.982916, longitude: 60.943308)),
                    coatOfArmsUrl: "https://upload.wikimedia.org/wikipedia/commons/thumb/9/9c/Coat_of_Arms_of_Yekaterinburg_%28Sverdlovsk_oblast%29.svg/600px-Coat_of_Arms_of_Yekaterinburg_%28Sverdlovsk_oblast%29.svg.png"),

            Locality(location: CLLocation(latitude: 57.000348, longitude: 40.973921), name: "Иваново", description: "Росиия",
                    boundedBy: (CLLocation(latitude: 56.946683, longitude: 40.867911),
                            CLLocation(latitude: 57.07038, longitude: 41.125476)),
                    coatOfArmsUrl: "https://upload.wikimedia.org/wikipedia/commons/thumb/b/b1/Coat-of-Arms-of-Ivanovo-%28Ivanovskaya_oblast%29.svg/400px-Coat-of-Arms-of-Ivanovo-%28Ivanovskaya_oblast%29.svg.png"),

            Locality(location: CLLocation(latitude: 57.767961, longitude: 40.926858), name: "Кострома", description: "Росиия",
                    boundedBy: (CLLocation(latitude: 57.707638, longitude: 40.744482),
                            CLLocation(latitude: 57.838285, longitude: 41.058335)),
                    coatOfArmsUrl: "https://upload.wikimedia.org/wikipedia/commons/thumb/7/74/Coat_of_Arms_of_Kostroma.svg/200px-Coat_of_Arms_of_Kostroma.svg.png"),

            Locality(location: CLLocation(latitude: 58.048454, longitude: 38.858406), name: "Рыбинск", description: "Росиия, Ярославская область",
                    boundedBy: (CLLocation(latitude: 58.001581, longitude: 38.64997),
                            CLLocation(latitude: 58.12118, longitude: 38.975035)),
                    coatOfArmsUrl: "https://upload.wikimedia.org/wikipedia/commons/b/b9/Coat_of_Arms_of_Rybinsk_%28Yaroslavl_oblast%29.png"),

            Locality(location: CLLocation(latitude: 57.626569, longitude: 39.893787), name: "Ярославль", description: "Росиия",
                    boundedBy: (CLLocation(latitude: 57.525615, longitude: 39.730796),
                            CLLocation(latitude: 57.775396, longitude: 40.003049)),
                    coatOfArmsUrl: "https://upload.wikimedia.org/wikipedia/commons/f/f6/Coat_of_Arms_of_Yaroslavl_%281995%29.png")
    ])
}
