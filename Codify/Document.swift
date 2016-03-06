//
//  Document.swift
//  Codify
//
//  Created by Brian Partridge on 3/6/16.
//  Copyright © 2016 Pear Tree Labs. All rights reserved.
//

import Cocoa

class Document: NSDocument, NSTextViewDelegate {

    // MARK: - Outlets
    
    @IBOutlet var editorTextView: NSTextView!
    @IBOutlet var desaturatedTextView: NSTextView!
    
    // MARK: - Private Properties
    
    /// Temporary storage for document data between when the document is loaded and the window is presented.
    private var pendingDocumentData: NSData?

    // MARK: - NSDocument
    
    override func windowControllerDidLoadNib(aController: NSWindowController) {
        super.windowControllerDidLoadNib(aController)

        guard let editorTextView = editorTextView, _ = desaturatedTextView else { fatalError("TextViews not loaded.") }
        
        editorTextView.delegate = self
            
        if let pendingDocumentData = pendingDocumentData {
            updateEditorWithData(pendingDocumentData)
        }
    }

    override class func autosavesInPlace() -> Bool {
        return true
    }

    override var windowNibName: String? {
        return "Document"
    }

    override func dataOfType(typeName: String) throws -> NSData {
        let attributedString = editorTextView?.textStorage
        let range = NSMakeRange(0, attributedString?.length ?? 0)
        return attributedString?.RTFDFromRange(range, documentAttributes: [:]) ?? NSData()
    }

    override func readFromData(data: NSData, ofType typeName: String) throws {
        if let _ = editorTextView {
            updateEditorWithData(data)
        } else {
            pendingDocumentData = data
        }
    }
    
    // MARK: - NSTextViewDelegate
    
    func textDidChange(notification: NSNotification) {
        guard let editorContent = editorTextView.textStorage else { return }
        updateDesaturatedTextPreview(editorContent)
    }
    
    // MARK: - Private Methods
    
    private func updateEditorWithData(data: NSData) {
        let attributedString = NSAttributedString(RTFD: data, documentAttributes: nil) ?? NSAttributedString(string: "")
        editorTextView?.textStorage?.setAttributedString(attributedString)
        updateDesaturatedTextPreview(attributedString)
    }
    
    private func updateDesaturatedTextPreview(editorContent: NSAttributedString) {
        let desaturatedContent = editorContent
        desaturatedTextView?.textStorage?.setAttributedString(desaturatedContent)
    }
}

