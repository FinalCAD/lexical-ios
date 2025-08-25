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

extension LexicalListPlugin.ListItemNode: NodeHTMLSupport {
    public static func importDOM() throws -> DOMConversionMap {
        [
            "li": convertListItemElement
        ]
    }
    
    private static func convertListItemElement(_ element: SwiftSoup.Node) -> DOMConversionOutput {
        (after: nil, forChild: nil, node: [ListItemNode()])
    }
    
    public func exportDOM(editor: Lexical.Editor) throws -> DOMExportOutput {
        let dom = SwiftSoup.Element(Tag("li"), "")
        if getValue() > 0 {
            try dom.attr("value", "\(getValue())")
        }
        return (after: nil, element: dom)
    }
}
