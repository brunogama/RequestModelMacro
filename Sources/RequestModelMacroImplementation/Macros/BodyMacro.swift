//
//  BodyMacro.swift
//  RequestModelMacro
//
//  Created by Bruno on 01/11/24.
//

import Foundation
import SwiftSyntax
import SwiftSyntaxBuilder
import SwiftSyntaxMacros

public struct BodyMacro: AccessorMacro {
    public static func expansion(
        of node: AttributeSyntax,
        providingAccessorsOf declaration: some DeclSyntaxProtocol,
        in context: some MacroExpansionContext
    ) throws -> [AccessorDeclSyntax] {
        guard let varDecl = declaration.as(VariableDeclSyntax.self),
            let binding = varDecl.bindings.first,
            let identifier = binding.pattern.as(IdentifierPatternSyntax.self)?.identifier.text
        else {
            return []
        }

        return [
            """
            get {
                body.\(raw: identifier)
            }
            """ as AccessorDeclSyntax
        ]
    }
}
