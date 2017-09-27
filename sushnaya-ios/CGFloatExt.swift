import UIKit

extension Float {
    var asNSNumber: NSNumber {
        return NSNumber(value: self as Float)
    }
    
    var asCGFloat: CGFloat {
        return CGFloat(self)
    }
    
    var asCFTimeInterval: CFTimeInterval {
        return CFTimeInterval(self)
    }
}

extension CGFloat {
    var asNSNumber: NSNumber {
        return asFloat.asNSNumber
    }
    
    var asFloat: Float {
        return Float(self)
    }
    
    var asInt: Int {
        return Int(self)
    }
}
