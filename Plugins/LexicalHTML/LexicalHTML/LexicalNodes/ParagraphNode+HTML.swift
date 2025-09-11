/*
 * Copyright (c) Meta Platforms, Inc. and affiliates.
 *
 * This source code is licensed under the MIT license found in the
 * LICENSE file in the root directory of this source tree.
 */

import Lexical
import SwiftSoup

extension Lexical.ParagraphNode: NodeHTMLSupport {
    public static func importDOM() throws -> DOMConversionMap {
        [
            "p": convertParagraphElement
        ]
    }
    
    private static func convertParagraphElement(_ element: SwiftSoup.Node) throws -> DOMConversionOutput {
        let node = Lexical.ParagraphNode()
        
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
        let dom = SwiftSoup.Element(Tag("p"), "")
        
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
