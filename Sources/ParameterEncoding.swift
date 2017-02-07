import Foundation

struct Parameters : ExpressibleByArrayLiteral {
    fileprivate var _storage: [String: Parameter.Value]
    
    init(_ parameters: [Parameter]) {
        var result: [String: Parameter.Value] = [:]
        parameters.forEach {
            assert(result[$0.name] == nil)
            result[$0.name] = $0.value
        }
        _storage = result
    }
    
    // convenience initializer useful for mixing simple with array parameter values
    init(_ parameters: Parameter ...) {
        self.init(parameters)
    }
    
    // convenience initializer useful for only simple parameter values
    init(arrayLiteral elements: (String, String)...) {
        self.init(elements.map({ Parameter($0.0, .simple($0.1)) }))
    }
    
    var isEmpty: Bool { return _storage.isEmpty }
}

struct Parameter {
    
    enum Value {
        case simple(String)
        case array([String])
        case dictionary([String: String])
    }
    
    let name: String
    let value: Value
    
    fileprivate init(_ name: String, _ value: Value) {
        self.name = name
        self.value = value
    }
    
    init(_ name: String, _ values: [String: String?]) {
        var dictionary = [String: String]()
        values.forEach { key, value in
            if let value = value {
                dictionary[key] = value
            }
        }
        self.init(name, .dictionary(dictionary))
    }
    
    init?(_ name: String, _ value: String?) {
        guard let value = value else { return nil }
        self.init(name, .simple(value))
    }
}

// MARK: URL Encoding (percent escaping)

extension Parameters {
    
    var urlQueryEncoded: String {
        return urlEncoded(percentEscaping: { $0.urlQueryPercentEncoded() })
    }
    var urlFormEncoded: String {
        return urlEncoded(percentEscaping: { $0.urlFormPercentEncoded() })
    }
    
    private func urlEncoded(percentEscaping: (String) -> String) -> String {
        let encodedParameters: [String] = _storage.map { parameter in
            let percentEncodedKey = percentEscaping(parameter.key)
            
            switch parameter.value {
                
            case .simple(let stringValue):
                let percentEncodedValue = percentEscaping(stringValue)
                return "\(percentEncodedKey)=\(percentEncodedValue)"
                
            case .array(let values):
                return values.map { value in
                    let percentEncodedValue = percentEscaping(value)
                    return "\(percentEncodedKey)[]=\(percentEncodedValue)"
                    }.joined(separator: "&")
            
            case .dictionary(let pairs):
                return pairs.map { pair in
                    let percentEncodedPairKey = percentEscaping(pair.key)
                    let percentEncodedPairValue = percentEscaping(pair.value)
                    return "\(percentEncodedKey)[\(percentEncodedPairKey)]=\(percentEncodedPairValue)"
                    }.joined(separator: "&")
            }
        }
        
        return encodedParameters.joined(separator: "&")
    }
}

extension String {
    
    fileprivate func urlQueryPercentEncoded() -> String {
        // can fail only fail because internal Foundation bugs or out of memory
        return addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!
    }
    
    fileprivate func urlFormPercentEncoded() -> String {
        // according to RFC 3986
        var allowed = CharacterSet.alphanumerics
        allowed.insert(charactersIn: "-._~")
        let encodedComponents = components(separatedBy: " ").map { component in
            // can fail only fail because internal Foundation bugs or out of memory
            return component.addingPercentEncoding(withAllowedCharacters: allowed)!
        }
        return encodedComponents.joined(separator: "+")
    }
}
