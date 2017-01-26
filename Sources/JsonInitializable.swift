import Foundation

typealias JsonObject = [String: Any]

protocol JsonInitializable {
    init(jsonObject: JsonObject) throws
}

protocol JsonArrayInitializable : JsonInitializable {
    static var arrayKey: String { get }
}

extension Array where Element : JsonArrayInitializable {
    init(jsonObject: JsonObject) throws {
        let jsonArray = try jsonObject.value(forKey: Element.arrayKey) as [JsonObject]
        let elements = try jsonArray.map(Element.init)
        self.init(elements)
    }
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

extension Credentials : JsonInitializable {
    init(jsonObject: [String: Any]) throws {
        accessToken = try jsonObject.value(forKey: "access_token")
        clientId = try jsonObject.value(forKey: "client_id")
        expiresIn = UInt(try jsonObject.value(forKey: "expires_in") as Int)
        refreshToken = try jsonObject.value(forKey: "refresh_token")
        tokenType = try jsonObject.value(forKey: "token_type")
        userId = try jsonObject.value(forKey: "user_id")
    }
}

extension AccessTokenInfo : JsonInitializable {
    init(jsonObject: JsonObject) throws {
        let authenticated: Bool = try jsonObject.value(forKey: "authenticated")
        if authenticated {
            let clientId: String = try jsonObject.value(forKey: "client_id")
            let userId: String = try jsonObject.value(forKey: "user_id")
            self = .authenticated(clientId: clientId, userId: userId)
        } else {
            self = .notAuthenticated
        }
    }
}

extension Account : JsonInitializable {
    init(jsonObject: JsonObject) throws {
        let id: String = try jsonObject.value(forKey: "id")
        let created: String = try jsonObject.value(forKey: "created")
        let description: String = try jsonObject.value(forKey: "description")
        try self.init(id: id, created: created, description: description)
    }
    
    private init(id: String, created: String, description: String) throws {
        let iso8601Formatter = DateFormatter()
        iso8601Formatter.locale = Locale(identifier: "en_US_POSIX")
        iso8601Formatter.timeZone = TimeZone(secondsFromGMT: 0)!
        iso8601Formatter.dateFormat = "yyyy'-'MM'-'dd'T'HH':'mm':'ss.SSSZ"
        guard let dateCreated = iso8601Formatter.date(from: created) else { throw ClientError.parsingError }
        self.init(id: id, created: dateCreated, description: description)
    }
}

extension Account : JsonArrayInitializable {
    static var arrayKey: String { return "accounts" }
}

extension Balance : JsonInitializable {
    init(jsonObject: JsonObject) throws {
        // FIXME: balance and spendToday should be parsed as an 64 bit integer, currently doesn't work on linux
        balance = Int64(try jsonObject.value(forKey: "balance") as Int)
        currency = try jsonObject.value(forKey: "currency")
        spendToday = Int64(try jsonObject.value(forKey: "spend_today") as Int)
    }
}
