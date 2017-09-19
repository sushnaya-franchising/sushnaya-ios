import Foundation
import CoreStore
import SwiftyJSON

class AddressEntity: NSManagedObject {
    @NSManaged var serverId: NSNumber?
    @NSManaged var latitude: Double
    @NSManaged var longitude: Double
    @NSManaged var streetAndHouse: String
    @NSManaged var apartment: String?
    @NSManaged var entrance: String?
    @NSManaged var floor: String?
    @NSManaged var comment: String?
    @NSManaged var orderCount: Int32
    @NSManaged var timestamp: NSNumber?

    @NSManaged var locality: LocalityEntity

    var displayName: String {
        guard let apartment = apartment else {
            return streetAndHouse
        }

        return "\(streetAndHouse), \(apartment)"
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

extension AddressEntity: ImportableUniqueObject {
    typealias ImportSource = JSON
    typealias UniqueIDType = Int32
    
    class var uniqueIDKeyPath: String {
        return #keyPath(AddressEntity.serverId)
    }
    
    var uniqueIDValue: Int32 {
        get { return self.serverId!.int32Value }
        set { self.serverId = NSNumber(value: newValue) }
    }
    
    class func uniqueID(from source: JSON, in transaction: BaseDataTransaction) throws -> Int32? {
        return source["id"].int32
    }
    
    func update(from source: ImportSource, in transaction: BaseDataTransaction) throws {
        // todo: impl
    }
}
