//
//  EditionListItemTests.swift
//  Lexical
//
//  Created by Julien SMOLARECK on 03/12/2025.
//

import XCTest

@testable import Lexical
@testable import LexicalListPlugin

class EditionListItemTests: XCTestCase {
    var view: LexicalView?
    
    var editor: Editor? {
        get {
            return view?.editor
        }
    }
    
    override func setUp() {
        view = LexicalView(editorConfig: EditorConfig(theme: Theme(), plugins: []), featureFlags: FeatureFlags())
    }
    
    override func tearDown() {
        view = nil
    }
    
    /*
     . Hello world 1 again
       . Nested item 1
       . Nested item 2
     . Hello world 2
     */
    private func generatesList() throws -> ListNode {
        let list = ListNode(listType: .bullet, start: 1, withPlaceholders: true)
        let item1 = ListItemNode()
        try item1.append([TextNode(text: "Hello world 1 again")])
        
        let item2 = ListItemNode()
        try item2.append([TextNode(text: "Hello world 2")])
        
        // Nested level
        let nestedList = ListNode(listType: .bullet, start: 1, withPlaceholders: true)
        
        let nestedListItem = ListItemNode()
        try nestedListItem.append([nestedList])
        
        let nestedItem1 = ListItemNode()
        try nestedItem1.append([TextNode(text: "Nested item 1")])
        
        let nestedItem2 = ListItemNode()
        try nestedItem2.append([TextNode(text: "Nested item 2")])
        
        try nestedList.append([nestedItem1, nestedItem2])
        
        // Putting it together
        try list.append([item1, nestedListItem, item2])
        return list
    }
    
    func createPoint(key: NodeKey, offset: Int, type: SelectionType) -> Point {
        Point(key: key, offset: offset, type: type)
    }
    
    func testBreaklineItem() throws {
        guard let editor else {
            XCTFail("Editor unexpectedly nil")
            return
        }
        
        try editor.update {
            guard
                let editorState = getActiveEditorState(),
                let rootNode = editorState.getRootNode() else {
                XCTFail("should have editor state")
                return
            }
            
            try rootNode.getFirstChild()?.replace(replaceWith: try generatesList())
            
            guard let listNode = getNodeByKey(key: "1") as? ListNode else { return }
            XCTAssertEqual(listNode.children.count, 3)
            
            guard let editorState = getActiveEditorState() else {
                XCTFail("should have editor state")
                return
            }
            
            guard let listItemNode = getNodeByKey(key: "2") as? ListItemNode else {
                XCTFail("Code node not found")
                return
            }
            
            guard let selection = editorState.selection as? RangeSelection else {
                XCTFail("Expected range selection")
                return
            }

            let _ = try listItemNode.insertNewAfter(selection: selection)
            XCTAssertEqual(listNode.children.count, 4)
            
            
            let startPoint = createPoint(key: listItemNode.key, offset: 14, type: .text)
            let endPoint = createPoint(key: listItemNode.key, offset: 16, type: .text)
            let newSelection = RangeSelection(anchor: startPoint, focus: endPoint, format: TextFormat(), style: TextNodeStyle())
            
            
            
            guard let newItemNode = try listItemNode.insertNewAfter(selection: newSelection).element as? ListItemNode else {
                XCTFail("Expected listItemNode")
                return
            }
            XCTAssertEqual(listNode.children.count, 5)
//            
//            let json = try editorState.toJSON()
//            print(json)
           
            
            guard let listItemNode1 = getNodeByKey(key: listItemNode.children[0]) as? TextNode,
                  let listItemNode2 = getNodeByKey(key: newItemNode.children[1]) as? TextNode
            else { return }
            
            XCTAssertEqual(listItemNode1.getTextPart(), "Hello world 1")
            XCTAssertEqual(listItemNode2.getTextPart(), "again")
        }
        
        try editor.read {
            let editorState = editor.getEditorState()
            let json = try editorState.toJSON()
            print(json)
            
//            guard let listNode = getNodeByKey(key: "1") as? ListNode else { return }
//            
//            guard let listItemNode1 = getNodeByKey(key: listNode.children[0]) as? ListItemNode,
//                  let listItemNode2 = getNodeByKey(key: listNode.children[1]) as? ListItemNode
//            else { return }
//            
//            XCTAssertEqual(listItemNode1.getTextPart(), "Hello world 1")
//            XCTAssertEqual(listItemNode2.getTextPart(), "again")
            
//            guard let paragraphNode = getNodeByKey(key: "1") as? ListNode else { return }
            
//
//            guard let textNode1 = getNodeByKey(key: paragraphNode.children[0]) as? TextNode,
//                  let textNode2 = getNodeByKey(key: paragraphNode.children[1]) as? TextNode
//            else { return }
//            
//            XCTAssertEqual(textNode1.getTextPart(), "Hello ")
//            XCTAssertEqual(textNode2.getTextPart(), "\u{200B}")
//            XCTAssertTrue(textNode2.format.bold)
        }
    }
}
