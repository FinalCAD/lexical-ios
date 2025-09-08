/*
 * Copyright (c) Meta Platforms, Inc. and affiliates.
 *
 * This source code is licensed under the MIT license found in the
 * LICENSE file in the root directory of this source tree.
 */

import Lexical
import SwiftSoup


extension Lexical.QuoteNode: NodeHTMLSupport {
    public static func importDOM() throws -> DOMConversionMap {
        [
            "blockquote": convertBlockquoteElement
        ]
    }
    
    private static func convertBlockquoteElement(_ element: SwiftSoup.Node) -> DOMConversionOutput {
        let node = createQuoteNode()
        
        return (after: nil, forChild: nil, node: [node])
    }
    
    public func exportDOM(editor: Lexical.Editor) throws -> DOMExportOutput {
        let dom = SwiftSoup.Element(Tag("blockquote"), "")
        return (after: nil, element: dom)
    }
}

