/*
 * Copyright (c) Meta Platforms, Inc. and affiliates.
 *
 * This source code is licensed under the MIT license found in the
 * LICENSE file in the root directory of this source tree.
 */

import SwiftSoup
import Lexical

func isBlockDomNode(node: SwiftSoup.Node) -> Bool {
    [
        "address",
        "article",
        "aside",
        "blockquote",
        "canvas",
        "dd",
        "div",
        "dl",
        "dt",
        "fieldset",
        "figcaption",
        "figure",
        "footer",
        "form",
        "h1",
        "h2",
        "h3",
        "h4",
        "h5",
        "h6",
        "header",
        "hr",
        "li",
        "main",
        "nav",
        "noscript",
        "ol",
        "p",
        "pre",
        "section",
        "table",
        "td",
        "tfoot",
        "ul",
        "video"
    ].contains(
        (node as? SwiftSoup.Element)?
            .tagName() ?? ""
    )
}

func isRoot(node: Lexical.Node) -> Lexical.RootNode? {
    node as? Lexical.RootNode
}

func isRootOrShadowRoot(node: Lexical.Node) -> Bool {
    return node is Lexical.RootNode || (node as? Lexical.ElementNode)?.isShadowRoot() ?? false
}
