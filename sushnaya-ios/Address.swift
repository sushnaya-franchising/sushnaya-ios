import Foundation

struct Address {
    var locality: Locality
    var streetAndHouse: String
    var latitude: Double
    var longitude: Double
    var ordersCount: Int = 0
    var apartment: String?
    var entrance: String?
    var floor: String?
    var comment: String?
    var serverId: Int?
    
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
