/*
 * Copyright (c) Meta Platforms, Inc. and affiliates.
 *
 * This source code is licensed under the MIT license found in the
 * LICENSE file in the root directory of this source tree.
 */

import EditorHistoryPlugin
import Lexical
import LexicalInlineImagePlugin
import LexicalLinkPlugin
import LexicalListPlugin
import UIKit
import LexicalHTML
import SwiftSoup

class ViewController: UIViewController, UIToolbarDelegate {
    
    var lexicalView: LexicalView?
    weak var toolbar: UIToolbar?
    weak var hierarchyView: UIView?
    private let editorStatePersistenceKey = "editorState"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        
        let editorHistoryPlugin = EditorHistoryPlugin()
        let toolbarPlugin = ToolbarPlugin(viewControllerForPresentation: self, historyPlugin: editorHistoryPlugin)
        let toolbar = toolbarPlugin.toolbar
        toolbar.delegate = self
        
        let hierarchyPlugin = NodeHierarchyViewPlugin()
        let hierarchyView = hierarchyPlugin.hierarchyView
        
        let listPlugin = ListPlugin()
        let imagePlugin = InlineImagePlugin()
        let htmlPlugin = HTMLPlugin()
        
        let linkPlugin = LinkPlugin()
        
        let theme = Theme()
        theme.indentSize = 40.0
        theme.text = [
            .lineHeight: 32.0,
            .lineSpacing: 50
        ]
        theme.link = [
            .foregroundColor: UIColor.systemBlue,
        ]
        
        let editorConfig = EditorConfig(
            theme: theme,
            plugins: [
                toolbarPlugin,
                listPlugin,
                hierarchyPlugin,
                imagePlugin,
                linkPlugin,
                editorHistoryPlugin,
                htmlPlugin
            ]
        )
        let lexicalView = LexicalView(editorConfig: editorConfig, featureFlags: FeatureFlags())
        
        linkPlugin.lexicalView = lexicalView
        
        self.lexicalView = lexicalView
        self.toolbar = toolbar
        self.hierarchyView = hierarchyView
        
//        self.restoreEditorState()
        
        self.importHtml()
        
        
        view.addSubview(lexicalView)
        view.addSubview(toolbar)
        view.addSubview(hierarchyView)
        
        navigationItem.title = "Lexical"
        setUpExportMenu()
        
        let removeUpdateListener = lexicalView.editor.registerUpdateListener(listener: { activeEditorState, previousEditorState,dirtyNodes in
            // turn the editor state into stringified JSON
            guard let jsonString = try? activeEditorState.toJSON() else {
                return
            }
            
            print("Persist \(jsonString)")
        })
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        if let lexicalView, let toolbar, let hierarchyView {
            let safeAreaInsets = self.view.safeAreaInsets
            let hierarchyViewHeight = 300.0
            
            toolbar.frame = CGRect(
                x: 0,
                y: safeAreaInsets.top,
                width: view.bounds.width,
                height: 44)
            lexicalView.frame = CGRect(
                x: 0,
                y: toolbar.frame.maxY,
                width: view.bounds.width,
                height: view.bounds.height - toolbar.frame.maxY - safeAreaInsets.bottom - hierarchyViewHeight)
            hierarchyView.frame = CGRect(
                x: 0,
                y: lexicalView.frame.maxY,
                width: view.bounds.width,
                height: hierarchyViewHeight)
        }
        
        
    }
    
    func persistEditorState() {
        guard let editor = lexicalView?.editor else {
            return
        }
        
        let currentEditorState = editor.getEditorState()
        
        // turn the editor state into stringified JSON
        guard let jsonString = try? currentEditorState.toJSON() else {
            return
        }
        
        print("Persist \(jsonString)")
        UserDefaults.standard.set(jsonString, forKey: editorStatePersistenceKey)
    }
    
    func importHtml() {
        guard let editor = lexicalView?.editor else {
            return
        }
        
        
//        let html = """
//<p class="PlaygroundEditorTheme__paragraph"><span style="color: rgb(65, 117, 5); white-space: pre-wrap;">he playground</span><span style="background-color: rgb(126, 211, 33); white-space: pre-wrap;"> is a demo environm</span></p>
//"""
        
        let html = """
<h1 class="PlaygroundEditorTheme__h1"><span style="white-space:pre-wrap">Welcome to the playground</span></h1><blockquote class="PlaygroundEditorTheme__quote"><span style="white-space:pre-wrap">In case you were wondering what the black box at the bottom is – it's the debug view, showing the current state of the editor. You can disable it by pressing on the settings control in the bottom-left of your screen and toggling the debug view setting.</span></blockquote><p class="PlaygroundEditorTheme__paragraph"><a href="https://github.com/facebook/lexical" class="PlaygroundEditorTheme__link"><span style="white-space: pre-wrap;">GitHub repository</span></a><span style="white-space: pre-wrap;">T</span><span style="color: rgb(65, 117, 5); white-space: pre-wrap;">he playground</span><span style="background-color: rgb(126, 211, 33); white-space: pre-wrap;"> is a demo environm</span><span style="white-space: pre-wrap;">ent built with </span><code spellcheck="false" style="white-space: pre-wrap;"><span class="PlaygroundEditorTheme__textCode">@lexical/react</span></code><span style="white-space:pre-wrap">. Try typing in</span><b><strong class="PlaygroundEditorTheme__textBold" style="white-space:pre-wrap">some text</strong></b><span style="white-space:pre-wrap">with</span><i><em class="PlaygroundEditorTheme__textItalic" style="white-space:pre-wrap">different</em></i><span style="white-space:pre-wrap">formats.</span></p><p class="PlaygroundEditorTheme__paragraph"><span style="white-space:pre-wrap">Make sure to check out the various plugins in the toolbar. You can also use</span><span class="PlaygroundEditorTheme__hashtag" style="white-space:pre-wrap">#hashtags</span><span style="white-space:pre-wrap">or @-mentions too!</span></p><p class="PlaygroundEditorTheme__paragraph"><span style="white-space:pre-wrap">If you'd like to find out more about Lexical, you can:</span></p><ul class="PlaygroundEditorTheme__ul"><li value="1" class="PlaygroundEditorTheme__listItem"><span style="white-space:pre-wrap">Visit the</span><a href="https://lexical.dev/" class="PlaygroundEditorTheme__link"><span style="white-space:pre-wrap">Lexical website</span></a><span style="white-space:pre-wrap">for documentation and more information.</span></li><li value="2" class="PlaygroundEditorTheme__listItem"><span style="white-space:pre-wrap">Check out the code on our</span><a href="https://github.com/facebook/lexical" class="PlaygroundEditorTheme__link"><span style="white-space:pre-wrap">GitHub repository</span></a><span style="white-space:pre-wrap">.</span></li><li value="3" class="PlaygroundEditorTheme__listItem"><span style="white-space:pre-wrap">Playground code can be found</span><a href="https://github.com/facebook/lexical/tree/main/packages/lexical-playground" class="PlaygroundEditorTheme__link"><span style="white-space:pre-wrap">here</span></a><span style="white-space:pre-wrap">.</span></li><li value="4" class="PlaygroundEditorTheme__listItem"><span style="white-space:pre-wrap">Join our</span><a href="https://discord.com/invite/KmG4wQnnD9" class="PlaygroundEditorTheme__link"><span style="white-space:pre-wrap">Discord Server</span></a><span style="white-space:pre-wrap">and chat with the team.</span></li></ul><ol class="PlaygroundEditorTheme__ul"><li value="1" class="PlaygroundEditorTheme__listItem"><span style="white-space:pre-wrap">Visit the </span><a href="https://lexical.dev/" class="PlaygroundEditorTheme__link"><span style="white-space:pre-wrap">Lexical website</span></a><span style="white-space:pre-wrap">for documentation and more information.</span></li><li value="2" class="PlaygroundEditorTheme__listItem"><span style="white-space:pre-wrap">Check out the code on our</span><a href="https://github.com/facebook/lexical" class="PlaygroundEditorTheme__link"><span style="white-space:pre-wrap">GitHub repository</span></a><span style="white-space:pre-wrap">.</span></li><li value="3" class="PlaygroundEditorTheme__listItem"><span style="white-space:pre-wrap">Playground code can be found</span><a href="https://github.com/facebook/lexical/tree/main/packages/lexical-playground" class="PlaygroundEditorTheme__link"><span style="white-space:pre-wrap">here</span></a><span style="white-space:pre-wrap">.</span></li><li value="4" class="PlaygroundEditorTheme__listItem"><span style="white-space:pre-wrap">Join our</span><a href="https://discord.com/invite/KmG4wQnnD9" class="PlaygroundEditorTheme__link"><span style="white-space:pre-wrap">Discord Server</span></a><span style="white-space:pre-wrap">and chat with the team.</span></li><li value="6" class="PlaygroundEditorTheme__listItem PlaygroundEditorTheme__nestedListItem"><ol class="PlaygroundEditorTheme__ol2"><li value="1" class="PlaygroundEditorTheme__listItem"><span style="white-space: pre-wrap;">awdwadaw</span></li><li value="2" class="PlaygroundEditorTheme__listItem"><span style="white-space: pre-wrap;">wadwadawd</span></li></ol></li></ol><p class="PlaygroundEditorTheme__paragraph"><span style="white-space:pre-wrap">Lastly, we're constantly adding cool new features to this playground. So make sure you check back here when you next get a chance</span><span class="emoji happysmile" style="white-space:pre-wrap"><span class="emoji-inner">🙂</span></span><span style="white-space:pre-wrap">.</span></p>
"""
        
        
        
        guard let body: Document = try? SwiftSoup.parse(html.replacingOccurrences(of: "\n", with: "")) else {
            return
        }
        
        
       
        
        
        do {
            try editor.update {
                let nodes = try generateNodesFromDOM(editor: editor, dom: body)
                
                let editorState = editor.getEditorState()
                
                guard let rootNode = editorState.getRootNode() else {
                    return
                }
                
                
                
                let selection = try rootNode.selectStart()
                if try selection.insertNodes(nodes: nodes, selectStart: false) == false {
                    print("NOT INSERT NODES")
                }
            }
            
//            // turn the JSON back into a new editor state
            
            
//            guard let newEditorState = try? EditorState.fromJSON(json: jsonString, editor: editor) else {
//                return
//            }
//
            // install the new editor state into editor
//            try editor.setEditorState(newEditorState)
        
//            let nodes = convertToLexical(node: body)
//            try editor.getEditorState().getRootNode()?.append(nodes)
        } catch {
            print("ERROR \(error)")
        }
        
    }
    
    func convertToLexical(node: SwiftSoup.Node) -> [Lexical.Node] {
        guard let editor = lexicalView?.editor else {
            return []
        }
        
        var nodes = [Lexical.Node]()
        
        for child in node.getChildNodes() {
            switch child {
            case let node as SwiftSoup.Element:
                switch node.tagName() {
                case "p":
                    let paragraph = createParagraphNode()
                    try? paragraph.append(convertToLexical(node: node))
                    nodes.append(paragraph)
                case "span":
                    let text = createTextNode(text: (try? node.text()) ?? "")
                    nodes.append(text)
                default:
                    print("UNKNOW \(node.tagName())")
                }
            default:
                print("unknown node \(child)")
            }
        }
        
        
        print("\(nodes.count)")
        return nodes
        
    }
    
    func restoreEditorState() {
        guard let editor = lexicalView?.editor else {
            return
        }
        
        guard let jsonString = UserDefaults.standard.value(forKey: editorStatePersistenceKey) as? String else {
            return
        }
        
        // turn the JSON back into a new editor state
        guard let newEditorState = try? EditorState.fromJSON(json: jsonString, editor: editor) else {
            return
        }
        
        // install the new editor state into editor
        try? editor.setEditorState(newEditorState)
    }
    
    func setUpExportMenu() {
        let menuItems = OutputFormat.allCases.map { outputFormat in
            UIAction(
                title: "Export \(outputFormat.title)",
                handler: { [weak self] action in
                    self?.showExportScreen(outputFormat)
                })
        }
        let menu = UIMenu(title: "Export as…", children: menuItems)
        let barButtonItem = UIBarButtonItem(title: "Export", style: .plain, target: nil, action: nil)
        barButtonItem.menu = menu
        navigationItem.rightBarButtonItem = barButtonItem
    }
    
    func showExportScreen(_ type: OutputFormat) {
        guard let editor = lexicalView?.editor else { return }
        let vc = ExportOutputViewController(editor: editor, format: type)
        navigationController?.pushViewController(vc, animated: true)
    }
    
    func position(for bar: UIBarPositioning) -> UIBarPosition {
        return .top
    }
}
