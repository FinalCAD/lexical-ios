//
//  SwiftSoup+Attributes.swift
//  Lexical
//
//  Created by Julien SMOLARECK on 23/08/2025.
//

import SwiftSoup

enum Styles {
    case paddingInlineStart(Int)
    case textAlign(TextAlign)
    
    var toHTMLString: String {
        switch self {
        case .paddingInlineStart(let value):
            return "padding-inline-start:\(value)px"
        case .textAlign(let value):
            return "text-align:\(value)"
        }
    }
}

extension Styles {
    enum TextAlign: String {
        case left
        case right
        case center
        case justify
    }
}

struct NodeStyle {
    private let attributes: [Styles]
//    let fontWeight
    
    init(attributes: [Styles]) {
        self.attributes = attributes
    }
    
    init(from string: String) {
        let components = string.split(separator: ";")
        
        self.attributes = components.compactMap {
            let temp = $0.split(separator: ":")
            let key = temp[0].trimmingCharacters(in: .whitespaces)
            let value = temp[1].trimmingCharacters(in: .whitespaces)
            
            switch key {
            case "padding-inline-start":
                return .paddingInlineStart(Int(value) ?? 0)
            case "text-align":
                guard let textAlign = Styles.TextAlign(rawValue: value) else {
                    break
                }
                return .textAlign(textAlign)
            default:
                break
            }
            
            return nil
        }
    }
    
//    func get<T: Any>(_ key: Styles) -> T {
//        attributes.first { $0 == key } as? T
//    }
    
    var toString: String {
        attributes.map { $0.toHTMLString }.joined(separator: ";")
    }
}

extension SwiftSoup.Attributes {
    func styles() -> NodeStyle? {
        NodeStyle(from: get(key: "styles"))
    }
}
