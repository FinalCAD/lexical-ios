/*
 * Copyright (c) Meta Platforms, Inc. and affiliates.
 *
 * This source code is licensed under the MIT license found in the
 * LICENSE file in the root directory of this source tree.
 */

import Lexical
import LexicalHTML
import SwiftSoup

extension LinkNode: NodeHTMLSupport {
    public static func importDOM() throws -> DOMConversionMap {
        [
            "a": convertAnchorElement
        ]
    }
    
    private static func convertAnchorElement(_ element: SwiftSoup.Node) -> DOMConversionOutput {
        guard element.nodeName() == "a" else {
            return (after: nil, forChild: nil, node: [])
        }
        
        let node = LinkNode(url: element.getAttributes()?.get(key: "href") ?? "", key: nil)
        
//        if element is SwiftSoup.
        
        
        return (after: nil, forChild: nil, node: [node])
    }
    
    public func exportDOM(editor: Lexical.Editor) throws -> DOMExportOutput {
        let dom = SwiftSoup.Element(Tag("br"), "")
        return (after: nil, element: dom)
    }
    
    
}
