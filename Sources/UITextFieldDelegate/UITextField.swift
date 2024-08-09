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
            previousOffset: 0,
            currencySymbol,
            checkLanguageAlignment)
    }
    
    /// Interface to update the selected text range as expected.
    func updateSelectedTextRange(
        previousOffset: Int,
        currencySymbol: String,
        checkLanguageAlignment: Bool = true) {
        self.adjustSelectedTextRange(
            previousOffset: previousOffset,
            currencySymbol,
            checkLanguageAlignment)
    }

    // MARK: Private

    /// Adjust the selected text range to match the best position.
    private func adjustSelectedTextRange(
        previousOffset: Int,
        _ currencySymbol: String,
        _ checkLanguageAlignment: Bool = true) {
        
        /// If the text is empty the offset is set to zero, the selected text range does need to be changed.
        guard let text = self.text?.replacingOccurrences(of: currencySymbol, with: ""), !text.isEmpty
        else {
            return
        }
        
        var offset = previousOffset
        let isRightAlignedLanguage = checkLanguageAlignment && text.contains("\u{200f}")
        
        /// Find the last number or decimal separator offset from start / end.
        if let lastRelevantOffset = isRightAlignedLanguage ?
            text.lastRelevantCharacterOffsetFromStart :
            text.lastRelevantCharacterOffsetFromEnd {
            if lastRelevantOffset < offset {
                offset = lastRelevantOffset
            }
        }
        
        /// Update the offset to include the currency symbol (if necessary).
        switch isRightAlignedLanguage {
        case true:
            if self.text?.hasPrefix(currencySymbol) ?? false {
                offset += currencySymbol.count
            }
            
        case false:
            if self.text?.hasSuffix(currencySymbol) ?? false {
                offset -= currencySymbol.count
            }
        }
        
        self.updateSelectedTextRange(offset, checkLanguageAlignment)
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
