//
//  HTMLImportPlugin.swift
//  Lexical
//
//  Created by Julien SMOLARECK on 22/08/2025.
//

import SwiftSoup
import Lexical

public class HTMLImportPlugin: Plugin {
    weak var editor: Editor?
    
    public func setUp(editor: Lexical.Editor) {
        self.editor = editor
    }
    
    public func tearDown() {
        self.editor = nil
    }
    
    
}
