/*
 * Copyright (c) Meta Platforms, Inc. and affiliates.
 *
 * This source code is licensed under the MIT license found in the
 * LICENSE file in the root directory of this source tree.
 */

import Foundation
import Lexical
import LexicalLinkPlugin
import UIKit

struct LinkMatcherResult {
    let index: Int
    let length: Int
    let text: String
    let url: String
}

struct LinkMatcher {
    var index: Int
    var text: String
    var url: String
    var range: NSRange
}

open class AutoLinkPlugin: Plugin {
    
    public init() {}
    
    var editor: Editor?
    
    public func setUp(editor: Editor) {
        self.editor = editor
        do {
            try editor.registerNode(nodeType: NodeType.autoLink, class: LinkNode.self)
            _ = editor.addNodeTransform(nodeType: NodeType.text, transform: { [weak self] in
                guard let strongSelf = self else { return }
                
                try strongSelf.transform($0)
            })
            
            _ = editor.addNodeTransform(nodeType: NodeType.autoLink, transform: { [weak self] linkNode in
                guard let strongSelf = self, let linkNode = linkNode as? AutoLinkNode else { return }
                
                try strongSelf.handleLinkEdit(linkNode: linkNode)
            })
        } catch {
            print("\(error)")
        }
    }
    
    public func tearDown() {
    }
    
    public func isAutoLinkNode(_ node: Node?) -> Bool {
        node is LinkNode
    }
    
    public func createAutoLinkNode(url: String) -> AutoLinkNode {
        AutoLinkNode(url: url, key: nil)
    }
    
    func isPreviousNodeValid(node: Node) -> Bool {
        var previousNode = node.getPreviousSibling()
        
        if let elementNode = previousNode as? ElementNode {
            previousNode = elementNode.getLastDescendant()
        }
        
        if let textNode = previousNode as? TextNode {
            let text = textNode.getTextContent()
            let endIndex = text.index(before: text.endIndex)
            if String(text[endIndex]) == " " {
                return true
            }
        }
        
        return previousNode == nil || isLineBreakNode(previousNode)
    }
    
    func isNextNodeValid(node: Node) -> Bool {
        var nextNode = node.getNextSibling()
        
        if let elementNode = nextNode as? ElementNode {
            nextNode = elementNode.getFirstDescendant()
        }
        
        if let textNode = nextNode as? TextNode {
            let text = textNode.getTextContent()
            if String(text[text.startIndex]) == " " {
                return true
            }
        }
        
        return nextNode == nil || isLineBreakNode(nextNode)
    }
    
    @discardableResult
    func replaceWithChildren(node: ElementNode) throws -> [Node] {
        let children = node.getChildren()
        
        for child in children.reversed() {
            try node.insertAfter(nodeToInsert: child)
        }
        
        try node.remove()
        return children.map { child in
            child.getLatest()
        }
    }
    
    // MARK: - Private
    
    private func transform(_ node: Node) throws {
        guard
            let node = node as? TextNode,
            let parent = node.getParent()
        else { return }
        
        if let parent = parent as? AutoLinkNode {
            try handleLinkEdit(linkNode: parent)
        } else if !(parent is LinkNode) {
            try handleBadNeighbors(textNode: node)
            
            if node.isSimpleText() {
                try handleLinkCreation(node: node)
            }
            
            
        }
    }
    
    private func findFirstMatch(text: String) -> [LinkMatcher] {
        var linkMatcher = [LinkMatcher]()
        let types: NSTextCheckingResult.CheckingType = [.link]
        let detector = try? NSDataDetector(types: types.rawValue)
        let range = NSRange(text.startIndex..<text.endIndex, in: text)
        var index = -1
        
        detector?.enumerateMatches(in: text, options: [], range: range) { match, flags, _ in
            index += 1
            guard let match else {
                return
            }
            
            switch match.resultType {
            case .link:
                let label = String(text[Range(match.range, in: text)!])
                let url =  match.url?.absoluteString.lowercased() ?? ""
                linkMatcher.append(LinkMatcher(index: index, text: label, url: url, range: match.range))
            default:
                return
            }
        }
        
        return linkMatcher
    }
    
//    private func findFirstMatch(text: String) -> [LinkMatcher] {
//        var linkMatchers = [LinkMatcher]()
//        // Votre expression régulière
//        let pattern = "((https?:\\/\\/(www\\.)?)|(www\\.))[-a-zA-Z0-9@:%._+~#=]{1,256}\\.[a-zA-Z0-9()]{1,6}\\b([-a-zA-Z0-9()@:%_+.~#?&//=]*)"
//        
//        // On utilise NSRegularExpression pour la recherche avec un pattern personnalisé
//        guard let regex = try? NSRegularExpression(pattern: pattern, options: [.caseInsensitive]) else {
//            return []
//        }
//        
//        let range = NSRange(text.startIndex..<text.endIndex, in: text)
//        let matches = regex.matches(in: text, options: [], range: range)
//        
//        // On boucle sur tous les résultats trouvés
//        for (index, match) in matches.enumerated() {
//            // On s'assure que la range est valide pour extraire le texte
//            guard let matchRange = Range(match.range, in: text) else { continue }
//            
//            let label = String(text[matchRange])
//            
//            // On s'assure que l'URL est valide (en ajoutant "https://" si nécessaire)
//            var urlString = label
//            if urlString.lowercased().hasPrefix("www.") {
//                urlString = "https://\(urlString)"
//            }
//            
//            linkMatchers.append(
//                LinkMatcher(
//                    index: index,
//                    text: label,
//                    url: urlString.lowercased(),
//                    range: match.range
//                )
//            )
//        }
//        
//        return linkMatchers
//    }
    
    private func handleLinkCreation(node: TextNode) throws {
        let nodeText = node.getTextContent()
        let nodeTextLength = nodeText.lengthAsNSString()
        let text = nodeText
        var textOffset = 0
        var lastNode = node
        let matches = findFirstMatch(text: text)
        if matches.count == 0 {
            return
        }
        
        for match in matches {
            let matchOffset = match.range.location
            let offset = textOffset + matchOffset
            let matchLength = match.range.length
            
            // Previous node is valid if any of:
            // 1. Space before same node
            // 2. Space in previous simple text node
            // 3. Previous node is LineBreakNode
            let contentBeforeMatchIsValid: Bool
            
            if offset > 0 {
                let index = nodeText.index(nodeText.startIndex, offsetBy: offset)
                let beforeIndex = nodeText.index(before: index)
                contentBeforeMatchIsValid = nodeText[beforeIndex..<index] == " "
            } else {
                contentBeforeMatchIsValid = isPreviousNodeValid(node: node)
            }
            
            // Next node is valid if any of:
            // 1. Space after same node
            // 2. Space in next simple text node
            // 3. Next node is LineBreakNode
            let contentAfterMatchIsValid: Bool
            
            if offset + matchLength < nodeTextLength {
                let index = nodeText.index(nodeText.startIndex, offsetBy: offset + matchLength)
                let afterIndex = nodeText.index(after: index)
                contentAfterMatchIsValid = nodeText[index..<afterIndex] == " "
            } else {
                contentAfterMatchIsValid = isNextNodeValid(node: node)
            }
            
            if contentAfterMatchIsValid && contentBeforeMatchIsValid {
                var middleNode: Node?
                
                if matchOffset == 0 {
                    let nodes = try lastNode.splitText(splitOffsets: [matchLength])
                    if nodes.count > 1 {
                        middleNode = nodes[0]
                        lastNode = nodes.count == 2 ? nodes[1] : lastNode
                    } else if nodes.count == 1 {
                        middleNode = nodes[0]
                    }
                } else {
                    let nodes = try lastNode.splitText(splitOffsets: [matchOffset, matchOffset + matchLength])
                    if nodes.count >= 2 {
                        // ignore the first node
                        middleNode = nodes[1]
                        lastNode = nodes.count == 3 ? nodes[2] : lastNode
                    }
                }
                
                let linkNode = createAutoLinkNode(url: match.url)
                try linkNode.append([createTextNode(text: match.text)])
                try middleNode?.replace(replaceWith: linkNode)
                try linkNode.selectEnd()
                
            }
            
            textOffset += (matchOffset + matchLength)
        }
        
        
    }
    
    private func handleLinkEdit(linkNode: LinkNode) throws {
        // Check children are simple text
        let children = linkNode.getChildren()
        
        for child in children {
            if !(child is TextNode) {
                try replaceWithChildren(node: linkNode)
                return
            }
            
            if let child = child as? TextNode, !child.isSimpleText() {
                try replaceWithChildren(node: linkNode)
                return
            }
        }
        
        // Check text content fully matches
        let text = linkNode.getTextContent()
        let matches = findFirstMatch(text: text)
        
        if matches.count == 0 {
            try replaceWithChildren(node: linkNode)
            return
        } else if matches.count > 1 && matches[0].text != text {
            return
        }
        
//        // Check neighbors
//        if !isPreviousNodeValid(node: linkNode) || !isNextNodeValid(node: linkNode) {
//            try replaceWithChildren(node: linkNode)
//            return
//        }
        
        let url = linkNode.getURL()
        
        if matches.count >= 1, matches[0].url != url {
            try linkNode.setURL(matches[0].url)
        }
    }
    
    // Bad neighbours are edits in neighbor nodes that make AutoLinks incompatible.
    // Given the creation preconditions, these can only be simple text nodes.
    private func handleBadNeighbors(textNode: TextNode) throws {
        let previousSibling = textNode.getPreviousSibling()
        let nextSibling = textNode.getNextSibling()
        let text = textNode.getTextContent()
        var newTextNode = textNode
        
        let startChar = String(text[text.startIndex])
        if let previousSibling = previousSibling as? LinkNode, startChar != " " {
            
            if let index = text.firstIndex(of: " ") {
                let distance = text.distance(from: text.startIndex, to: index)
                let textNodes = try textNode.splitText(splitOffsets: [distance])
                
                if textNodes.count > 1 {
                    newTextNode = textNodes.first!
                }
            }
            
            try previousSibling.append([newTextNode])
            if previousSibling is AutoLinkNode {
                try handleLinkEdit(linkNode: previousSibling)
            }
//            try replaceWithChildren(node: previousSibling)
        }
        
        let endIndex = text.index(before: text.endIndex)
        let lastChar = String(text[endIndex])
        if let nextSibling = nextSibling as? LinkNode, lastChar != " " {
            if let index = text.lastIndex(of: " ") {
                let distance = text.distance(from: index, to: text.endIndex)
                let textNodes = try textNode.splitText(splitOffsets: [distance])
                
                if textNodes.count > 1 {
                    newTextNode = textNodes.last!
                }
            }
            
            try nextSibling.getFirstChild()?.insertBefore(nodeToInsert: newTextNode)
//            try replaceWithChildren(node: nextSibling)
            if nextSibling is AutoLinkNode {
                try handleLinkEdit(linkNode: nextSibling)
            }
        }
    }
}

