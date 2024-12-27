//
//  String.swift
//  CurrencyText
//
//  Created by Felipe Lefèvre Marino on 4/3/18.
//  Copyright © 2018 Felipe Lefèvre Marino. All rights reserved.
//

import Foundation

public protocol CurrencyString {
    var representsZero: Bool { get }
    var hasNumbers: Bool { get }
    var lastRelevantCharacterOffsetFromEnd: Int? { get }
    var lastRelevantCharacterOffsetFromStart: Int? { get }
    func numeralFormat() -> String
    mutating func updateDecimalSeparator(decimalDigits: Int)
}

//Currency String Extension
extension String: CurrencyString {

    // MARK: Properties
    
    /// Informs with the string represents the value of zero
    public var representsZero: Bool {
        return numeralFormat().replacingOccurrences(of: "0", with: "").count == 0
    }
    
    /// Returns if the string does have any character that represents numbers
    public var hasNumbers: Bool {
        return numeralFormat().count > 0
    }
    
    /// Find the offset from the end of the last relevant character (number or decimal separator)
    public var lastRelevantCharacterOffsetFromEnd: Int? {
        let relevantCharacters = CharacterSet.decimalDigits.union(
            CharacterSet(charactersIn: Locale.autoupdatingCurrent.decimalSeparator ?? "."))
        for (index, character) in self.reversed().enumerated() {
            if String(character).rangeOfCharacter(from: relevantCharacters) != nil {
                return self.distance(from: self.endIndex, to: self.index(self.endIndex, offsetBy: -index))
            }
        }
        return nil
    }
    
    /// Find the offset from the start of the last relevant character (number or decimal separator)
    public var lastRelevantCharacterOffsetFromStart: Int? {
        let relevantCharacters = CharacterSet.decimalDigits.union(
            CharacterSet(charactersIn: Locale.autoupdatingCurrent.decimalSeparator ?? "."))
        for (index, character) in self.enumerated() {
            if String(character).rangeOfCharacter(from: relevantCharacters) != nil {
                return self.distance(from: self.startIndex, to: self.index(self.startIndex, offsetBy: index))
            }
        }
        return nil
    }
    
    // MARK: Functions
    
    /// Updates a currency string decimal separator position based on
    /// the amount of decimal digits desired
    ///
    /// - Parameter decimalDigits: The amount of decimal digits of the currency formatted string
    public mutating func updateDecimalSeparator(decimalDigits: Int) {
        guard decimalDigits != 0 && count >= decimalDigits else { return }
        let decimalsRange = index(endIndex, offsetBy: -decimalDigits)..<endIndex
        
        let decimalChars = self[decimalsRange]
        replaceSubrange(decimalsRange, with: "." + decimalChars)
    }
    
    /// The numeral format of a string - remove all non numerical occurrences
    ///
    /// - Returns: itself without the non numerical characters occurrences
    public func numeralFormat() -> String {
        let formatter = NumberFormatter()
        formatter.locale = Locale.autoupdatingCurrent
        
        var result = self
        for number in 0...9 {
            if let localizedDigit = formatter.string(from: NSNumber(value: number)) {
                result = result.replacingOccurrences(of: localizedDigit, with: "\(number)")
            }
        }
        
        return result.replacingOccurrences(of: "[^0-9]", with: "", options: .regularExpression)
    }
}

// MARK: - Static constants

extension String {
    public var isNegative: Bool {
        // Check if the value is negative using the minus hyphen (U+002D) and sign (U+2212).
        return self.contains(String.negativeSymbol) ||
            self.contains(String.minusSymbol)
    }
    
    public static let negativeSymbol = "-"
    public static let minusSymbol = "−"
}
