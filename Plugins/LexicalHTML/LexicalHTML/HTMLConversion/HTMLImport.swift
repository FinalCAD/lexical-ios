/*
 * Copyright (c) Meta Platforms, Inc. and affiliates.
 *
 * This source code is licensed under the MIT license found in the
 * LICENSE file in the root directory of this source tree.
 */

import Lexical
import SwiftSoup

let IGNORE_TAGS = ["style", "script"]

public func generateNodesFromDOM(editor: Editor, dom: SwiftSoup.Document) throws -> [Lexical.Node] {
    let elements = dom.body()?.getChildNodes() ?? []
    var lexicalNodes: [Lexical.Node] = []
    
    for element in elements {
        if IGNORE_TAGS.contains(element.nodeName()) == false {
            var forChildMap: [String: DOMChildConversion] = [:]
            let lexicalNode = try createNodeFromDOM(
                element: element,
                editor: editor,
                hasBlockAncestorLexicalNode: false,
                forChildMap: &forChildMap
            ).filter { $0 is Lexical.TextNode == false }
            lexicalNodes.append(contentsOf: lexicalNode)
        }
    }
    
    return lexicalNodes
}

func getConversionFunction(domNode: SwiftSoup.Node, editor: Editor) throws -> DOMConversionFn? {
    var tagName = (domNode as? SwiftSoup.Element)?.tagName()
    if tagName == nil {
        if domNode is SwiftSoup.TextNode {
            tagName = "#text"
        }
    }
    
    guard let tagName else {
        return nil
    }
    
    return try editor.getRegisteredNodes()
        .compactMap { $1.self as? NodeHTMLSupport.Type }
        .compactMap {
            let conversionMap = try $0.importDOM()
            return conversionMap[tagName]
        }.first
}


func createNodeFromDOM(
    element: SwiftSoup.Node,
    editor: Editor,
    hasBlockAncestorLexicalNode: Bool,
    forChildMap: inout [String: DOMChildConversion],
    parentLexicalNode: Lexical.Node? = nil
) throws -> [Lexical.Node] {
    var lexicalNodes: [Lexical.Node?] = []
    
    if IGNORE_TAGS.contains(element.nodeName()) {
        return []
    }
    
    
    
    var currentLexicalNode: Lexical.Node? = nil
    
    let transformFunction = try getConversionFunction(domNode: element, editor: editor)
    if let transformOutput = try transformFunction?(element) {
        let transformNodes = transformOutput.node
        currentLexicalNode = transformNodes.last
        
        if currentLexicalNode != nil {
            for (_, forChildFunction) in forChildMap {
                currentLexicalNode = try forChildFunction(
                    currentLexicalNode!,
                    parentLexicalNode
                )
                
                if currentLexicalNode == nil {
                    break
                }
            }
            
            if currentLexicalNode != nil {
                lexicalNodes += transformNodes.count > 1 ? transformNodes : [currentLexicalNode]
            }
        }
        
        if transformOutput.forChild != nil {
            forChildMap[element.nodeName()] = transformOutput.forChild
        }
    }
    
    var childLexicalNodes: [Lexical.Node] = []
    
    var hasBlockAncestorLexicalNodeForChildren: Bool {
        if currentLexicalNode != nil && isRootOrShadowRoot(node: currentLexicalNode!) {
            return false
        }
        
        return (currentLexicalNode != nil && currentLexicalNode is Lexical.ElementNode) || hasBlockAncestorLexicalNode
    }
    
    for child in element.getChildNodes() {
        var forChildMap = forChildMap
        childLexicalNodes.append(contentsOf: try! createNodeFromDOM(
            element: child,
            editor: editor,
            hasBlockAncestorLexicalNode: hasBlockAncestorLexicalNodeForChildren,
            forChildMap: &forChildMap,
            parentLexicalNode: currentLexicalNode
        ))
    }
    
    if isBlockDomNode(node: element) {
        if hasBlockAncestorLexicalNodeForChildren == false {
            childLexicalNodes = wrapContinuousInlines(
                element: element,
                nodes: childLexicalNodes,
                createWrapperFn: createParagraphNode
            )
        }
    }
    
    if currentLexicalNode == nil {
        if childLexicalNodes.count > 0 {
            lexicalNodes += childLexicalNodes
        } else {
            if isBlockDomNode(node: element) {
                lexicalNodes += [createLineBreakNode()]
            }
        }
    } else if let node = currentLexicalNode as? Lexical.ElementNode {
        try node.append(childLexicalNodes)
    }
    
    return lexicalNodes.compactMap { $0 }
    
}

private func wrapContinuousInlines(element: SwiftSoup.Node, nodes: [Lexical.Node], createWrapperFn: () -> Lexical.ElementNode) -> [Lexical.Node] {
    var out: [Lexical.Node] = []
    var continuousInlines: [Lexical.Node] = []
    
    for i in 0..<nodes.count {
        let node = nodes[i]
        
        if node is Lexical.ElementNode {
            out.append(node)
        } else {
            continuousInlines.append(node)
            
            if (i == nodes.count - 1) || (i < nodes.count - 1 && nodes[i + 1] is Lexical.ElementNode) {
                let wrapper = createWrapperFn()
                try! wrapper.append(continuousInlines)
                out.append(wrapper)
                continuousInlines = []
            }
        }
    }
    
    return out
}
