//
//  Document.swift
//  Codify
//
//  Created by Brian Partridge on 3/6/16.
//  Copyright © 2016 Pear Tree Labs. All rights reserved.
//

import Cocoa

class Document: NSDocument {

    // MARK: - Outlets
    
    @IBOutlet var textView: NSTextView!
    
    // MARK: - Private Properties
    
    /// Temporary storage for document data between when the document is loaded and the window is presented.
    private var pendingDocumentData: NSData?

    // MARK: - NSDocument
    
    override func windowControllerDidLoadNib(aController: NSWindowController) {
        super.windowControllerDidLoadNib(aController)

        if let _ = textView, pendingDocumentData = pendingDocumentData {
            updateTextViewWithData(pendingDocumentData)
        }
    }

    override class func autosavesInPlace() -> Bool {
        return true
    }

    override var windowNibName: String? {
        return "Document"
    }

    override func dataOfType(typeName: String) throws -> NSData {
        let attributedString = textView?.textStorage
        let range = NSMakeRange(0, attributedString?.length ?? 0)
        return attributedString?.RTFDFromRange(range, documentAttributes: [:]) ?? NSData()
    }

    override func readFromData(data: NSData, ofType typeName: String) throws {
        if let _ = textView {
            updateTextViewWithData(data)
        } else {
            pendingDocumentData = data
        }
    }
    
    // MARK: - Private Methods
    
    private func updateTextViewWithData(data: NSData) {
        let attributedString = NSAttributedString(RTFD: data, documentAttributes: nil) ?? NSAttributedString(string: "")
        textView?.textStorage?.setAttributedString(attributedString)
    }
}

