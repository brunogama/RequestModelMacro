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
    named(init)
)
public macro RequestModel() = #externalMacro(module: "RequestModelMacroImplementation", type: "RequestModelMacro")

@attached(accessor)
public macro Header(_ key: String? = nil) =
    #externalMacro(module: "RequestModelMacroImplementation", type: "HeaderMacro")

@attached(accessor)
public macro Body(_ key: String? = nil) = #externalMacro(module: "RequestModelMacroImplementation", type: "BodyMacro")
