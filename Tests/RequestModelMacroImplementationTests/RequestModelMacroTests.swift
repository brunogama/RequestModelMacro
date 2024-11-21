import SwiftSyntaxMacros
import SwiftSyntaxMacrosTestSupport
import XCTest
import RequestModelMacroImplementation
@testable import RequestModelMacro

final class RequestModelMacroTests: XCTestCase {
    private let macros: [String: Macro.Type] = [
        "RequestModel": RequestModelMacro.self,
        "Header": HeaderMacro.self,
        "Body": BodyMacro.self,
    ]
    
    func testBasicRequestModel() {
        assertMacroExpansion(
            """
            @RequestModel
            struct BasicRequest {
                @Header
                var authorization: String
                
                @Body
                var message: String
            }
            """,
            expandedSource: """
            struct BasicRequest {
                var authorization: String {
                    get {
                        headers.authorization
                    }
                }

                var message: String {
                    get {
                        body.message
                    }
                }

                private struct Headers: Codable {
                    let authorization: String

                    enum CodingKeys: String, CodingKey {
                        case authorization
                    }
                }

                private struct Body: Codable {
                    let message: String

                    enum CodingKeys: String, CodingKey {
                        case message
                    }
                }

                var headersDictionary: [String: String] {
                    do {
                        let encoder = JSONEncoder()
                        let data = try encoder.encode(headers)
                        let jsonObject = try JSONSerialization.jsonObject(with: data, options: [])

                        if let dictionary = jsonObject as? [String: String] {
                            return dictionary
                        } else {
                            print("Warning: Failed to cast headers dictionary to [String: String]")
                            return [:]
                        }
                    } catch {
                        assertionFailure("Warning: Failed to encode headers: \\(error)")
                        return [:]
                    }
                }

                var bodyDictionary: [String: Any] {
                    do {
                        let encoder = JSONEncoder()
                        let data = try encoder.encode(body)
                        let jsonObject = try JSONSerialization.jsonObject(with: data, options: [])

                        if let dictionary = jsonObject as? [String: Any] {
                            return dictionary
                        } else {
                            print("Warning: Failed to cast body dictionary to [String: Any]")
                            return [:]
                        }
                    } catch {
                        assertionFailure("Warning: Failed to encode body: \\(error)")
                        return [:]
                    }
                }

                private var headers: Headers

                private var body: Body

                init(authorization: String, message: String) {
                    self.headers = Headers(authorization: authorization)
                    self.body = Body(message: message)
                }
            }
            """,
            macros: macros
        )
    }
    
    func testRequestModelWithCustomKeys() {
        assertMacroExpansion(
            """
            @RequestModel
            struct CustomKeyRequest {
                @Header("Authorization")
                var token: String
                
                @Body("payload")
                var message: String
            }
            """,
            expandedSource: """
            struct CustomKeyRequest {
                var token: String {
                    get {
                        headers.token
                    }
                }

                var message: String {
                    get {
                        body.message
                    }
                }

                private struct Headers: Codable {
                    let token: String

                    enum CodingKeys: String, CodingKey {
                        case token = "Authorization"
                    }
                }

                private struct Body: Codable {
                    let message: String

                    enum CodingKeys: String, CodingKey {
                        case message = "payload"
                    }
                }

                var headersDictionary: [String: String] {
                    do {
                        let encoder = JSONEncoder()
                        let data = try encoder.encode(headers)
                        let jsonObject = try JSONSerialization.jsonObject(with: data, options: [])

                        if let dictionary = jsonObject as? [String: String] {
                            return dictionary
                        } else {
                            print("Warning: Failed to cast headers dictionary to [String: String]")
                            return [:]
                        }
                    } catch {
                        assertionFailure("Warning: Failed to encode headers: \\(error)")
                        return [:]
                    }
                }

                var bodyDictionary: [String: Any] {
                    do {
                        let encoder = JSONEncoder()
                        let data = try encoder.encode(body)
                        let jsonObject = try JSONSerialization.jsonObject(with: data, options: [])

                        if let dictionary = jsonObject as? [String: Any] {
                            return dictionary
                        } else {
                            print("Warning: Failed to cast body dictionary to [String: Any]")
                            return [:]
                        }
                    } catch {
                        assertionFailure("Warning: Failed to encode body: \\(error)")
                        return [:]
                    }
                }

                private var headers: Headers

                private var body: Body

                init(token: String, message: String) {
                    self.headers = Headers(token: token)
                    self.body = Body(message: message)
                }
            }
            """,
            macros: macros
        )
    }
    
    func testEmptyHeadersAndBody() {
        assertMacroExpansion(
            """
            @RequestModel
            struct EmptyRequest {
            }
            """,
            expandedSource: """
            
            struct EmptyRequest {

                private struct Headers: Codable {
                }

                private struct Body: Codable {
                }

                var headersDictionary: [String: String] {
                    do {
                        let encoder = JSONEncoder()
                        let data = try encoder.encode(headers)
                        let jsonObject = try JSONSerialization.jsonObject(with: data, options: [])

                        if let dictionary = jsonObject as? [String: String] {
                            return dictionary
                        } else {
                            print("Warning: Failed to cast headers dictionary to [String: String]")
                            return [:]
                        }
                    } catch {
                        assertionFailure("Warning: Failed to encode headers: \\(error)")
                        return [:]
                    }
                }

                var bodyDictionary: [String: Any] {
                    do {
                        let encoder = JSONEncoder()
                        let data = try encoder.encode(body)
                        let jsonObject = try JSONSerialization.jsonObject(with: data, options: [])

                        if let dictionary = jsonObject as? [String: Any] {
                            return dictionary
                        } else {
                            print("Warning: Failed to cast body dictionary to [String: Any]")
                            return [:]
                        }
                    } catch {
                        assertionFailure("Warning: Failed to encode body: \\(error)")
                        return [:]
                    }
                }

                private var headers: Headers

                private var body: Body

                init() {
                    self.headers = Headers()
                    self.body = Body()
                }
            }
            """,
            macros: macros
        )
    }
    
    func testAccessorExpansion() {
        assertMacroExpansion(
            """
            @Header
            var authorization: String
            """,
            expandedSource: """
            var authorization: String {
                get {
                    headers.authorization
                }
            }
            """,
            macros: macros
        )
        
        assertMacroExpansion(
            """
            @Body
            var message: String
            """,
            expandedSource: """
            var message: String {
                get {
                    body.message
                }
            }
            """,
            macros: macros
        )
    }
    
    func testNonStructError() {
        assertMacroExpansion(
            """
            @RequestModel
            class InvalidRequest {
            }
            """,
            expandedSource: """
            class InvalidRequest {
            }
            """,
            diagnostics: [
                DiagnosticSpec(message: "RequestModelMacro can only be applied to a struct", line: 1, column: 1)
            ],
            macros: macros
        )
    }
    
    // Test for multiple headers and body properties
    func testMultipleProperties() {
        assertMacroExpansion(
            """
            @RequestModel
            struct ComplexRequest {
                @Header("Auth")
                var token: String
                
                @Header("Content-Type")
                var contentType: String
                
                @Body("data")
                var payload: String
                
                @Body("metadata")
                var info: String
            }
            """,
            expandedSource: """
            struct ComplexRequest {
                var token: String {
                    get {
                        headers.token
                    }
                }

                var contentType: String {
                    get {
                        headers.contentType
                    }
                }

                var payload: String {
                    get {
                        body.payload
                    }
                }

                var info: String {
                    get {
                        body.info
                    }
                }

                private struct Headers: Codable {
                    let token: String
                    let contentType: String

                    enum CodingKeys: String, CodingKey {
                        case token = "Auth"
                        case contentType = "Content-Type"
                    }
                }

                private struct Body: Codable {
                    let payload: String
                    let info: String

                    enum CodingKeys: String, CodingKey {
                        case payload = "data"
                        case info = "metadata"
                    }
                }

                var headersDictionary: [String: String] {
                    do {
                        let encoder = JSONEncoder()
                        let data = try encoder.encode(headers)
                        let jsonObject = try JSONSerialization.jsonObject(with: data, options: [])

                        if let dictionary = jsonObject as? [String: String] {
                            return dictionary
                        } else {
                            print("Warning: Failed to cast headers dictionary to [String: String]")
                            return [:]
                        }
                    } catch {
                        assertionFailure("Warning: Failed to encode headers: \\(error)")
                        return [:]
                    }
                }

                var bodyDictionary: [String: Any] {
                    do {
                        let encoder = JSONEncoder()
                        let data = try encoder.encode(body)
                        let jsonObject = try JSONSerialization.jsonObject(with: data, options: [])

                        if let dictionary = jsonObject as? [String: Any] {
                            return dictionary
                        } else {
                            print("Warning: Failed to cast body dictionary to [String: Any]")
                            return [:]
                        }
                    } catch {
                        assertionFailure("Warning: Failed to encode body: \\(error)")
                        return [:]
                    }
                }

                private var headers: Headers

                private var body: Body

                init(token: String, contentType: String, payload: String, info: String) {
                    self.headers = Headers(token: token, contentType: contentType)
                    self.body = Body(payload: payload, info: info)
                }
            }
            """,
            macros: macros
        )
    }
}
