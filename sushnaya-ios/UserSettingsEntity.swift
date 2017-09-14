import Foundation
import SwiftEventBus
import CoreData

class UserSettingsEntity: NSManagedObject {
    @NSManaged var authToken: String
    @NSManaged var selectedMenu: MenuEntity?
}
