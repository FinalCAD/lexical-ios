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

extension LexicalListPlugin.ListNode: NodeHTMLSupport {
    public static func importDOM() throws -> DOMConversionMap {
        [
            "ol": convertListNode,
            "ul": convertListNode
        ]
    }
    
    private static func convertListNode(_ element: SwiftSoup.Node) throws -> DOMConversionOutput {
        guard let element = element as? SwiftSoup.Element else {
            return (after: nil, forChild: nil, node: [])
        }
        
        var node: Lexical.Node? = nil
        
        switch element.tagName() {
        case "ol":
            node = try createListNode(listType: .number, start: 1)
        case "ul":
            node = try createListNode(listType: .bullet)
        default:
            break
        }
        
        
        return (
            after: nil,
            forChild: nil,
            node: node != nil ? [node!]: []
        )
    }
    
    public static func importDOM(domNode: SwiftSoup.Node) throws -> DOMConversionOutput {
        return (after: nil, forChild: nil, node: [])
    }
    
    public func exportDOM(editor: Lexical.Editor) throws -> DOMExportOutput {
        let tag = self.getListType() == .number ? "ol" : "ul"
        let dom = SwiftSoup.Element(Tag(tag), "")
        
        if getStart() != 1 {
            try dom.attr("start", "\(getStart())")
        }
        
        return (after: nil, element: dom)
    }
}

