/*
 * Copyright (c) Meta Platforms, Inc. and affiliates.
 *
 * This source code is licensed under the MIT license found in the
 * LICENSE file in the root directory of this source tree.
 */

import Foundation

public func updateTextFormat(type: TextFormatType, editor: Editor) throws {
  guard getActiveEditor() != nil else {
    throw LexicalError.invariantViolation("Must have editor")
  }
  guard let selection = try getSelection() as? RangeSelection else {
    return
  }

  try selection.formatText(formatType: type)
}

public func patchStyleText(styles: [PartialKeyPath<TextNodeStyle>: Any], editor: Editor) throws {
    guard getActiveEditor() != nil else {
        throw LexicalError.invariantViolation("Must have editor")
    }
    guard let selection = try getSelection() as? RangeSelection else {
        return
    }
    
    try selection.apply(styles: styles)
}

public func updateElementFormat(type: ElementFormatType, editor: Editor) throws {
    guard getActiveEditor() != nil else {
        throw LexicalError.invariantViolation("Must have editor")
    }
    
    guard let selection = try getSelection() as? RangeSelection else {
        return
    }
    
    for node in try selection.getNodes() {
        if let decoratorNode = node as? DecoratorNode {
            
        } else {
            let element = try getNearestBlockElementAncestorOrThrow(startNode: node)
            try element.setFormat(type)
        }
    }
}
