import Foundation
import UIKit
import AsyncDisplayKit

extension UIViewController {
    var app: App {
        return UIApplication.shared.delegate as! App
    }
    
    var notificationCenter: NotificationCenter {
        return NotificationCenter.default
    }
    
    func alert(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: UIAlertControllerStyle.alert)
        alert.addAction(UIAlertAction(title: "ОК", style: UIAlertActionStyle.default, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
}

