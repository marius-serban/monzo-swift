import Foundation

extension Client {
    public func transactions(accessToken: String, accountId: String, since: Since? = nil, before: Date? = nil, limit: UInt? = nil) throws -> [Transaction] {
        let parameters = Parameters([
            ("account_id", accountId),
            since.map({ ("since", $0.string) }),
            before.map({ ("before", DateFormatter.iso8601Formatter().string(from: $0)) }),
            limit.map({ ("limit", String($0)) })
            ].flatMap({ $0 }).map(Parameter.init))
        let transactionsRequest = ApiRequest(path: "transactions", accessToken: accessToken, parameters: parameters)
        
        return try retrieve(transactionsRequest)
    }
    
    public func transaction(accessToken: String, id: String) throws -> Transaction {
        let transactionRequest = ApiRequest(path: "transactions/\(id)", accessToken: accessToken)
        
        return try retrieve(transactionRequest)
    }
    
    public func annotate(transaction id: String, with metadata: [String: String], accessToken: String) throws {
        let parameter = Parameter("metadata", metadata)
        let annotateRequest = ApiRequest(method: .patch, path: "transactions/\(id)", accessToken: accessToken, parameters: Parameters(parameter))
        
        try deliver(annotateRequest)
    }
}

public enum Since {
    case date(Date)
    case transaction(String)
}

extension Since {
    fileprivate var string: String {
        switch self {
        case .date(let date): return DateFormatter.iso8601Formatter().string(from: date)
        case .transaction(let transactionId): return transactionId
        }
    }
}

//TODO: support for attachments, counterparty, decline_reason, expanded merchant
public struct Transaction {
    public let id: String
    public let created: Date
    public let description: String
    public let amount: Int
    public let currency: String
    public let merchant: String
    public let notes: String
    public let metadata: [String: String]
    public let accountBalance: Int
    public let category: String
    public let isLoad: Bool
    public let settled: Date
    public let localAmount: Int
    public let localCurrency: String
    public let updated: Date
    public let accountId: String
    public let scheme: String
    public let dedupeId: String
    public let originator: Bool
    public let includeInSpending: Bool
}

extension Transaction : JsonInitializable {
    static var nestedObjectKey: String? { return "transaction" }
    
    init(jsonObject: JsonObject) throws {
        id = try jsonObject.value(forKey: "id")
        created = try type(of: self).iso8601Date(jsonObject.value(forKey: "created"))
        description = try jsonObject.value(forKey: "description")
        amount = try jsonObject.value(forKey: "amount")
        currency = try jsonObject.value(forKey: "currency")
        merchant = try jsonObject.value(forKey: "merchant")
        notes = try jsonObject.value(forKey: "notes")
        metadata = try jsonObject.value(forKey: "metadata")
        accountBalance = try jsonObject.value(forKey: "account_balance")
        category = try jsonObject.value(forKey: "category")
        isLoad = try jsonObject.value(forKey: "is_load")
        settled = try type(of: self).iso8601Date(jsonObject.value(forKey: "settled"))
        localAmount = try jsonObject.value(forKey: "local_amount")
        localCurrency = try jsonObject.value(forKey: "local_currency")
        updated = try type(of: self).iso8601Date(jsonObject.value(forKey: "updated"))
        accountId = try jsonObject.value(forKey: "account_id")
        scheme = try jsonObject.value(forKey: "scheme")
        dedupeId = try jsonObject.value(forKey: "dedupe_id")
        originator = try jsonObject.value(forKey: "originator")
        includeInSpending = try jsonObject.value(forKey: "include_in_spending")
    }
}

extension Transaction : JsonArrayInitializable {
    static var arrayKey: String { return "transactions" }
}
