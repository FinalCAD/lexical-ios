/*
 * Copyright (c) Meta Platforms, Inc. and affiliates.
 *
 * This source code is licensed under the MIT license found in the
 * LICENSE file in the root directory of this source tree.
 */

import Lexical
import SwiftSoup

extension Lexical.TextNode: NodeHTMLSupport {
    public static func importDOM() throws -> DOMConversionMap {
        [
            "#text": convertTextDOMNode,
            "code": convertTextFormatElement,
            "em": convertTextFormatElement,
            "i": convertTextFormatElement,
            "mark": convertTextFormatElement,
            "s": convertTextFormatElement,
            "span": convertSpanElement,
            "strong": convertTextFormatElement,
            "sup": convertTextFormatElement,
            "sub": convertTextFormatElement,
            "u": convertTextFormatElement
            
        ]
    }
    
    private static func convertTextFormatElement(_ element: SwiftSoup.Node) throws -> DOMConversionOutput {
        guard let styles = element.getAttributes()?.styles() else {
            return (after: nil, forChild: nil, node: [])
        }
        
        return (after: nil, forChild: applyTextFormatFromStyle(styles), node: [])
    }
    
    private static func convertSpanElement(_ node: SwiftSoup.Node) throws -> DOMConversionOutput {
        (after: nil, forChild: { lexicalNode, _ in
            return lexicalNode
        }, node: [])
    }
    
    private static func convertTextDOMNode(_ node: SwiftSoup.Node) throws -> DOMConversionOutput {
        guard let domNode = node as? SwiftSoup.TextNode else {
            return (after: nil, forChild: nil, node: [])
        }
        let parentDom = node.parent()
        var textContent = domNode.text()
//        
//        
//        let regex = try Regex("/\r/")
//        textContent = textContent.replace(Regex("\r"), with:" ")
//        
        return (after: nil, forChild: nil, node: [createTextNode(text: textContent)])
    }
    
    private static func applyTextFormatFromStyle(_ style: NodeStyle) -> DOMChildConversion {
//        let fontWeigth = style.fontWeight
        
        return { node, _ in
            return node
        }
    }
    
    public func exportDOM(editor: Lexical.Editor) throws -> DOMExportOutput {
        let outerTag = getFormat().code ? "code" : "span"
        
        var element = SwiftSoup.Element(Tag(outerTag), "")
        
        
        
        try element.appendText(self.getTextPart())
        
        if getFormat().bold {
            element = try wrapDomElement(element, with: "b")
        }
        if getFormat().italic {
            element = try wrapDomElement(element, with: "i")
        }
        if getFormat().strikethrough {
            element = try wrapDomElement(element, with: "s")
        }
        if getFormat().underline {
            element = try wrapDomElement(element, with: "u")
        }
        
        return (after: nil, element: element)
    }
    
    private func wrapDomElement(_ element: SwiftSoup.Element, with tagString: String) throws -> SwiftSoup.Element {
        let newElement = SwiftSoup.Element(Tag(tagString), "")
        try newElement.appendChild(element)
        return newElement
    }
}
