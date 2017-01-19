import S4
import Foundation

struct ApiRequest {
    let method: S4.Method
    let path: String
    let accessToken: String?
    let parameters: Parameters?
    
    init(method: S4.Method = .get, path: String, accessToken: String? = nil, parameters: Parameters? = nil) {
        self.method = method
        self.path = path
        self.accessToken = accessToken
        self.parameters = parameters
    }
}

extension Client {
    
    func deliver(_ request: ApiRequest) throws {
        let response = try httpClient.respond(to: request.request)
        try validateResponseStatus(response: response)
    }
    
    func retrieve<T: JsonInitializable>(_ request: ApiRequest) throws -> T {
        let jsonObject = try retrieve(request) as JsonObject
        return try T.init(jsonObject: jsonObject)
    }
    
    func retrieve(_ request: ApiRequest) throws -> JsonObject {
        let response = try httpClient.respond(to: request.request)
        try validateResponseStatus(response: response)
        return try parse(response.body.data)
    }
    
    private func validateResponseStatus(response: Response) throws {
        switch response.status.statusCode {
        case 0..<300 : return
        case 401: throw ClientError.accessTokenInvalid
        default: throw ClientError.responseError(response.status)
        }
    }
    
    private func parse(_ data: Foundation.Data) throws -> JsonObject {
        guard let json = try? JSONSerialization.jsonObject(with: data, options: [.allowFragments]), let jsonObject = json as? [String: Any] else { throw ClientError.parsingError }
        return jsonObject
    }
    
}

extension ApiRequest {
    fileprivate var request: Request {
        return Request(method: method, uri: uri, version: Version(major: 1, minor: 1), headers: headers, body: body)
    }
    
    private var uri: URI {
        return URI(scheme: "https", host: "api.monzo.com", path: path, query: query)
    }
    
    private var query: String? {
        if case .get = method, let parameters = parameters, !parameters.isEmpty {
            return parameters.urlQueryEncoded
        } else {
            return nil
        }
    }
    
    private var headers: Headers {
        var result = Headers([
            "host": "api.monzo.com",
            "connection": "close",
            ])
        switch method {
        case .post, .patch:
            result["content-type"] = "application/x-www-form-urlencoded; charset=utf-8"
        default: break
        }
        if let accessToken = accessToken {
            result["authorization"] = "Bearer \(accessToken)"
        }
        
        return result
    }
    
    private var body: Body {
        guard let parameters = parameters else { return .empty }
        switch method {
        case .post, .patch:
            return Body(parameters.urlFormEncoded)
        default:
            return .empty
        }
    }
}

extension Body {
    fileprivate static var empty: Body { return .buffer(Data([])) }
    
    fileprivate init(_ string: String) {
        let data = string.data(using: .utf8, allowLossyConversion: true)! // guaranteed not to be nil if the allowLossyConversion flag is true
        self = .buffer(Data([Byte](data)))
    }
    
    fileprivate var data: Foundation.Data {
        guard case .buffer(let data) = self else { return Data() }
        return Data(data.bytes)
    }
}
