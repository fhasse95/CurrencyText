//
//  UITextField.swift
//  CurrencyText
//
//  Created by Felipe Lefèvre Marino on 12/26/18.
//

#if os(watchOS)
#else

import UIKit

public extension UITextField {

    // MARK: Public

    var selectedTextRangeOffsetFromEnd: Int {
        return offset(from: endOfDocument, to: selectedTextRange?.end ?? endOfDocument)
    }

    /// Sets the selected text range when the text field is starting to be edited.
    /// _Should_ be called when text field start to be the first responder.
    func setInitialSelectedTextRange(
        currencySymbol: String,
        checkLanguageAlignment: Bool = true) {
        self.adjustSelectedTextRange(
            lastOffsetFromEnd: 0,
            currencySymbol,
            checkLanguageAlignment)
    }
    
    /// Interface to update the selected text range as expected.
    func updateSelectedTextRange(
        lastOffsetFromEnd: Int,
        currencySymbol: String,
        checkLanguageAlignment: Bool = true) {
        self.adjustSelectedTextRange(
            lastOffsetFromEnd: lastOffsetFromEnd,
            currencySymbol,
            checkLanguageAlignment)
    }

    // MARK: Private

    /// Adjust the selected text range to match the best position.
    private func adjustSelectedTextRange(
        lastOffsetFromEnd: Int,
        _ currencySymbol: String,
        _ checkLanguageAlignment: Bool = true) {
        
        /// If text is empty the offset is set to zero, the selected text range does need to be changed.
        guard var text = self.text?.replacingOccurrences(of: currencySymbol, with: ""), !text.isEmpty
        else {
            return
        }
        
        var offsetFromEnd = lastOffsetFromEnd
        let isRightAlignedLanguage = checkLanguageAlignment && text.contains("\u{200f}")
        
        /// Find the last number or decimal separator offset from end.
        if let lastRelevantOffset = isRightAlignedLanguage ?
            text.lastRelevantCharacterOffsetFromStart :
            text.lastRelevantCharacterOffsetFromEnd {
            if lastRelevantOffset < offsetFromEnd {
                offsetFromEnd = lastRelevantOffset
            }
        }
        
        self.updateSelectedTextRange(
            offsetFromEnd - (isRightAlignedLanguage ? 0 : currencySymbol.count),
            checkLanguageAlignment)
    }
    
    /// Update the selected text range with given offset from end.
    private func updateSelectedTextRange(_ offsetFromEnd: Int, _ checkLanguageAlignment: Bool) {
        let isRightAlignedLanguage = checkLanguageAlignment && (self.text?.contains("\u{200f}") ?? false)
        if let updatedCursorPosition = self.position(
            from: isRightAlignedLanguage ? self.beginningOfDocument : self.endOfDocument,
            offset: offsetFromEnd) {
            selectedTextRange = self.textRange(from: updatedCursorPosition, to: updatedCursorPosition)
        }
    }
}

#endif
