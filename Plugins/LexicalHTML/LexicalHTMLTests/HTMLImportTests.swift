/*
 * Copyright (c) Meta Platforms, Inc. and affiliates.
 *
 * This source code is licensed under the MIT license found in the
 * LICENSE file in the root directory of this source tree.
 */

import Foundation
import XCTest
import SwiftSoup

@testable import Lexical
@testable import LexicalHTML

class HTMLImportTests: XCTestCase {
    var lexicalView: LexicalView?
    var editor: Editor? {
        get {
            return lexicalView?.editor
        }
    }
    
    override func setUp() {
        lexicalView = LexicalView(editorConfig: EditorConfig(theme: Theme(), plugins: []), featureFlags: FeatureFlags())
    }
    
    override func tearDown() {
        lexicalView = nil
    }

    
    func testNodesToHTML() throws {
        guard let editor else {
            XCTFail()
            return
        }
        
        let html = """
<h1 class="PlaygroundEditorTheme__h1"><span style="white-space:pre-wrap">Welcome to the playground</span></h1><blockquote class="PlaygroundEditorTheme__quote"><span style="white-space:pre-wrap">In case you were wondering what the black box at the bottom is – it's the debug view, showing the current state of the editor. You can disable it by pressing on the settings control in the bottom-left of your screen and toggling the debug view setting.</span></blockquote><p class="PlaygroundEditorTheme__paragraph"><a href="https://github.com/facebook/lexical" class="PlaygroundEditorTheme__link"><span style="white-space: pre-wrap;">GitHub repository</span></a><span style="white-space: pre-wrap;">T</span><span style="color: rgb(65, 117, 5); white-space: pre-wrap;">he playground</span><span style="background-color: rgb(126, 211, 33); white-space: pre-wrap;"> is a demo environm</span><span style="white-space: pre-wrap;">ent built with </span><code spellcheck="false" style="white-space: pre-wrap;"><span class="PlaygroundEditorTheme__textCode">@lexical/react</span></code><span style="white-space:pre-wrap">. Try typing in</span><b><strong class="PlaygroundEditorTheme__textBold" style="white-space:pre-wrap">some text</strong></b><span style="white-space:pre-wrap">with</span><i><em class="PlaygroundEditorTheme__textItalic" style="white-space:pre-wrap">different</em></i><span style="white-space:pre-wrap">formats.</span></p><p class="PlaygroundEditorTheme__paragraph"><span style="white-space:pre-wrap">Make sure to check out the various plugins in the toolbar. You can also use</span><span class="PlaygroundEditorTheme__hashtag" style="white-space:pre-wrap">#hashtags</span><span style="white-space:pre-wrap">or @-mentions too!</span></p><p class="PlaygroundEditorTheme__paragraph"><span style="white-space:pre-wrap">If you'd like to find out more about Lexical, you can:</span></p><ul class="PlaygroundEditorTheme__ul"><li value="1" class="PlaygroundEditorTheme__listItem"><span style="white-space:pre-wrap">Visit the</span><a href="https://lexical.dev/" class="PlaygroundEditorTheme__link"><span style="white-space:pre-wrap">Lexical website</span></a><span style="white-space:pre-wrap">for documentation and more information.</span></li><li value="2" class="PlaygroundEditorTheme__listItem"><span style="white-space:pre-wrap">Check out the code on our</span><a href="https://github.com/facebook/lexical" class="PlaygroundEditorTheme__link"><span style="white-space:pre-wrap">GitHub repository</span></a><span style="white-space:pre-wrap">.</span></li><li value="3" class="PlaygroundEditorTheme__listItem"><span style="white-space:pre-wrap">Playground code can be found</span><a href="https://github.com/facebook/lexical/tree/main/packages/lexical-playground" class="PlaygroundEditorTheme__link"><span style="white-space:pre-wrap">here</span></a><span style="white-space:pre-wrap">.</span></li><li value="4" class="PlaygroundEditorTheme__listItem"><span style="white-space:pre-wrap">Join our</span><a href="https://discord.com/invite/KmG4wQnnD9" class="PlaygroundEditorTheme__link"><span style="white-space:pre-wrap">Discord Server</span></a><span style="white-space:pre-wrap">and chat with the team.</span></li></ul><ol class="PlaygroundEditorTheme__ul"><li value="1" class="PlaygroundEditorTheme__listItem"><span style="white-space:pre-wrap">Visit the </span><a href="https://lexical.dev/" class="PlaygroundEditorTheme__link"><span style="white-space:pre-wrap">Lexical website</span></a><span style="white-space:pre-wrap">for documentation and more information.</span></li><li value="2" class="PlaygroundEditorTheme__listItem"><span style="white-space:pre-wrap">Check out the code on our</span><a href="https://github.com/facebook/lexical" class="PlaygroundEditorTheme__link"><span style="white-space:pre-wrap">GitHub repository</span></a><span style="white-space:pre-wrap">.</span></li><li value="3" class="PlaygroundEditorTheme__listItem"><span style="white-space:pre-wrap">Playground code can be found</span><a href="https://github.com/facebook/lexical/tree/main/packages/lexical-playground" class="PlaygroundEditorTheme__link"><span style="white-space:pre-wrap">here</span></a><span style="white-space:pre-wrap">.</span></li><li value="4" class="PlaygroundEditorTheme__listItem"><span style="white-space:pre-wrap">Join our</span><a href="https://discord.com/invite/KmG4wQnnD9" class="PlaygroundEditorTheme__link"><span style="white-space:pre-wrap">Discord Server</span></a><span style="white-space:pre-wrap">and chat with the team.</span></li></ol><p class="PlaygroundEditorTheme__paragraph"><span style="white-space:pre-wrap">Lastly, we're constantly adding cool new features to this playground. So make sure you check back here when you next get a chance</span><span class="emoji happysmile" style="white-space:pre-wrap"><span class="emoji-inner">🙂</span></span><span style="white-space:pre-wrap">.</span></p>
"""
        
        try editor.update {
            measure {
                let body: Document = try! SwiftSoup.parse(html)
                let nodes = try! generateNodesFromDOM(editor: editor, dom: body)
            }
        }
    }
}
