//
//  main.swift
//  RequestModelMacro
//
//  Created by Bruno on 31/10/24.
//

import Foundation
import RequestModelMacro

struct Ham: Codable {
    var name: String
    var age: Int
}

@RequestModel
struct StartRequest {
    @Header("Authorization")
    var token: String

    @Header
    var contentType: String

    @Body("Hashed")
    var hashed: Data
}

//print(startRequest.headersDictionary)
//print(startRequest.bodyDictionary)
