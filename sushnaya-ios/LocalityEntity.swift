import Foundation
import CoreLocation
import CoreStore
import SwiftyJSON

class LocalityEntity: NSManagedObject {
    @NSManaged var name: String
    @NSManaged var descr: String
    @NSManaged var fiasId: String
    @NSManaged var latitude: Double
    @NSManaged var longitude: Double
    @NSManaged var lowerLatitude: Double
    @NSManaged var lowerLongitude: Double
    @NSManaged var upperLatitude: Double
    @NSManaged var upperLongitude: Double

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

extension LocalityEntity {
    func update(from source: JSON, in transaction: BaseDataTransaction) throws {
        self.name = source["name"].string!
        self.descr = source["description"].string!
        self.fiasId = source["fiasId"].string!
        self.latitude = source["location"]["latitude"].double!
        self.longitude = source["location"]["longitude"].double!
        self.lowerLatitude = source["boundedBy"]["lowerCorner"]["latitude"].double!
        self.lowerLongitude = source["boundedBy"]["lowerCorner"]["longitude"].double!
        self.upperLatitude = source["boundedBy"]["upperCorner"]["latitude"].double!
        self.upperLongitude = source["boundedBy"]["upperCorner"]["longitude"].double!
    }
}

