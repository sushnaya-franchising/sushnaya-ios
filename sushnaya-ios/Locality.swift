import Foundation
import CoreStore
import SwiftyJSON

struct Locality {
    var name: String
    var descr: String
    var fiasId: String
    var latitude: Double
    var longitude: Double
    var lowerLatitude: Double
    var lowerLongitude: Double
    var upperLatitude: Double
    var upperLongitude: Double
    
    var boundedBy: (lowerCorner: CLLocationCoordinate2D, upperCorner: CLLocationCoordinate2D) {
        get {
            return (lowerCorner: CLLocationCoordinate2D(latitude: lowerLatitude, longitude: lowerLongitude),
                    upperCorner: CLLocationCoordinate2D(latitude: upperLatitude, longitude: upperLongitude))
        }
        
        set {
            self.lowerLatitude = newValue.lowerCorner.latitude
            self.lowerLongitude = newValue.lowerCorner.longitude
            self.upperLatitude = newValue.upperCorner.latitude
            self.upperLongitude = newValue.upperCorner.longitude
        }
    }
    
    var coordinate: CLLocationCoordinate2D {
        get {
            return CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
        }
        
        set {
            self.latitude = newValue.latitude
            self.longitude = newValue.longitude
        }
    }
}
