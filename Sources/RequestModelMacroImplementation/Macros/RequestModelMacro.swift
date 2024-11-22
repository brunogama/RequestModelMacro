//
//  RequestModelMacro.swift
//  RequestModelMacro
//
//  Created by Bruno on 31/10/24.
//

import Foundation
import SwiftSyntax
import SwiftSyntaxBuilder
import SwiftSyntaxMacros

public enum RequestModelMacro {
    struct MacroError: Error, CustomStringConvertible {
        let message: String
        var description: String { message }
    }
}

extension RequestModelMacro: MemberMacro {
    public static func expansion(
        of node: AttributeSyntax,
        providingMembersOf declaration: some DeclGroupSyntax,
        conformingTo protocols: [TypeSyntax],
        in context: some MacroExpansionContext
    ) throws -> [DeclSyntax] {
        guard let _ = declaration.as(StructDeclSyntax.self) else {
            throw MacroDiagnosticMessage(
                id: "struct-support-only",
                message: "RequestModelMacro can only be applied to a struct",
                severity: .error
            )
        }

        let memberList = declaration.memberBlock.members
        return try makeRequestModelDeclarations(memberList: memberList, context: context)
    }

    private static func makeRequestModelDeclarations(
        memberList: MemberBlockItemListSyntax,
        context: some MacroExpansionContext
    ) throws -> [DeclSyntax] {
        let headerStruct = try makeHeaderDeclSyntas(memberList: memberList, context: context)
        let bodyStruct = try makeBodyDeclSyntax(memberList: memberList, context: context)
        let dictionaryProperties = makeDictionaryProperties()
        let storageProperties = makeStorageProperties()
        let initializer = try makeInitializer(memberList: memberList, context: context)

        return [
            headerStruct,
            bodyStruct,
            dictionaryProperties.headers,
            dictionaryProperties.body,
            storageProperties.headers,
            storageProperties.body,
            initializer
        ]
    }

    private static func makeStorageProperties() -> (headers: DeclSyntax, body: DeclSyntax) {
        let headers = """
            private var headers: Headers
            """ as DeclSyntax

        let body = """
            private var body: Body
            """ as DeclSyntax

        return (headers, body)
    }

    private static func makeDictionaryProperties() -> (headers: DeclSyntax, body: DeclSyntax) {
        let headers = """
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
            """ as DeclSyntax

        let body = """
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
            """ as DeclSyntax

        return (headers, body)
    }

    static func makeHeaderDeclSyntas(
        memberList: MemberBlockItemListSyntax,
        context: some MacroExpansionContext
    ) throws -> DeclSyntax {
        let headersData = try extractPropertiesWithAttribute(
            from: memberList,
            withAttribute: "Header",
            context: context
        )

        guard !headersData.isEmpty else {
            return makeEmptyStruct(name: "Headers")
        }

        return makeStruct(name: "Headers", with: headersData)
    }

    static func makeBodyDeclSyntax(
        memberList: MemberBlockItemListSyntax,
        context: some MacroExpansionContext
    ) throws -> DeclSyntax {
        let bodyData = try extractPropertiesWithAttribute(
            from: memberList,
            withAttribute: "Body",
            context: context
        )

        guard !bodyData.isEmpty else {
            return makeEmptyStruct(name: "Body")
        }

        return makeStruct(name: "Body", with: bodyData)
    }

    private static func makeInitializer(
        memberList: MemberBlockItemListSyntax,
        context: some MacroExpansionContext
    ) throws -> DeclSyntax {
        let headerProps = try extractPropertiesWithAttribute(
            from: memberList,
            withAttribute: "Header",
            context: context
        )
        let bodyProps = try extractPropertiesWithAttribute(
            from: memberList,
            withAttribute: "Body",
            context: context
        )
        
        let parameters = (headerProps + bodyProps).map { prop in
            "\(prop.propertyName): \(prop.type)"
        }.joined(separator: ", ")
        
        let headerAssignments = headerProps.map { prop in
            "\(prop.propertyName): \(prop.propertyName)"
        }.joined(separator: ", ")
        
        let bodyAssignments = bodyProps.map { prop in
            "\(prop.propertyName): \(prop.propertyName)"
        }.joined(separator: ", ")
        
        return """
            init(\(raw: parameters)) {
                self.headers = Headers(\(raw: headerAssignments))
                self.body = Body(\(raw: bodyAssignments))
            }
            """ as DeclSyntax
    }

    private static func extractPropertiesWithAttribute(
        from memberList: MemberBlockItemListSyntax,
        withAttribute attributeName: String,
        context: some MacroExpansionContext
    ) throws -> [PropertyData] {
        memberList.compactMap { member -> PropertyData? in
            guard let varDcl = member.decl.as(VariableDeclSyntax.self),
                hasAttribute(varDcl, named: attributeName),
                let binding = varDcl.bindings.first,
                let identifier = binding.pattern.as(IdentifierPatternSyntax.self)?.identifier.text,
                let typeAnnotation = binding.typeAnnotation?.type
            else {
                return nil
            }

            return PropertyData(
                propertyName: identifier,
                type: typeAnnotation.description,
                label: getFromKey(key: attributeName, varDcl: varDcl)
            )
        }
    }

    private static func hasAttribute(_ varDcl: VariableDeclSyntax, named attributeName: String) -> Bool {
        varDcl.attributes.contains { element in
            element
                .as(AttributeSyntax.self)?
                .attributeName
                .as(IdentifierTypeSyntax.self)?
                .description == attributeName
        }
    }

    private static func makeEmptyStruct(name: String) -> DeclSyntax {
        """
        private struct \(raw: name): Encodable {
        }
        """ as DeclSyntax
    }

    private static func makeStruct(name: String, with properties: [PropertyData]) -> DeclSyntax {
        let structProperties = properties.map { data in
            "let \(data.propertyName): \(data.type)"
        }

        let codingKeys = makeCodingKeys(from: properties)

        return """
            private struct \(raw: name): Encodable {
                \(raw: structProperties.joined(separator: "\n    "))

                \(raw: codingKeys)
            }
            """ as DeclSyntax
    }

    private static func makeCodingKeys(from properties: [PropertyData]) -> DeclSyntax {
        let cases = properties.map { data in
            if let label = data.label {
                "case \(data.propertyName) = \"\(label)\""
            } else {
                "case \(data.propertyName)"
            }
        }
        var codingKeysEnum = ""
        codingKeysEnum += "enum CodingKeys: String, CodingKey {"
        
        cases.forEach {
            codingKeysEnum +=
            """
                \($0)
            """
        }
        
        codingKeysEnum += "}"
        return DeclSyntax(stringLiteral: codingKeysEnum)
    }

    private static func getFromKey(
        key: String,
        varDcl: VariableDeclSyntax
    ) -> String? {
        varDcl
            .attributes
            .first(where: { element in
                element
                    .as(AttributeSyntax.self)?
                    .attributeName
                    .as(IdentifierTypeSyntax.self)?
                    .description == key
            })?
            .as(AttributeSyntax.self)?
            .arguments?
            .as(LabeledExprListSyntax.self)?
            .first?
            .expression
            .as(StringLiteralExprSyntax.self)?
            .segments
            .first?
            .as(StringSegmentSyntax.self)?
            .content
            .text
    }
}
