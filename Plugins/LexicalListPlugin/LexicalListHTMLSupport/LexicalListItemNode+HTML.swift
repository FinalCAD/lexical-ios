/*
 * Copyright (c) Meta Platforms, Inc. and affiliates.
 *
 * This source code is licensed under the MIT license found in the
 * LICENSE file in the root directory of this source tree.
 */

import Foundation
import Lexical
import LexicalHTML
import LexicalListPlugin
import SwiftSoup

extension LexicalListPlugin.ListItemNode: @retroactive NodeHTMLSupport {
    public static func importDOM() throws -> DOMConversionMap {
        [
            "li": convertListItemElement
        ]
    }
    
    private static func convertListItemElement(_ element: SwiftSoup.Node) throws -> DOMConversionOutput {
        let node = ListItemNode()
        
        if let style = element.getAttributes()?.styles() {
            let indent = (style.paddingInlineState ?? 0) / 40
            
            try node.setIndent(indent)
            
            if let textAlign = style.textAlign?.rawValue {
                try node.setFormat(ElementFormatType(rawValue: textAlign) ?? .left)
            }
        }
        
        return (after: nil, forChild: nil, node: [node])
    }
    
    public func exportDOM(editor: Lexical.Editor) throws -> DOMExportOutput {
        let dom = SwiftSoup.Element(Tag("li"), "")
        if getValue() > 0 {
            try dom.attr("value", "\(getValue())")
        }
        
        var style: [String] = []
        
        if getIndent() > 0 {
            style.append("padding-inline-start:\(getIndent() * 40)px")
            
        }
        
        let format = getFormat()
        if format != .left {
            style.append("text-align:\(format.rawValue)")
        }
        
        if style.isEmpty == false {
            try dom.attr("style", style.joined(separator: ";"))
        }
        
        return (after: nil, element: dom)
    }
}
