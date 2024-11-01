//
//  MessageID+Extensions.swift
//  RequestModelMacro
//
//  Created by Bruno on 01/11/24.
//

import SwiftDiagnostics

extension MessageID {
    static func makeHashableMacroMessageID(id: String) -> MessageID {
        MessageID(domain: "br.brunoporciuncula.RequestModelMacro", id: id)
    }
}
