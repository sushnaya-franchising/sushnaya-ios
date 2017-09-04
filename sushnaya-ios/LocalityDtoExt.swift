import Foundation

extension LocalityDto {
    func includes(coordinate: CLLocationCoordinate2D) -> Bool {
        return self.lowerLatitude <= coordinate.latitude &&
            coordinate.latitude <= self.upperLatitude &&
            self.lowerLongitude <= coordinate.longitude &&
            coordinate.longitude <= self.upperLongitude
    }
}
