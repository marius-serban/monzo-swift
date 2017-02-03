import Foundation

typealias JsonObject = [String: Any]

protocol JsonInitializable {
    init(jsonObject: JsonObject) throws
    static var nestedObjectKey: String? { get }
}

protocol JsonArrayInitializable : JsonInitializable {
    static var arrayKey: String { get }
}

extension JsonInitializable {
    static var nestedObjectKey: String? { return nil }
}

// FIXME: cleanup when SE-0143 gets implemented
protocol StringProtocol { }
extension String : StringProtocol { }
extension Dictionary where Key: StringProtocol {
    func value<T>(forKey key: Key) throws -> T {
        guard let value = self[key] as? T else { throw ClientError.parsingError }
        return value
    }
}

extension Array where Element : JsonArrayInitializable {
    init(jsonObject: JsonObject) throws {
        let jsonArray = try jsonObject.value(forKey: Element.arrayKey) as [JsonObject]
        let elements = try jsonArray.map(Element.init)
        self.init(elements)
    }
}

extension JsonInitializable {
    static func iso8601Date(_ string: String) throws -> Date {
        if let date = DateFormatter.iso8601Formatter().date(from: string) {
            return date
        } else {
            throw ClientError.parsingError
        }
    }
}

extension DateFormatter {
    static func iso8601Formatter() -> DateFormatter {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.timeZone = TimeZone(secondsFromGMT: 0)!
        formatter.dateFormat = "yyyy'-'MM'-'dd'T'HH':'mm':'ss.SSXX"
        return formatter
    }
}
