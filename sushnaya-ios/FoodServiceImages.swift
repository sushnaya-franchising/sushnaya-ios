import Foundation

class FoodServiceImages {
    static let baseUrl = "http://img.appnbot.ngrok.io"
    static let coatOfArmsUrl = "/coatofarms"
    
    class func getCoatOfArmsImageUrl(coordinate: CLLocationCoordinate2D) -> URL {
        let queryItems = [URLQueryItem(name: "lat", value: "\(coordinate.latitude)"),
                          URLQueryItem(name: "lon", value: "\(coordinate.longitude)")]
        let urlComponents = NSURLComponents(string: "\(baseUrl)\(coatOfArmsUrl)")!
        urlComponents.queryItems = queryItems
        
        return urlComponents.url!
    }
}
