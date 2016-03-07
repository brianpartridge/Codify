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
    @IBOutlet var previewTextView: NSTextView!
    
    // MARK: - Private Properties
    
    /// Temporary storage for document data between when the document is loaded and the window is presented.
    private var pendingDocumentData: NSData?

    // MARK: - NSDocument
    
    override func windowControllerDidLoadNib(aController: NSWindowController) {
        super.windowControllerDidLoadNib(aController)

        guard let editorTextView = editorTextView, _ = previewTextView else { fatalError("TextViews not loaded.") }
        
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
        updatePreviewWithContent(editorContent, selections: [])
    }
    
    func textViewDidChangeSelection(notification: NSNotification) {
        guard let editorContent = editorTextView.textStorage else { return }
        let ranges = editorTextView.selectedRanges.map { $0.rangeValue }
        updatePreviewWithContent(editorContent, selections: ranges)
    }
    
    // MARK: - Private Methods
    
    /// Populate the editor with the given text content.
    private func updateEditorWithData(data: NSData) {
        let attributedString = NSAttributedString(RTFD: data, documentAttributes: nil) ?? NSAttributedString(string: "")
        editorTextView?.textStorage?.setAttributedString(attributedString)
        updatePreviewWithContent(attributedString, selections: [])
    }
    
    /// Populate the preview with the given text and selections.
    private func updatePreviewWithContent(content: NSAttributedString, selections: [NSRange]) {
        let desaturatedContent = desaturatedAttributedString(content, excludedRanges: selections)
        previewTextView?.textStorage?.setAttributedString(desaturatedContent)
    }
    
    /// Desaturate the given attributed string except for the specified ranges.
    private func desaturatedAttributedString(attributedString: NSAttributedString, excludedRanges: [NSRange]) -> NSAttributedString {
        let sourceRange = NSMakeRange(0, attributedString.length)
        let rangesToDesaturate = rangesBySubtractingRanges(excludedRanges, fromRange: sourceRange)
        return desaturateRanges(rangesToDesaturate, inAttributedString: attributedString)
    }
    
    /// Identifies subranges within sourceRance after subtracing the given subranges.
    private func rangesBySubtractingRanges(rangesToSubtract: [NSRange], fromRange sourceRange: NSRange) -> [NSRange] {
        // We know which ranges to exclude, so calculate the ranges to desaturate.
        // Use and NSIndexSet and then extract the ranges from that.
        let indexSet = NSMutableIndexSet(indexesInRange: sourceRange)
        for range in rangesToSubtract {
            indexSet.removeIndexesInRange(range)
        }
        
        var resultRanges = [NSRange]()
        indexSet.enumerateRangesUsingBlock { (range, stop) in
            resultRanges.append(range)
        }
        return resultRanges
    }
    
    /// Convenience wrapper around `desaturateRange` for multiple ranges.
    private func desaturateRanges(ranges:[NSRange], inAttributedString attributedString: NSAttributedString) -> NSAttributedString {
        var resultString = attributedString.copy() as! NSAttributedString
        for range in ranges {
            resultString = self.desaturateRange(range, inAttributedString: resultString)
        }
        return resultString
    }
    
    /// Adjust the foreground color of the given attributed string.
    private func desaturateRange(range: NSRange, inAttributedString attributedString: NSAttributedString) -> NSAttributedString {
        let desaturatedString = attributedString.mutableCopy() as! NSMutableAttributedString
        desaturatedString.addAttribute(NSForegroundColorAttributeName,
            value: NSColor(white: 0.6, alpha: 1.0),
            range: range)
        return desaturatedString.copy() as! NSAttributedString
    }
}

