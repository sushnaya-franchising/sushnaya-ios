//
// Created by Igor Kurylenko on 3/30/17.
// Copyright (c) 2017 igor kurilenko. All rights reserved.
//

import Foundation
import UIKit

extension UIImage {
    public convenience init?(color: UIColor, size: CGSize = CGSize(width: 1, height: 1)) {
        let rect = CGRect(origin: .zero, size: size)
        UIGraphicsBeginImageContextWithOptions(rect.size, false, 0.0)
        color.setFill()
        UIRectFill(rect)
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()

        guard let cgImage = image?.cgImage else {
            return nil
        }
        self.init(cgImage: cgImage)
    }

    public func convertToGrayScale() -> UIImage {

        let filter = CIFilter(name: "CIPhotoEffectNoir")

        // convert UIImage to CIImage and set as input

        let ciInput = CIImage(image: self)
        filter?.setValue(ciInput, forKey: kCIInputImageKey)

        // get output CIImage, render as CGImage first to retain proper UIImage scale

        let ciOutput = filter?.outputImage
        let ciContext = CIContext()
        let cgImage = ciContext.createCGImage(ciOutput!, from: (ciOutput?.extent)!)

        let result = UIImage(cgImage: cgImage!, scale: UIScreen.main.scale, orientation: UIImageOrientation.up)

        return result
    }
    
    public func tranlucentWithAlpha(alpha: CGFloat) -> UIImage {
        UIGraphicsBeginImageContextWithOptions(size, false, scale)
        draw(at: CGPoint.zero, blendMode: .normal, alpha: alpha)
        let tranlucentImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return tranlucentImage!
    }
}
