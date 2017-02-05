import Foundation

struct Parameters : ExpressibleByDictionaryLiteral, ExpressibleByArrayLiteral {
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
    
    // convenience initializer useful for mixed but static parameter values
    init(dictionaryLiteral elements: (String, Parameter.Value)...) {
        self.init(elements.map(Parameter.init))
    }
    
    // convenience initializer useful for only simple parameter values
    init(arrayLiteral elements: (String, String)...) {
        self.init(elements.map(Parameter.init))
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
    
    init(_ name: String, _ value: Value) {
        self.name = name
        self.value = value
    }
    
    init(_ name: String, _ value: String) {
        self.init(name, .simple(value))
    }
    
    init(_ name: String, _ values: [String]) {
        self.init(name, .array(values))
    }
    
    init(_ name: String, _ values: [String: String]) {
        self.init(name, .dictionary(values))
    }
}

extension Parameter.Value : ExpressibleByStringLiteral {
    public init(stringLiteral value: String) {
        self = .simple(value)
    }
    
    public init(extendedGraphemeClusterLiteral value: String) {
        self.init(stringLiteral: value)
    }
    
    public init(unicodeScalarLiteral value: String) {
        self.init(stringLiteral: value)
    }
}

extension Parameter.Value : ExpressibleByArrayLiteral {
    public init(arrayLiteral elements: String...) {
        switch elements.count {
        case 0:
            self = .simple("")
        case 1:
            self = .simple(elements[0])
        default:
            self = .array(elements)
        }
    }
}

extension Parameter.Value : ExpressibleByDictionaryLiteral {
    public init(dictionaryLiteral elements: (String, String)...) {
        var dictionary = [String: String]()
        elements.forEach {
            assert(dictionary[$0.0] == nil)
            dictionary[$0.0] = $0.1
        }
        self = .dictionary(dictionary)
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
