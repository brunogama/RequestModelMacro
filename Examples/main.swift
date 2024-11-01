//
//  main.swift
//  RequestModelMacro
//
//  Created by Bruno on 31/10/24.
//

import Foundation
import RequestModelMacro

@RequestModel
struct StartRequest {
    @Header("Authorization")
    var token: String

    @Header
    var contentType: String

    @Body
    var fff: String

    @Body("Hashed")
    var hashed: Data
}

let startRequest = StartRequest(token: "Bearer 123", contentType: "application/json", fff: "fff", hashed: Data())

print(startRequest.headersDictionary)
print(startRequest.bodyDictionary)
