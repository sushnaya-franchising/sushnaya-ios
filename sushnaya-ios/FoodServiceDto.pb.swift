// DO NOT EDIT.
//
// Generated by the Swift generator plugin for the protocol buffer compiler.
// Source: FoodServiceDto.proto
//
// For information on using the generated types, please see the documenation:
//   https://github.com/apple/swift-protobuf/

import Foundation
import SwiftProtobuf

// If the compiler emits an error on this type, it is because this file
// was generated by a version of the `protoc` Swift plug-in that is
// incompatible with the version of SwiftProtobuf to which you are linking.
// Please ensure that your are building against the same version of the API
// that was used to generate this file.
fileprivate struct _GeneratedWithProtocGenSwiftVersion: SwiftProtobuf.ProtobufAPIVersionCheck {
  struct _2: SwiftProtobuf.ProtobufAPIVersion_2 {}
  typealias Version = _2
}

struct GetMenuDto: SwiftProtobuf.Message {
  static let protoMessageName: String = "GetMenuDto"

  var unknownFields = SwiftProtobuf.UnknownStorage()

  init() {}

  /// Used by the decoding initializers in the SwiftProtobuf library, not generally
  /// used directly. `init(serializedData:)`, `init(jsonUTF8Data:)`, and other decoding
  /// initializers are defined in the SwiftProtobuf library. See the Message and
  /// Message+*Additions` files.
  mutating func decodeMessage<D: SwiftProtobuf.Decoder>(decoder: inout D) throws {
    while let _ = try decoder.nextFieldNumber() {
    }
  }

  /// Used by the encoding methods of the SwiftProtobuf library, not generally
  /// used directly. `Message.serializedData()`, `Message.jsonUTF8Data()`, and
  /// other serializer methods are defined in the SwiftProtobuf library. See the
  /// `Message` and `Message+*Additions` files.
  func traverse<V: SwiftProtobuf.Visitor>(visitor: inout V) throws {
    try unknownFields.traverse(visitor: &visitor)
  }
}

struct SelectMenuDto: SwiftProtobuf.Message {
  static let protoMessageName: String = "SelectMenuDto"

  var menus: [MenuDto] = []

  var unknownFields = SwiftProtobuf.UnknownStorage()

  init() {}

  /// Used by the decoding initializers in the SwiftProtobuf library, not generally
  /// used directly. `init(serializedData:)`, `init(jsonUTF8Data:)`, and other decoding
  /// initializers are defined in the SwiftProtobuf library. See the Message and
  /// Message+*Additions` files.
  mutating func decodeMessage<D: SwiftProtobuf.Decoder>(decoder: inout D) throws {
    while let fieldNumber = try decoder.nextFieldNumber() {
      switch fieldNumber {
      case 1: try decoder.decodeRepeatedMessageField(value: &self.menus)
      default: break
      }
    }
  }

  /// Used by the encoding methods of the SwiftProtobuf library, not generally
  /// used directly. `Message.serializedData()`, `Message.jsonUTF8Data()`, and
  /// other serializer methods are defined in the SwiftProtobuf library. See the
  /// `Message` and `Message+*Additions` files.
  func traverse<V: SwiftProtobuf.Visitor>(visitor: inout V) throws {
    if !self.menus.isEmpty {
      try visitor.visitRepeatedMessageField(value: self.menus, fieldNumber: 1)
    }
    try unknownFields.traverse(visitor: &visitor)
  }
}

struct DidUpdateTermsOfServicesDto: SwiftProtobuf.Message {
  static let protoMessageName: String = "DidUpdateTermsOfServicesDto"

  var unknownFields = SwiftProtobuf.UnknownStorage()

  init() {}

  /// Used by the decoding initializers in the SwiftProtobuf library, not generally
  /// used directly. `init(serializedData:)`, `init(jsonUTF8Data:)`, and other decoding
  /// initializers are defined in the SwiftProtobuf library. See the Message and
  /// Message+*Additions` files.
  mutating func decodeMessage<D: SwiftProtobuf.Decoder>(decoder: inout D) throws {
    while let _ = try decoder.nextFieldNumber() {
    }
  }

  /// Used by the encoding methods of the SwiftProtobuf library, not generally
  /// used directly. `Message.serializedData()`, `Message.jsonUTF8Data()`, and
  /// other serializer methods are defined in the SwiftProtobuf library. See the
  /// `Message` and `Message+*Additions` files.
  func traverse<V: SwiftProtobuf.Visitor>(visitor: inout V) throws {
    try unknownFields.traverse(visitor: &visitor)
  }
}

struct MenuDto: SwiftProtobuf.Message {
  static let protoMessageName: String = "MenuDto"

  var menuID: Int64 {
    get {return _storage._menuID}
    set {_uniqueStorage()._menuID = newValue}
  }

  var locality: LocalityDto {
    get {return _storage._locality ?? LocalityDto()}
    set {_uniqueStorage()._locality = newValue}
  }
  /// Returns true if `locality` has been explicitly set.
  var hasLocality: Bool {return _storage._locality != nil}
  /// Clears the value of `locality`. Subsequent reads from it will return its default value.
  mutating func clearLocality() {_storage._locality = nil}

  var unknownFields = SwiftProtobuf.UnknownStorage()

  init() {}

  /// Used by the decoding initializers in the SwiftProtobuf library, not generally
  /// used directly. `init(serializedData:)`, `init(jsonUTF8Data:)`, and other decoding
  /// initializers are defined in the SwiftProtobuf library. See the Message and
  /// Message+*Additions` files.
  mutating func decodeMessage<D: SwiftProtobuf.Decoder>(decoder: inout D) throws {
    _ = _uniqueStorage()
    try withExtendedLifetime(_storage) { (_storage: _StorageClass) in
      while let fieldNumber = try decoder.nextFieldNumber() {
        switch fieldNumber {
        case 1: try decoder.decodeSingularInt64Field(value: &_storage._menuID)
        case 2: try decoder.decodeSingularMessageField(value: &_storage._locality)
        default: break
        }
      }
    }
  }

  /// Used by the encoding methods of the SwiftProtobuf library, not generally
  /// used directly. `Message.serializedData()`, `Message.jsonUTF8Data()`, and
  /// other serializer methods are defined in the SwiftProtobuf library. See the
  /// `Message` and `Message+*Additions` files.
  func traverse<V: SwiftProtobuf.Visitor>(visitor: inout V) throws {
    try withExtendedLifetime(_storage) { (_storage: _StorageClass) in
      if _storage._menuID != 0 {
        try visitor.visitSingularInt64Field(value: _storage._menuID, fieldNumber: 1)
      }
      if let v = _storage._locality {
        try visitor.visitSingularMessageField(value: v, fieldNumber: 2)
      }
    }
    try unknownFields.traverse(visitor: &visitor)
  }

  fileprivate var _storage = _StorageClass.defaultInstance
}

struct LocalityDto: SwiftProtobuf.Message {
  static let protoMessageName: String = "LocalityDto"

  var name: String = String()

  var descr: String = String()

  var latitude: Double = 0

  var longitude: Double = 0

  var lowerLatitude: Double = 0

  var lowerLongitude: Double = 0

  var upperLatitude: Double = 0

  var upperLongitude: Double = 0

  var fiasID: String = String()

  var unknownFields = SwiftProtobuf.UnknownStorage()

  init() {}

  /// Used by the decoding initializers in the SwiftProtobuf library, not generally
  /// used directly. `init(serializedData:)`, `init(jsonUTF8Data:)`, and other decoding
  /// initializers are defined in the SwiftProtobuf library. See the Message and
  /// Message+*Additions` files.
  mutating func decodeMessage<D: SwiftProtobuf.Decoder>(decoder: inout D) throws {
    while let fieldNumber = try decoder.nextFieldNumber() {
      switch fieldNumber {
      case 1: try decoder.decodeSingularStringField(value: &self.name)
      case 2: try decoder.decodeSingularStringField(value: &self.descr)
      case 3: try decoder.decodeSingularDoubleField(value: &self.latitude)
      case 4: try decoder.decodeSingularDoubleField(value: &self.longitude)
      case 5: try decoder.decodeSingularDoubleField(value: &self.lowerLatitude)
      case 6: try decoder.decodeSingularDoubleField(value: &self.lowerLongitude)
      case 7: try decoder.decodeSingularDoubleField(value: &self.upperLatitude)
      case 8: try decoder.decodeSingularDoubleField(value: &self.upperLongitude)
      case 9: try decoder.decodeSingularStringField(value: &self.fiasID)
      default: break
      }
    }
  }

  /// Used by the encoding methods of the SwiftProtobuf library, not generally
  /// used directly. `Message.serializedData()`, `Message.jsonUTF8Data()`, and
  /// other serializer methods are defined in the SwiftProtobuf library. See the
  /// `Message` and `Message+*Additions` files.
  func traverse<V: SwiftProtobuf.Visitor>(visitor: inout V) throws {
    if !self.name.isEmpty {
      try visitor.visitSingularStringField(value: self.name, fieldNumber: 1)
    }
    if !self.descr.isEmpty {
      try visitor.visitSingularStringField(value: self.descr, fieldNumber: 2)
    }
    if self.latitude != 0 {
      try visitor.visitSingularDoubleField(value: self.latitude, fieldNumber: 3)
    }
    if self.longitude != 0 {
      try visitor.visitSingularDoubleField(value: self.longitude, fieldNumber: 4)
    }
    if self.lowerLatitude != 0 {
      try visitor.visitSingularDoubleField(value: self.lowerLatitude, fieldNumber: 5)
    }
    if self.lowerLongitude != 0 {
      try visitor.visitSingularDoubleField(value: self.lowerLongitude, fieldNumber: 6)
    }
    if self.upperLatitude != 0 {
      try visitor.visitSingularDoubleField(value: self.upperLatitude, fieldNumber: 7)
    }
    if self.upperLongitude != 0 {
      try visitor.visitSingularDoubleField(value: self.upperLongitude, fieldNumber: 8)
    }
    if !self.fiasID.isEmpty {
      try visitor.visitSingularStringField(value: self.fiasID, fieldNumber: 9)
    }
    try unknownFields.traverse(visitor: &visitor)
  }
}

struct DidSelectMenuDto: SwiftProtobuf.Message {
  static let protoMessageName: String = "DidSelectMenuDto"

  var menuID: Int64 = 0

  var unknownFields = SwiftProtobuf.UnknownStorage()

  init() {}

  /// Used by the decoding initializers in the SwiftProtobuf library, not generally
  /// used directly. `init(serializedData:)`, `init(jsonUTF8Data:)`, and other decoding
  /// initializers are defined in the SwiftProtobuf library. See the Message and
  /// Message+*Additions` files.
  mutating func decodeMessage<D: SwiftProtobuf.Decoder>(decoder: inout D) throws {
    while let fieldNumber = try decoder.nextFieldNumber() {
      switch fieldNumber {
      case 1: try decoder.decodeSingularInt64Field(value: &self.menuID)
      default: break
      }
    }
  }

  /// Used by the encoding methods of the SwiftProtobuf library, not generally
  /// used directly. `Message.serializedData()`, `Message.jsonUTF8Data()`, and
  /// other serializer methods are defined in the SwiftProtobuf library. See the
  /// `Message` and `Message+*Additions` files.
  func traverse<V: SwiftProtobuf.Visitor>(visitor: inout V) throws {
    if self.menuID != 0 {
      try visitor.visitSingularInt64Field(value: self.menuID, fieldNumber: 1)
    }
    try unknownFields.traverse(visitor: &visitor)
  }
}

struct CategoriesDto: SwiftProtobuf.Message {
  static let protoMessageName: String = "CategoriesDto"

  var categories: [CategoryDto] = []

  var unknownFields = SwiftProtobuf.UnknownStorage()

  init() {}

  /// Used by the decoding initializers in the SwiftProtobuf library, not generally
  /// used directly. `init(serializedData:)`, `init(jsonUTF8Data:)`, and other decoding
  /// initializers are defined in the SwiftProtobuf library. See the Message and
  /// Message+*Additions` files.
  mutating func decodeMessage<D: SwiftProtobuf.Decoder>(decoder: inout D) throws {
    while let fieldNumber = try decoder.nextFieldNumber() {
      switch fieldNumber {
      case 1: try decoder.decodeRepeatedMessageField(value: &self.categories)
      default: break
      }
    }
  }

  /// Used by the encoding methods of the SwiftProtobuf library, not generally
  /// used directly. `Message.serializedData()`, `Message.jsonUTF8Data()`, and
  /// other serializer methods are defined in the SwiftProtobuf library. See the
  /// `Message` and `Message+*Additions` files.
  func traverse<V: SwiftProtobuf.Visitor>(visitor: inout V) throws {
    if !self.categories.isEmpty {
      try visitor.visitRepeatedMessageField(value: self.categories, fieldNumber: 1)
    }
    try unknownFields.traverse(visitor: &visitor)
  }
}

struct CategoryDto: SwiftProtobuf.Message {
  static let protoMessageName: String = "CategoryDto"

  var name: String = String()

  var products: [ProductDto] = []

  var unknownFields = SwiftProtobuf.UnknownStorage()

  init() {}

  /// Used by the decoding initializers in the SwiftProtobuf library, not generally
  /// used directly. `init(serializedData:)`, `init(jsonUTF8Data:)`, and other decoding
  /// initializers are defined in the SwiftProtobuf library. See the Message and
  /// Message+*Additions` files.
  mutating func decodeMessage<D: SwiftProtobuf.Decoder>(decoder: inout D) throws {
    while let fieldNumber = try decoder.nextFieldNumber() {
      switch fieldNumber {
      case 1: try decoder.decodeSingularStringField(value: &self.name)
      case 2: try decoder.decodeRepeatedMessageField(value: &self.products)
      default: break
      }
    }
  }

  /// Used by the encoding methods of the SwiftProtobuf library, not generally
  /// used directly. `Message.serializedData()`, `Message.jsonUTF8Data()`, and
  /// other serializer methods are defined in the SwiftProtobuf library. See the
  /// `Message` and `Message+*Additions` files.
  func traverse<V: SwiftProtobuf.Visitor>(visitor: inout V) throws {
    if !self.name.isEmpty {
      try visitor.visitSingularStringField(value: self.name, fieldNumber: 1)
    }
    if !self.products.isEmpty {
      try visitor.visitRepeatedMessageField(value: self.products, fieldNumber: 2)
    }
    try unknownFields.traverse(visitor: &visitor)
  }
}

struct RecommendationsDto: SwiftProtobuf.Message {
  static let protoMessageName: String = "RecommendationsDto"

  var products: [ProductDto] = []

  var unknownFields = SwiftProtobuf.UnknownStorage()

  init() {}

  /// Used by the decoding initializers in the SwiftProtobuf library, not generally
  /// used directly. `init(serializedData:)`, `init(jsonUTF8Data:)`, and other decoding
  /// initializers are defined in the SwiftProtobuf library. See the Message and
  /// Message+*Additions` files.
  mutating func decodeMessage<D: SwiftProtobuf.Decoder>(decoder: inout D) throws {
    while let fieldNumber = try decoder.nextFieldNumber() {
      switch fieldNumber {
      case 1: try decoder.decodeRepeatedMessageField(value: &self.products)
      default: break
      }
    }
  }

  /// Used by the encoding methods of the SwiftProtobuf library, not generally
  /// used directly. `Message.serializedData()`, `Message.jsonUTF8Data()`, and
  /// other serializer methods are defined in the SwiftProtobuf library. See the
  /// `Message` and `Message+*Additions` files.
  func traverse<V: SwiftProtobuf.Visitor>(visitor: inout V) throws {
    if !self.products.isEmpty {
      try visitor.visitRepeatedMessageField(value: self.products, fieldNumber: 1)
    }
    try unknownFields.traverse(visitor: &visitor)
  }
}

struct ProductDto: SwiftProtobuf.Message {
  static let protoMessageName: String = "ProductDto"

  var name: String {
    get {return _storage._name}
    set {_uniqueStorage()._name = newValue}
  }

  var subheading: String {
    get {return _storage._subheading}
    set {_uniqueStorage()._subheading = newValue}
  }

  var pricing: [PriceDto] {
    get {return _storage._pricing}
    set {_uniqueStorage()._pricing = newValue}
  }

  var photo: PhotoDto {
    get {return _storage._photo ?? PhotoDto()}
    set {_uniqueStorage()._photo = newValue}
  }
  /// Returns true if `photo` has been explicitly set.
  var hasPhoto: Bool {return _storage._photo != nil}
  /// Clears the value of `photo`. Subsequent reads from it will return its default value.
  mutating func clearPhoto() {_storage._photo = nil}

  var unknownFields = SwiftProtobuf.UnknownStorage()

  init() {}

  /// Used by the decoding initializers in the SwiftProtobuf library, not generally
  /// used directly. `init(serializedData:)`, `init(jsonUTF8Data:)`, and other decoding
  /// initializers are defined in the SwiftProtobuf library. See the Message and
  /// Message+*Additions` files.
  mutating func decodeMessage<D: SwiftProtobuf.Decoder>(decoder: inout D) throws {
    _ = _uniqueStorage()
    try withExtendedLifetime(_storage) { (_storage: _StorageClass) in
      while let fieldNumber = try decoder.nextFieldNumber() {
        switch fieldNumber {
        case 1: try decoder.decodeSingularStringField(value: &_storage._name)
        case 2: try decoder.decodeSingularStringField(value: &_storage._subheading)
        case 3: try decoder.decodeRepeatedMessageField(value: &_storage._pricing)
        case 4: try decoder.decodeSingularMessageField(value: &_storage._photo)
        default: break
        }
      }
    }
  }

  /// Used by the encoding methods of the SwiftProtobuf library, not generally
  /// used directly. `Message.serializedData()`, `Message.jsonUTF8Data()`, and
  /// other serializer methods are defined in the SwiftProtobuf library. See the
  /// `Message` and `Message+*Additions` files.
  func traverse<V: SwiftProtobuf.Visitor>(visitor: inout V) throws {
    try withExtendedLifetime(_storage) { (_storage: _StorageClass) in
      if !_storage._name.isEmpty {
        try visitor.visitSingularStringField(value: _storage._name, fieldNumber: 1)
      }
      if !_storage._subheading.isEmpty {
        try visitor.visitSingularStringField(value: _storage._subheading, fieldNumber: 2)
      }
      if !_storage._pricing.isEmpty {
        try visitor.visitRepeatedMessageField(value: _storage._pricing, fieldNumber: 3)
      }
      if let v = _storage._photo {
        try visitor.visitSingularMessageField(value: v, fieldNumber: 4)
      }
    }
    try unknownFields.traverse(visitor: &visitor)
  }

  fileprivate var _storage = _StorageClass.defaultInstance
}

struct PriceDto: SwiftProtobuf.Message {
  static let protoMessageName: String = "PriceDto"

  var value: Double = 0

  var modifier: String = String()

  var unknownFields = SwiftProtobuf.UnknownStorage()

  init() {}

  /// Used by the decoding initializers in the SwiftProtobuf library, not generally
  /// used directly. `init(serializedData:)`, `init(jsonUTF8Data:)`, and other decoding
  /// initializers are defined in the SwiftProtobuf library. See the Message and
  /// Message+*Additions` files.
  mutating func decodeMessage<D: SwiftProtobuf.Decoder>(decoder: inout D) throws {
    while let fieldNumber = try decoder.nextFieldNumber() {
      switch fieldNumber {
      case 1: try decoder.decodeSingularDoubleField(value: &self.value)
      case 2: try decoder.decodeSingularStringField(value: &self.modifier)
      default: break
      }
    }
  }

  /// Used by the encoding methods of the SwiftProtobuf library, not generally
  /// used directly. `Message.serializedData()`, `Message.jsonUTF8Data()`, and
  /// other serializer methods are defined in the SwiftProtobuf library. See the
  /// `Message` and `Message+*Additions` files.
  func traverse<V: SwiftProtobuf.Visitor>(visitor: inout V) throws {
    if self.value != 0 {
      try visitor.visitSingularDoubleField(value: self.value, fieldNumber: 1)
    }
    if !self.modifier.isEmpty {
      try visitor.visitSingularStringField(value: self.modifier, fieldNumber: 2)
    }
    try unknownFields.traverse(visitor: &visitor)
  }
}

struct PhotoDto: SwiftProtobuf.Message {
  static let protoMessageName: String = "PhotoDto"

  var height: Int32 = 0

  var width: Int32 = 0

  var url: String = String()

  var unknownFields = SwiftProtobuf.UnknownStorage()

  init() {}

  /// Used by the decoding initializers in the SwiftProtobuf library, not generally
  /// used directly. `init(serializedData:)`, `init(jsonUTF8Data:)`, and other decoding
  /// initializers are defined in the SwiftProtobuf library. See the Message and
  /// Message+*Additions` files.
  mutating func decodeMessage<D: SwiftProtobuf.Decoder>(decoder: inout D) throws {
    while let fieldNumber = try decoder.nextFieldNumber() {
      switch fieldNumber {
      case 1: try decoder.decodeSingularInt32Field(value: &self.height)
      case 2: try decoder.decodeSingularInt32Field(value: &self.width)
      case 3: try decoder.decodeSingularStringField(value: &self.url)
      default: break
      }
    }
  }

  /// Used by the encoding methods of the SwiftProtobuf library, not generally
  /// used directly. `Message.serializedData()`, `Message.jsonUTF8Data()`, and
  /// other serializer methods are defined in the SwiftProtobuf library. See the
  /// `Message` and `Message+*Additions` files.
  func traverse<V: SwiftProtobuf.Visitor>(visitor: inout V) throws {
    if self.height != 0 {
      try visitor.visitSingularInt32Field(value: self.height, fieldNumber: 1)
    }
    if self.width != 0 {
      try visitor.visitSingularInt32Field(value: self.width, fieldNumber: 2)
    }
    if !self.url.isEmpty {
      try visitor.visitSingularStringField(value: self.url, fieldNumber: 3)
    }
    try unknownFields.traverse(visitor: &visitor)
  }
}

struct UserMessage: SwiftProtobuf.Message {
  static let protoMessageName: String = "UserMessage"

  var type: OneOf_Type? {
    get {return _storage._type}
    set {_uniqueStorage()._type = newValue}
  }

  var didSelectMenu: DidSelectMenuDto {
    get {
      if case .didSelectMenu(let v)? = _storage._type {return v}
      return DidSelectMenuDto()
    }
    set {_uniqueStorage()._type = .didSelectMenu(newValue)}
  }

  var getMenu: GetMenuDto {
    get {
      if case .getMenu(let v)? = _storage._type {return v}
      return GetMenuDto()
    }
    set {_uniqueStorage()._type = .getMenu(newValue)}
  }

  var unknownFields = SwiftProtobuf.UnknownStorage()

  enum OneOf_Type: Equatable {
    case didSelectMenu(DidSelectMenuDto)
    case getMenu(GetMenuDto)

    static func ==(lhs: UserMessage.OneOf_Type, rhs: UserMessage.OneOf_Type) -> Bool {
      switch (lhs, rhs) {
      case (.didSelectMenu(let l), .didSelectMenu(let r)): return l == r
      case (.getMenu(let l), .getMenu(let r)): return l == r
      default: return false
      }
    }
  }

  init() {}

  /// Used by the decoding initializers in the SwiftProtobuf library, not generally
  /// used directly. `init(serializedData:)`, `init(jsonUTF8Data:)`, and other decoding
  /// initializers are defined in the SwiftProtobuf library. See the Message and
  /// Message+*Additions` files.
  mutating func decodeMessage<D: SwiftProtobuf.Decoder>(decoder: inout D) throws {
    _ = _uniqueStorage()
    try withExtendedLifetime(_storage) { (_storage: _StorageClass) in
      while let fieldNumber = try decoder.nextFieldNumber() {
        switch fieldNumber {
        case 1:
          var v: DidSelectMenuDto?
          if let current = _storage._type {
            try decoder.handleConflictingOneOf()
            if case .didSelectMenu(let m) = current {v = m}
          }
          try decoder.decodeSingularMessageField(value: &v)
          if let v = v {_storage._type = .didSelectMenu(v)}
        case 2:
          var v: GetMenuDto?
          if let current = _storage._type {
            try decoder.handleConflictingOneOf()
            if case .getMenu(let m) = current {v = m}
          }
          try decoder.decodeSingularMessageField(value: &v)
          if let v = v {_storage._type = .getMenu(v)}
        default: break
        }
      }
    }
  }

  /// Used by the encoding methods of the SwiftProtobuf library, not generally
  /// used directly. `Message.serializedData()`, `Message.jsonUTF8Data()`, and
  /// other serializer methods are defined in the SwiftProtobuf library. See the
  /// `Message` and `Message+*Additions` files.
  func traverse<V: SwiftProtobuf.Visitor>(visitor: inout V) throws {
    try withExtendedLifetime(_storage) { (_storage: _StorageClass) in
      switch _storage._type {
      case .didSelectMenu(let v)?:
        try visitor.visitSingularMessageField(value: v, fieldNumber: 1)
      case .getMenu(let v)?:
        try visitor.visitSingularMessageField(value: v, fieldNumber: 2)
      case nil: break
      }
    }
    try unknownFields.traverse(visitor: &visitor)
  }

  fileprivate var _storage = _StorageClass.defaultInstance
}

struct FoodServiceMessage: SwiftProtobuf.Message {
  static let protoMessageName: String = "FoodServiceMessage"

  var type: OneOf_Type? {
    get {return _storage._type}
    set {_uniqueStorage()._type = newValue}
  }

  var selectMenu: SelectMenuDto {
    get {
      if case .selectMenu(let v)? = _storage._type {return v}
      return SelectMenuDto()
    }
    set {_uniqueStorage()._type = .selectMenu(newValue)}
  }

  var didUpdateTermsOfServices: DidUpdateTermsOfServicesDto {
    get {
      if case .didUpdateTermsOfServices(let v)? = _storage._type {return v}
      return DidUpdateTermsOfServicesDto()
    }
    set {_uniqueStorage()._type = .didUpdateTermsOfServices(newValue)}
  }

  var categories: CategoriesDto {
    get {
      if case .categories(let v)? = _storage._type {return v}
      return CategoriesDto()
    }
    set {_uniqueStorage()._type = .categories(newValue)}
  }

  var recommendations: RecommendationsDto {
    get {
      if case .recommendations(let v)? = _storage._type {return v}
      return RecommendationsDto()
    }
    set {_uniqueStorage()._type = .recommendations(newValue)}
  }

  var unknownFields = SwiftProtobuf.UnknownStorage()

  enum OneOf_Type: Equatable {
    case selectMenu(SelectMenuDto)
    case didUpdateTermsOfServices(DidUpdateTermsOfServicesDto)
    case categories(CategoriesDto)
    case recommendations(RecommendationsDto)

    static func ==(lhs: FoodServiceMessage.OneOf_Type, rhs: FoodServiceMessage.OneOf_Type) -> Bool {
      switch (lhs, rhs) {
      case (.selectMenu(let l), .selectMenu(let r)): return l == r
      case (.didUpdateTermsOfServices(let l), .didUpdateTermsOfServices(let r)): return l == r
      case (.categories(let l), .categories(let r)): return l == r
      case (.recommendations(let l), .recommendations(let r)): return l == r
      default: return false
      }
    }
  }

  init() {}

  /// Used by the decoding initializers in the SwiftProtobuf library, not generally
  /// used directly. `init(serializedData:)`, `init(jsonUTF8Data:)`, and other decoding
  /// initializers are defined in the SwiftProtobuf library. See the Message and
  /// Message+*Additions` files.
  mutating func decodeMessage<D: SwiftProtobuf.Decoder>(decoder: inout D) throws {
    _ = _uniqueStorage()
    try withExtendedLifetime(_storage) { (_storage: _StorageClass) in
      while let fieldNumber = try decoder.nextFieldNumber() {
        switch fieldNumber {
        case 1:
          var v: SelectMenuDto?
          if let current = _storage._type {
            try decoder.handleConflictingOneOf()
            if case .selectMenu(let m) = current {v = m}
          }
          try decoder.decodeSingularMessageField(value: &v)
          if let v = v {_storage._type = .selectMenu(v)}
        case 2:
          var v: DidUpdateTermsOfServicesDto?
          if let current = _storage._type {
            try decoder.handleConflictingOneOf()
            if case .didUpdateTermsOfServices(let m) = current {v = m}
          }
          try decoder.decodeSingularMessageField(value: &v)
          if let v = v {_storage._type = .didUpdateTermsOfServices(v)}
        case 3:
          var v: CategoriesDto?
          if let current = _storage._type {
            try decoder.handleConflictingOneOf()
            if case .categories(let m) = current {v = m}
          }
          try decoder.decodeSingularMessageField(value: &v)
          if let v = v {_storage._type = .categories(v)}
        case 4:
          var v: RecommendationsDto?
          if let current = _storage._type {
            try decoder.handleConflictingOneOf()
            if case .recommendations(let m) = current {v = m}
          }
          try decoder.decodeSingularMessageField(value: &v)
          if let v = v {_storage._type = .recommendations(v)}
        default: break
        }
      }
    }
  }

  /// Used by the encoding methods of the SwiftProtobuf library, not generally
  /// used directly. `Message.serializedData()`, `Message.jsonUTF8Data()`, and
  /// other serializer methods are defined in the SwiftProtobuf library. See the
  /// `Message` and `Message+*Additions` files.
  func traverse<V: SwiftProtobuf.Visitor>(visitor: inout V) throws {
    try withExtendedLifetime(_storage) { (_storage: _StorageClass) in
      switch _storage._type {
      case .selectMenu(let v)?:
        try visitor.visitSingularMessageField(value: v, fieldNumber: 1)
      case .didUpdateTermsOfServices(let v)?:
        try visitor.visitSingularMessageField(value: v, fieldNumber: 2)
      case .categories(let v)?:
        try visitor.visitSingularMessageField(value: v, fieldNumber: 3)
      case .recommendations(let v)?:
        try visitor.visitSingularMessageField(value: v, fieldNumber: 4)
      case nil: break
      }
    }
    try unknownFields.traverse(visitor: &visitor)
  }

  fileprivate var _storage = _StorageClass.defaultInstance
}

// MARK: - Code below here is support for the SwiftProtobuf runtime.

extension GetMenuDto: SwiftProtobuf._MessageImplementationBase, SwiftProtobuf._ProtoNameProviding {
  static let _protobuf_nameMap = SwiftProtobuf._NameMap()

  func _protobuf_generated_isEqualTo(other: GetMenuDto) -> Bool {
    if unknownFields != other.unknownFields {return false}
    return true
  }
}

extension SelectMenuDto: SwiftProtobuf._MessageImplementationBase, SwiftProtobuf._ProtoNameProviding {
  static let _protobuf_nameMap: SwiftProtobuf._NameMap = [
    1: .same(proto: "menus"),
  ]

  func _protobuf_generated_isEqualTo(other: SelectMenuDto) -> Bool {
    if self.menus != other.menus {return false}
    if unknownFields != other.unknownFields {return false}
    return true
  }
}

extension DidUpdateTermsOfServicesDto: SwiftProtobuf._MessageImplementationBase, SwiftProtobuf._ProtoNameProviding {
  static let _protobuf_nameMap = SwiftProtobuf._NameMap()

  func _protobuf_generated_isEqualTo(other: DidUpdateTermsOfServicesDto) -> Bool {
    if unknownFields != other.unknownFields {return false}
    return true
  }
}

extension MenuDto: SwiftProtobuf._MessageImplementationBase, SwiftProtobuf._ProtoNameProviding {
  static let _protobuf_nameMap: SwiftProtobuf._NameMap = [
    1: .same(proto: "menuId"),
    2: .same(proto: "locality"),
  ]

  fileprivate class _StorageClass {
    var _menuID: Int64 = 0
    var _locality: LocalityDto? = nil

    static let defaultInstance = _StorageClass()

    private init() {}

    init(copying source: _StorageClass) {
      _menuID = source._menuID
      _locality = source._locality
    }
  }

  fileprivate mutating func _uniqueStorage() -> _StorageClass {
    if !isKnownUniquelyReferenced(&_storage) {
      _storage = _StorageClass(copying: _storage)
    }
    return _storage
  }

  func _protobuf_generated_isEqualTo(other: MenuDto) -> Bool {
    if _storage !== other._storage {
      let storagesAreEqual: Bool = withExtendedLifetime((_storage, other._storage)) { (_args: (_StorageClass, _StorageClass)) in
        let _storage = _args.0
        let other_storage = _args.1
        if _storage._menuID != other_storage._menuID {return false}
        if _storage._locality != other_storage._locality {return false}
        return true
      }
      if !storagesAreEqual {return false}
    }
    if unknownFields != other.unknownFields {return false}
    return true
  }
}

extension LocalityDto: SwiftProtobuf._MessageImplementationBase, SwiftProtobuf._ProtoNameProviding {
  static let _protobuf_nameMap: SwiftProtobuf._NameMap = [
    1: .same(proto: "name"),
    2: .same(proto: "descr"),
    3: .same(proto: "latitude"),
    4: .same(proto: "longitude"),
    5: .same(proto: "lowerLatitude"),
    6: .same(proto: "lowerLongitude"),
    7: .same(proto: "upperLatitude"),
    8: .same(proto: "upperLongitude"),
    9: .same(proto: "fiasId"),
  ]

  func _protobuf_generated_isEqualTo(other: LocalityDto) -> Bool {
    if self.name != other.name {return false}
    if self.descr != other.descr {return false}
    if self.latitude != other.latitude {return false}
    if self.longitude != other.longitude {return false}
    if self.lowerLatitude != other.lowerLatitude {return false}
    if self.lowerLongitude != other.lowerLongitude {return false}
    if self.upperLatitude != other.upperLatitude {return false}
    if self.upperLongitude != other.upperLongitude {return false}
    if self.fiasID != other.fiasID {return false}
    if unknownFields != other.unknownFields {return false}
    return true
  }
}

extension DidSelectMenuDto: SwiftProtobuf._MessageImplementationBase, SwiftProtobuf._ProtoNameProviding {
  static let _protobuf_nameMap: SwiftProtobuf._NameMap = [
    1: .same(proto: "menuId"),
  ]

  func _protobuf_generated_isEqualTo(other: DidSelectMenuDto) -> Bool {
    if self.menuID != other.menuID {return false}
    if unknownFields != other.unknownFields {return false}
    return true
  }
}

extension CategoriesDto: SwiftProtobuf._MessageImplementationBase, SwiftProtobuf._ProtoNameProviding {
  static let _protobuf_nameMap: SwiftProtobuf._NameMap = [
    1: .same(proto: "categories"),
  ]

  func _protobuf_generated_isEqualTo(other: CategoriesDto) -> Bool {
    if self.categories != other.categories {return false}
    if unknownFields != other.unknownFields {return false}
    return true
  }
}

extension CategoryDto: SwiftProtobuf._MessageImplementationBase, SwiftProtobuf._ProtoNameProviding {
  static let _protobuf_nameMap: SwiftProtobuf._NameMap = [
    1: .same(proto: "name"),
    2: .same(proto: "products"),
  ]

  func _protobuf_generated_isEqualTo(other: CategoryDto) -> Bool {
    if self.name != other.name {return false}
    if self.products != other.products {return false}
    if unknownFields != other.unknownFields {return false}
    return true
  }
}

extension RecommendationsDto: SwiftProtobuf._MessageImplementationBase, SwiftProtobuf._ProtoNameProviding {
  static let _protobuf_nameMap: SwiftProtobuf._NameMap = [
    1: .same(proto: "products"),
  ]

  func _protobuf_generated_isEqualTo(other: RecommendationsDto) -> Bool {
    if self.products != other.products {return false}
    if unknownFields != other.unknownFields {return false}
    return true
  }
}

extension ProductDto: SwiftProtobuf._MessageImplementationBase, SwiftProtobuf._ProtoNameProviding {
  static let _protobuf_nameMap: SwiftProtobuf._NameMap = [
    1: .same(proto: "name"),
    2: .same(proto: "subheading"),
    3: .same(proto: "pricing"),
    4: .same(proto: "photo"),
  ]

  fileprivate class _StorageClass {
    var _name: String = String()
    var _subheading: String = String()
    var _pricing: [PriceDto] = []
    var _photo: PhotoDto? = nil

    static let defaultInstance = _StorageClass()

    private init() {}

    init(copying source: _StorageClass) {
      _name = source._name
      _subheading = source._subheading
      _pricing = source._pricing
      _photo = source._photo
    }
  }

  fileprivate mutating func _uniqueStorage() -> _StorageClass {
    if !isKnownUniquelyReferenced(&_storage) {
      _storage = _StorageClass(copying: _storage)
    }
    return _storage
  }

  func _protobuf_generated_isEqualTo(other: ProductDto) -> Bool {
    if _storage !== other._storage {
      let storagesAreEqual: Bool = withExtendedLifetime((_storage, other._storage)) { (_args: (_StorageClass, _StorageClass)) in
        let _storage = _args.0
        let other_storage = _args.1
        if _storage._name != other_storage._name {return false}
        if _storage._subheading != other_storage._subheading {return false}
        if _storage._pricing != other_storage._pricing {return false}
        if _storage._photo != other_storage._photo {return false}
        return true
      }
      if !storagesAreEqual {return false}
    }
    if unknownFields != other.unknownFields {return false}
    return true
  }
}

extension PriceDto: SwiftProtobuf._MessageImplementationBase, SwiftProtobuf._ProtoNameProviding {
  static let _protobuf_nameMap: SwiftProtobuf._NameMap = [
    1: .same(proto: "value"),
    2: .same(proto: "modifier"),
  ]

  func _protobuf_generated_isEqualTo(other: PriceDto) -> Bool {
    if self.value != other.value {return false}
    if self.modifier != other.modifier {return false}
    if unknownFields != other.unknownFields {return false}
    return true
  }
}

extension PhotoDto: SwiftProtobuf._MessageImplementationBase, SwiftProtobuf._ProtoNameProviding {
  static let _protobuf_nameMap: SwiftProtobuf._NameMap = [
    1: .same(proto: "height"),
    2: .same(proto: "width"),
    3: .same(proto: "url"),
  ]

  func _protobuf_generated_isEqualTo(other: PhotoDto) -> Bool {
    if self.height != other.height {return false}
    if self.width != other.width {return false}
    if self.url != other.url {return false}
    if unknownFields != other.unknownFields {return false}
    return true
  }
}

extension UserMessage: SwiftProtobuf._MessageImplementationBase, SwiftProtobuf._ProtoNameProviding {
  static let _protobuf_nameMap: SwiftProtobuf._NameMap = [
    1: .same(proto: "didSelectMenu"),
    2: .same(proto: "getMenu"),
  ]

  fileprivate class _StorageClass {
    var _type: UserMessage.OneOf_Type?

    static let defaultInstance = _StorageClass()

    private init() {}

    init(copying source: _StorageClass) {
      _type = source._type
    }
  }

  fileprivate mutating func _uniqueStorage() -> _StorageClass {
    if !isKnownUniquelyReferenced(&_storage) {
      _storage = _StorageClass(copying: _storage)
    }
    return _storage
  }

  func _protobuf_generated_isEqualTo(other: UserMessage) -> Bool {
    if _storage !== other._storage {
      let storagesAreEqual: Bool = withExtendedLifetime((_storage, other._storage)) { (_args: (_StorageClass, _StorageClass)) in
        let _storage = _args.0
        let other_storage = _args.1
        if _storage._type != other_storage._type {return false}
        return true
      }
      if !storagesAreEqual {return false}
    }
    if unknownFields != other.unknownFields {return false}
    return true
  }
}

extension FoodServiceMessage: SwiftProtobuf._MessageImplementationBase, SwiftProtobuf._ProtoNameProviding {
  static let _protobuf_nameMap: SwiftProtobuf._NameMap = [
    1: .same(proto: "selectMenu"),
    2: .same(proto: "didUpdateTermsOfServices"),
    3: .same(proto: "categories"),
    4: .same(proto: "recommendations"),
  ]

  fileprivate class _StorageClass {
    var _type: FoodServiceMessage.OneOf_Type?

    static let defaultInstance = _StorageClass()

    private init() {}

    init(copying source: _StorageClass) {
      _type = source._type
    }
  }

  fileprivate mutating func _uniqueStorage() -> _StorageClass {
    if !isKnownUniquelyReferenced(&_storage) {
      _storage = _StorageClass(copying: _storage)
    }
    return _storage
  }

  func _protobuf_generated_isEqualTo(other: FoodServiceMessage) -> Bool {
    if _storage !== other._storage {
      let storagesAreEqual: Bool = withExtendedLifetime((_storage, other._storage)) { (_args: (_StorageClass, _StorageClass)) in
        let _storage = _args.0
        let other_storage = _args.1
        if _storage._type != other_storage._type {return false}
        return true
      }
      if !storagesAreEqual {return false}
    }
    if unknownFields != other.unknownFields {return false}
    return true
  }
}