//
//  Plugin.swift
//  RequestModelMacro
//
//  Created by Bruno on 31/10/24.
//

#if canImport(SwiftCompilerPlugin)
import SwiftCompilerPlugin
import SwiftSyntaxMacros

@main
struct Plugin: CompilerPlugin {
    let providingMacros: [Macro.Type] = [
        RequestModelMacro.self,
        HeaderMacro.self,
        BodyMacro.self,
    ]
}
#endif
