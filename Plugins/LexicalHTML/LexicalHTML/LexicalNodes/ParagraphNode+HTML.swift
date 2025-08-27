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
            
            
//            if let paddingInlineStart = style.paddingInlineStart {
//                try node.setIndent(paddingInlineStart / 40)
//            }
//            
//            if let textAlign = style.textAlign {
//                switch textAlign {
//                case .left:
//                    try node.setDirection(direction: .left)
//                case .right:
//                    try node.setDirection(direction: .right)
//                default:
//                    break
//                }
//            }
            //            node.setDirection(direction: .)
        }
        
        if let attributes = element.getAttributes() {
            //            if attributes.hasKey(key: "style")
        }
        if element.hasAttr("style") {
            //            if let padding = domNode.attr("style").split(separator: ":").last?.trimmingCharacters(in: .whitespacesAndNewlines) {
            //
            //            }
        }
        
        
        return (after: nil, forChild: nil, node: [node])
    }
    
    public func exportDOM(editor: Lexical.Editor) throws -> DOMExportOutput {
        let dom = SwiftSoup.Element(Tag("p"), "")
        
        if getIndent() > 0 {
            try dom.attr("style", "padding-inline-start:\(getIndent() * 40)px")
        }
        return (after: nil, element: dom)
    }
}
