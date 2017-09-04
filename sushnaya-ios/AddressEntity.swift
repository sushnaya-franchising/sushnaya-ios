import Foundation
import CoreData


class AddressEntity: NSManagedObject {
    @NSManaged var serverId: NSNumber?
    @NSManaged var latitude: Double
    @NSManaged var longitude: Double
    @NSManaged var streetAndHouse: String
    @NSManaged var apartment: String?
    @NSManaged var entrance: String?
    @NSManaged var floor: String?
    @NSManaged var comment: String?
    @NSManaged var ordersCount: Int32
    @NSManaged var needsSynchronization: Bool

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
