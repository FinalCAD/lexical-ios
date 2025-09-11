/*
 * Copyright (c) Meta Platforms, Inc. and affiliates.
 *
 * This source code is licensed under the MIT license found in the
 * LICENSE file in the root directory of this source tree.
 */

import SwiftSoup

public struct NodeStyle {
    public enum TextAlign: String {
        case left
        case right
        case center
        case justify
        case end
        case start
    }

    public private(set) var paddingInlineState: Int?
    public private(set) var textAlign: TextAlign?
    
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
    public func styles() -> NodeStyle? {
        NodeStyle(from: get(key: "style"))
    }
}
