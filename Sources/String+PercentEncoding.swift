import Foundation

extension String {
    
    func urlQueryPercentEncoded() throws -> String {
        guard let escaped = addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) else { throw ClientError.parameterEncodingError }
        return escaped
    }
    
    func urlFormPercentEncoded() throws -> String {
        // according to RFC 3986
        var allowed = CharacterSet.alphanumerics
        allowed.insert(charactersIn: "-._~")
        let encodedComponents = components(separatedBy: " ").flatMap { component in
            return component.addingPercentEncoding(withAllowedCharacters: allowed)
        }
        return encodedComponents.joined(separator: "+")
    }
}
