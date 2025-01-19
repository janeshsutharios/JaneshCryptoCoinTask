//
//  Constants.swift
//  CryptoCoin
//
//  Created by Janesh Suthar.
//

import Foundation

public enum FilterOption: String {
    case activeCoins = "Active Coins"
    case inactiveCoins = "Inactive Coins"
    case onlyCoins = "Only Coins"
    case onlyTokens = "Only Tokens"
    case newCoins = "New Coins"
}

// Constants for Layout Constraints
public struct LayoutConstants {
    // Spacing constants (for padding or margins)
    public static let defaultMargin: CGFloat = 16.0
    public static let smallMargin: CGFloat = 4.0
    public static let mediumMargin: CGFloat = 8.0
    public static let largeMargin: CGFloat = 24.0
    
    // Button
    public static let buttonHeight: CGFloat = 46.0
    
    //Icons
    public static let iconHeight: CGFloat = 40.0
    
    // Font sizes (if you want to define sizes for labels, buttons, etc.)
    public static let largeFontSize: CGFloat = 20.0
    public static let defaultFontSize: CGFloat = 16.0
    public static let mediumFontSize: CGFloat = 14.0
    public static let samllFontSize: CGFloat = 12.0
    
    // Corner radius for UI elements
    public static let defaultCornerRadius: CGFloat = 16.0
}

// Example of spacing for UI elements
public struct Spacing {
    public static let defaultVerticalSpacing: CGFloat = 16.0
    public static let smallVerticalSpacing: CGFloat = 10.0
    public static let mediumVerticalSpacing: CGFloat = 20.0
    
    public static let defaultHorizontalSpacing: CGFloat = 16.0
    public static let smallHorizontalSpacing: CGFloat = 10.0
    public static let mediumHorizontalSpacing: CGFloat = 20.0
}
