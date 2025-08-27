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
            "b": convertBringAttentionToElement,
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
    
    private static func convertBringAttentionToElement(_ element: SwiftSoup.Node) throws -> DOMConversionOutput {
        (
            after: nil,
            forChild: applyTextFormatFromStyle(
                element.getAttributes()?.get(key: "style") ?? "",
                shouldApply: nil
            ),
            node: []
        )
    }
    
    private static func convertTextFormatElement(_ element: SwiftSoup.Node) throws -> DOMConversionOutput {
        let nodeNameToTextFormat: [String: TextFormatType] = [
            "code": .code,
            "em": .italic,
            "i": .italic,
//            "mark": .hightlight,
            "s": .strikethrough,
            "strong": .bold,
            "sub": .subScript,
            "sup": .superScript,
            "u": .underline
        ]
        
        return (
            after: nil,
            forChild: applyTextFormatFromStyle(
                element.getAttributes()?.get(key: "style") ?? "",
                shouldApply: nodeNameToTextFormat[element.nodeName()]
            ),
            node: []
        )
    }
    
    private static func convertSpanElement(_ element: SwiftSoup.Node) throws -> DOMConversionOutput {
        (after: nil,
         forChild: applyTextFormatFromStyle(
            element.getAttributes()?.get(key: "style") ?? "",
            shouldApply: nil
         ),
         node: []
        )
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
    
    private static func applyTextFormatFromStyle(_ style: String, shouldApply: TextFormatType?) -> DOMChildConversion {
//        let fontWeigth = style.
        
        return { node, _ in
            guard let textNode = node as? Lexical.TextNode else {
                return node
            }
            
            let _ = try textNode.setStyle(style)
            
            if shouldApply != nil {
                var textFormat = textNode.getFormat()
                textFormat.updateFormat(type: shouldApply!, value: true)
                try textNode.setFormat(format: textFormat)
            }
            
            return textNode
        }
    }
    
    public func exportDOM(editor: Lexical.Editor) throws -> DOMExportOutput {
        let outerTag = getFormat().code ? "code" : "span"
        
        var element = SwiftSoup.Element(Tag(outerTag), "")
        
        
        let style = getLatest().getStyle()
        if !style.isEmpty {
            try element.attr("style", style)
        }
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
