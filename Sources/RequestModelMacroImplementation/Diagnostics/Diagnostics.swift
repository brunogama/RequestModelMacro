//
//  Diagnostics.swift
//  RequestModelMacro
//
//  Created by Bruno on 31/10/24.
//

import SwiftDiagnostics
import SwiftSyntax

struct MacroDiagnosticMessage: DiagnosticMessage, Error {
    let message: String
    let diagnosticID: MessageID
    let severity: DiagnosticSeverity

    init(id: String, message: String, severity: DiagnosticSeverity) {
        self.message = message
        self.diagnosticID = MessageID.makeHashableMacroMessageID(id: id)
        self.severity = severity
    }
}

extension MacroDiagnosticMessage: FixItMessage {
    var fixItID: MessageID { diagnosticID }
}

enum CustomError: Error, CustomStringConvertible {
    case message(String)

    var description: String {
        switch self {
        case .message(let text):
            return text
        }
    }
}
