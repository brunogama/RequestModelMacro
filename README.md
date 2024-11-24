# Request Model Macro

I was tired of repeating the same pattern for creating request models with custom headers and body so I decided to create a Swift Macro to help me to make this easier.

## Features

This library includes various Swift macros that can be used in your projects to improve code generation and reduce repetitive tasks:

* Header and Body Macros: Use HeaderMacro.swift and BodyMacro.swift to generate consistent request headers and body structures for API calls.

* Request Model Macro: RequestModelMacro.swift and RequestModelMacroInterface.swift facilitate the creation of standardized request models for APIs. This macro helps ensure that your request models are well-formed, consistent, and easy to maintain.

* Diagnostics Support: Diagnostics.swift helps provide useful information about the health and correctness of the generated code, making debugging simpler and more effective.

* Property Data Macro: PropertyData.swift offers an easy way to handle property generation for request models, ensuring consistency and reducing repetitive definitions.

## Usage

**Input**

```swift
import RequestModelMacro

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
```

**Generated Code&**

```swift
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
```

## Installation

**Swift Package Manager**

You can add this library to your project using Swift Package Manager by adding the following dependency in your `Package.swift`:

```swift
.package(url: "https://github.com/brunogama/RequestModelMacro.git", from: "0.0.1")
```

**Note:** This library lacks more tests. So use at your own risk.

## Contributing

We welcome contributions to improve this library! Feel free to open an issue or submit a pull request.

## License

This library is licensed under the MIT License. See the LICENSE file for more details.

## Contact

For any questions or suggestions, feel free to contact me at @brunogama on Twitter.