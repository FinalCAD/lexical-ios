/*
 * Copyright (c) Meta Platforms, Inc. and affiliates.
 *
 * This source code is licensed under the MIT license found in the
 * LICENSE file in the root directory of this source tree.
 */

import Lexical
import SwiftSoup
import UIKit

extension Lexical.TextNodeStyle {
    static func convertFromCSS(_ style: String) -> Lexical.TextNodeStyle {
        let splitted: [PartialKeyPath<TextNodeStyle>: Any] = style
            .split(separator: ";")
            .reduce(into: [:]) {
                let temp = $1.split(separator: ":")
                
                if temp.first != nil {
                    let key = String(temp.first!)
                    let value = String(temp.last!)
                    
                    switch key {
                    case "background-color":
                        $0[\TextNodeStyle.backgroundColor] = UIColor(rgb: value)
                    case "color":
                        $0[\TextNodeStyle.foregroundColor] = UIColor(rgb: value)
                    default:
                        break
                    }
                }
            }
        
        return TextNodeStyle(splitted)
    }
    
    func toCSS() -> String? {
        var properties : [String:String] = [:]
        
        if let backgroundColor {
            properties["background-color"] = String(format: "#%06X", backgroundColor.hex)
        }
        
        if let foregroundColor {
            properties["color"] = String(format: "#%06X", foregroundColor.hex)
        }
        
        if properties.isEmpty {
            return nil
        }
        
        return properties.map { "\($0):\($1)" }.joined(separator: ";")
    }
}

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
                TextNodeStyle.convertFromCSS(
                    element.getAttributes()?.get(key: "style") ?? ""
                ),
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
                TextNodeStyle.convertFromCSS(
                    element.getAttributes()?.get(key: "style") ?? ""
                ),
                shouldApply: nodeNameToTextFormat[element.nodeName()]
            ),
            node: []
        )
    }
    
    private static func convertSpanElement(_ element: SwiftSoup.Node) throws -> DOMConversionOutput {
        (after: nil,
         forChild: applyTextFormatFromStyle(
            TextNodeStyle.convertFromCSS(
                element.getAttributes()?.get(key: "style") ?? ""
            ),
            shouldApply: nil
         ),
         node: []
        )
    }
    
    private static func convertTextDOMNode(_ node: SwiftSoup.Node) throws -> DOMConversionOutput {
        guard let domNode = node as? SwiftSoup.TextNode else {
            return (after: nil, forChild: nil, node: [])
        }
        
        let textContent = domNode.text()

        return (after: nil, forChild: nil, node: [createTextNode(text: textContent)])
    }
    
    private static func applyTextFormatFromStyle(_ style: TextNodeStyle, shouldApply: TextFormatType?) -> DOMChildConversion {
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
        if getTextPart().isEmpty || self is PlaceholderNode {
            return (after: nil, element: nil)
        }
        
        var element: SwiftSoup.Node = SwiftSoup.TextNode(self.getTextPart(), nil)
        element = try wrapDomElement(element, with: "span")
        
        let style = getLatest().getStyle()
        if let css = style.toCSS() {
            try element.attr("style", css)
        }
        
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
    
    private func wrapDomElement(_ element: SwiftSoup.Node, with tagString: String) throws -> SwiftSoup.Element {
        let newElement = SwiftSoup.Element(Tag(tagString), "")
        try newElement.appendChild(element)
        return newElement
    }
}
