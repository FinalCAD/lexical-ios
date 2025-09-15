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
import LexicalAutoLinkPlugin
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
        let autolinkPlugin = AutoLinkPlugin()
        
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
                htmlPlugin,
                autolinkPlugin
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
        
        UserDefaults.standard.set(jsonString, forKey: editorStatePersistenceKey)
    }
    
    func importHtml() {
        guard let editor = lexicalView?.editor else {
            return
        }
        
        
//        let html = """
//<p><span style="color: rgb(65, 117, 5); white-space: pre-wrap;">he playground</span><span style="background-color: rgb(126, 211, 33); white-space: pre-wrap;"> is a demo environm</span></p>
//"""
        
        let html = """
<h1><span>Welcome to the playground</span></h1><blockquote><span>In case you were wondering what the black box at the bottom is – it's the debug view, showing the current state of the editor. You can disable it by pressing on the settings control in the bottom-left of your screen and toggling the debug view setting.</span></blockquote><p style="text-align:center"><span>The playground is a demo environment built with</span><code spellcheck="false"><span>@lexical/react</span></code><span>. Try typing in</span><b><strong>some text</strong></b><span style="background-color:#b8e986;color:#4a4a4a;">with</span><i><em>different</em></i><span>formats.</span></p><p><span>Make sure to check out the various plugins in the toolbar. You can also use</span><span>#hashtags</span><span>or @-mentions too!</span></p><p><span>If you'd like to find out more about Lexical, you can:</span></p><ul><li value="1" style="--listitem-marker-color:#4a4a4a;text-align:right"><span style="color:#4a4a4a;">Vi</span><span style="background-color:#b8e986;color:#4a4a4a;">sit the</span><a href="https://lexical.dev/"><span style="background-color:#b8e986;color:#4a4a4a;">Lexical website</span></a><span style="background-color:#b8e986;color:#4a4a4a;">for documentatio</span><span style="color:#4a4a4a;">n and more information.</span></li><li value="2"><span>Check out the code on our</span><a href="https://github.com/facebook/lexical"><span>GitHub repository</span></a><span>.</span></li><li value="3"><span>Playground code can be found</span><a href="https://github.com/facebook/lexical/tree/main/packages/lexical-playground"><span>here</span></a><span>.</span></li><li value="4" style="text-align:right"><span>Join our</span><a href="https://discord.com/invite/KmG4wQnnD9"><span>Discord Server</span></a><span>and chat with the team.</span></li><li value="5"><ul><li value="1"><span>awddwadwa</span></li></ul></li></ul><p><br></p><ol><li value="1"><span>awdwaddaw</span></li><li value="2" style="text-align:right"><span>awdwad</span></li><li value="2"><span>awdwad</span></li><li value="3"><ol><li value="1"><span>awdawd</span></li><li value="2"><ol l3"><li value="1"><span>wadawdaw</span></li></ol></li></ol></li></ol><p><span>Lastly, we're constantly adding cool new features to this playground. So make sure you check back here when you next get a chance</span><span><span>🙂</span></span><span>.</span></p>
"""
        
//        let html = """
//            <p><span></span></p>
//            <ol><li><span>toto</span></li><li><span></span></li></ol>
//            """
        
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
