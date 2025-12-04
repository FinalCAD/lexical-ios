/*
 * Copyright (c) Meta Platforms, Inc. and affiliates.
 *
 * This source code is licensed under the MIT license found in the
 * LICENSE file in the root directory of this source tree.
 */

import SwiftSoup
import Lexical
import Testing

@testable import LexicalHTML

struct HeadingNodeHTMLTests {
    
    @MainActor
    @Test
    func importDOM() throws {
        let view = LexicalView(editorConfig: EditorConfig(theme: Theme(), plugins: []), featureFlags: FeatureFlags())
    
        try view.editor.update {
            let conversions = try HeadingNode.importDOM()
            // Remplace forEach throwing par une boucle for classique
            let elements: [SwiftSoup.Element] = [
                SwiftSoup.Element(.init("h1"), ""),
                SwiftSoup.Element(.init("h2"), ""),
                SwiftSoup.Element(.init("h3"), ""),
                SwiftSoup.Element(.init("h4"), ""),
                SwiftSoup.Element(.init("h5"), "")
            ]
            for element in elements {
                let tagName = element.tagName()
                guard let entry = conversions[tagName] else {
                    fatalError("Missing conversion for tag: \(tagName)")
                }
                let node = try entry(element).node.first
                #expect(node is Lexical.HeadingNode)
                #expect((node as? Lexical.HeadingNode)?.getTag().rawValue == tagName)
            }
        }
    }
    
    @MainActor
    @Test func exportDOM() throws {
        let view = LexicalView(editorConfig: EditorConfig(theme: Theme(), plugins: []), featureFlags: FeatureFlags())
        
        try view.editor.update {
            let headingNode = HeadingNode(tag: .h1)
//            headingNode.setFormat(<#T##format: ElementFormatType##ElementFormatType#>)
            let dom = try headingNode.exportDOM(editor: view.editor)
            
            #expect(dom.element is SwiftSoup.Element)
            
            guard let element = dom.element as? SwiftSoup.Element else {
                fatalError("Expected SwiftSoup.Element")
            }

            #expect(element.tagName() == "h1")
            #expect(element.hasAttr("style"))
        }
    }
}
