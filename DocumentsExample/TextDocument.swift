//
//  TextDocument.swift
//
//  Created by Chris Van Buskirk on 2/9/25.
//

import UIKit

class TextDocument: UIDocument {
    
    // Add text property to store document content
    public var text: String? = nil {
        didSet {
            if text != oldValue && oldValue != nil {
                if let undoManager = self.undoManager {
                    let oldText = oldValue
                    undoManager.registerUndo(withTarget: self) { document in
                        document.text = oldText
                        // Register redo when undoing
                        document.undoManager?.registerUndo(withTarget: document) { target in
                            target.text = self.text
                        }
                    }
                    undoManager.setActionName("Text Change")
                }
                self.updateChangeCount(.done)
            }
        }
    }
    
    override func contents(forType typeName: String) throws -> Any {
        // Convert text to Data for saving
        guard let text = text else {
            return Data()
        }
        return text.data(using: .utf8) ?? Data()
    }
    
    override func load(fromContents contents: Any, ofType typeName: String?) throws {
        // Load text from the provided contents
        guard let data = contents as? Data else {
            throw CocoaError(.fileReadCorruptFile)
        }
        
        // Empty data means nil text
        if data.isEmpty {
            text = nil
            return
        }
        
        guard let loadedText = String(data: data, encoding: .utf8) else {
            throw CocoaError(.fileReadCorruptFile)
        }
        text = loadedText
    }
}

