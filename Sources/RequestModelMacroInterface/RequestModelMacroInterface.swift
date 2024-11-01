//
//  RequestModelMacroInterface.swift
//  RequestModelMacro
//
//  Created by Bruno on 31/10/24.
//

@attached(
    member,
    names: named(Headers),
    named(Body),
    named(headersDictionary),
    named(bodyDictionary),
    named(headers),
    named(body),
    named(initializer)
)
public macro RequestModel() = #externalMacro(module: "RequestModelMacroImplementation", type: "RequestModelMacro")

@attached(peer)
public macro Header(_ key: String? = nil) = #externalMacro(module: "RequestModelMacroImplementation", type: "HeaderMacro")

@attached(peer)
public macro Body(_ key: String? = nil) = #externalMacro(module: "RequestModelMacroImplementation", type: "BodyMacro")
