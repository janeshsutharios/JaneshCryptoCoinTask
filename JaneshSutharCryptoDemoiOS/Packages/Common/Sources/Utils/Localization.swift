//
//  Localization.swift
//  CryptoCoin
//
//  Created by Janesh Suthar.
//
import Foundation

public struct Localization {
    /// Retrieves a localized string for a given key with an optional default value.
    /// - Parameters:
    ///   - key: The key for the string in the `Localizable.strings` file.
    ///   - defaultValue: The default value to return if the key is not found in the localization file.
    ///   - args: Optional arguments to format the string.
    /// - Returns: A localized and formatted string or the default value if the key is missing.
    public static func localizedString(for key: String, defaultValue: String, args: any CVarArg...) -> String {
        let localized = NSLocalizedString(key, comment: "")
        let result = localized != key ? localized : defaultValue
        return String(format: result, arguments: args)
    }
}

