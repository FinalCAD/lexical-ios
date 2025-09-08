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
    @Test
    func importDOM() throws {
        let conversion = try HeadingNode.importDOM()
        
        try [
            SwiftSoup.Element(.init("h1"), ""),
            SwiftSoup.Element(.init("h2"), ""),
            SwiftSoup.Element(.init("h3"), ""),
            SwiftSoup.Element(.init("h4"), ""),
            SwiftSoup.Element(.init("h5"), "")
        ].forEach {
            let tagName = $0.tagName()
            
            guard let conversion = conversion[tagName] else {
                fatalError()
            }
            
            let node = try conversion($0).node.first
            
            #expect(node is Lexical.HeadingNode)
            #expect((node as? Lexical.HeadingNode)?.getTag().rawValue == tagName)
        }
    }
    
    @Test func exportDOM() throws {
        
    }
}
