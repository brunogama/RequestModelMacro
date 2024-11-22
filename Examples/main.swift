//
//  main.swift
//  RequestModelMacro
//
//  Created by Bruno on 31/10/24.
//

import Foundation
import RequestModelMacro

//@propertyWrapper struct Capitalized {
//    var wrappedValue: String {
//        didSet { wrappedValue = wrappedValue.capitalized }
//    }
//
//    init(wrappedValue: String) {
//        self.wrappedValue = wrappedValue.capitalized
//    }
//}

@RequestModel
struct StartRequest {
    
    @Header("Authorization")
    var token: String

    @Header
    var contentType: String

    @Body("Hashed")
    var hashed: Data
}

let request = StartRequest(
    token: "F",
    contentType: "Authorization/JSON",
    hashed: Data()
)

print(request.headersDictionary)
print(request.bodyDictionary)
