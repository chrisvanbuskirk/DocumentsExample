//
//  RichDocument.swift
//
//  Created by Chris Van Buskirk on 2/9/25.
//

import UIKit

class RichDocument: UIDocument {
    
    // Store document content as an optional NSAttributedString
    public var attributedText: NSAttributedString? = nil {
        didSet {
            if attributedText != oldValue && oldValue != nil {
                if let undoManager = self.undoManager {
                    let oldText = oldValue
                    undoManager.registerUndo(withTarget: self) { document in
                        document.attributedText = oldText
                        // Register redo when undoing
                        document.undoManager?.registerUndo(withTarget: document) { target in
                            target.attributedText = self.attributedText
                        }
                    }
                    undoManager.setActionName("Attributed Text Change")
                }
                self.updateChangeCount(.done)
            }
        }
    }
    
    
    // Convert attributedText to RTF Data for saving
    override func contents(forType typeName: String) throws -> Any {
        guard let text = attributedText else {
            return Data()
        }
        
        let range = NSRange(location: 0, length: text.length)
        let data = try text.data(
            from: range,
            documentAttributes: [.documentType: NSAttributedString.DocumentType.rtf]
        )
        return data
    }
    
    // Load attributedText from Data (assuming RTF data format)
    override func load(fromContents contents: Any, ofType typeName: String?) throws {
        guard let data = contents as? Data else {
            throw CocoaError(.fileReadCorruptFile)
        }
        
        // Empty data means nil text
        if data.isEmpty {
            attributedText = nil
            return
        }
        
        let options: [NSAttributedString.DocumentReadingOptionKey: Any] = [
            .documentType: NSAttributedString.DocumentType.rtf
        ]
        attributedText = try NSAttributedString(data: data, options: options, documentAttributes: nil)
    }
} 
