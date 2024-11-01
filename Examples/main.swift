//
//  main.swift
//  RequestModelMacro
//
//  Created by Bruno on 31/10/24.
//

import RequestModelMacro
import Foundation

@RequestModel
struct StartRequest {
    @Header("Authorization")
    var token: String
    
    @Header
    var contentType: String
    
    @Body
    var body: String
    
    @Body("Hashed")
    var hashed: Data
}
