/*
 * Copyright (c) Meta Platforms, Inc. and affiliates.
 *
 * This source code is licensed under the MIT license found in the
 * LICENSE file in the root directory of this source tree.
 */

import SwiftSoup
import Lexical

extension Lexical.HeadingNode: NodeHTMLSupport {
    //MARK: IMPORT
    
    public static func importDOM() throws -> DOMConversionMap {
        [
            "h1": convertHeadingElement,
            "h2": convertHeadingElement,
            "h3": convertHeadingElement,
            "h4": convertHeadingElement,
            "h5": convertHeadingElement,
            "h6": convertHeadingElement
        ]
    }
    
    private static func convertHeadingElement(_ element: SwiftSoup.Node) -> DOMConversionOutput {
        var node: Lexical.Node? = nil
        if let tagName = (element as? SwiftSoup.Element)?.tagName() {
            if let headingTag = HeadingTagType(rawValue: tagName) {
                node = createHeadingNode(headingTag: headingTag)
                
            }
        }
        
        return (after: nil, forChild: nil, node: [node].compactMap { $0 })
    }
    
    
    // MARK: EXPORT
    public func exportDOM(editor: Lexical.Editor) throws -> DOMExportOutput {
        let tag = self.getTag().rawValue
        let dom = SwiftSoup.Element(Tag(tag), "")
        return (after: nil, element: dom)
    }
}
