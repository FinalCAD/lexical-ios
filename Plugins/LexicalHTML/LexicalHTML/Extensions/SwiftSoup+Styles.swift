//
//  SwiftSoup+Attributes.swift
//  Lexical
//
//  Created by Julien SMOLARECK on 23/08/2025.
//

import SwiftSoup

struct NodeStyle {
    enum TextAlign: String {
        case left
        case right
        case center
        case justify
    }
//    let fontWeight
    
    var paddingInlineState: Int?
    var textAlign: TextAlign?
    
    
    
    init(paddingInlineState: Int? = nil, textAlign: TextAlign? = nil) {
        self.paddingInlineState = paddingInlineState
        self.textAlign = textAlign
    }
    
    init(from string: String) {
        let components = string.split(separator: ";")
        
        components.forEach {
            let splitted = $0.split(separator: ":")
            let key = splitted[0].trimmingCharacters(in: .whitespaces)
            let value = splitted[1].trimmingCharacters(in: .whitespaces)
            
            switch key {
            case "padding-inline-start":
                self.paddingInlineState = Int(value)
            case "text-align":
                self.textAlign = .init(rawValue: value)
            default:
                break
            }
        }
    }
    
    var toString: String {
        ([
            "padding-inline-start": paddingInlineState,
            "text-align": textAlign
        ] as [String: Any?])
        .filter { $1 != nil }
        .map { "\($0):\($1!)" }
        .joined(separator: ";")
        
    }
}

extension SwiftSoup.Attributes {
    func styles() -> NodeStyle? {
        NodeStyle(from: get(key: "styles"))
    }
}
