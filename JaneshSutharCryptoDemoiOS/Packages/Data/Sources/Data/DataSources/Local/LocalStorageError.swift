//
//  LocalStorageError.swift
//  CryptoCoin
//
//  Created by Janesh Suthar
//

import Foundation

public enum LocalStorageError: Error {
    case objectNotFound
    case failedToSave
    case invalidData

    public var localizedDescription: String {
        switch self {
        case .objectNotFound:
            return "The requested object was not found in the local storage."
        case .failedToSave:
            return "Failed to save the data to local storage."
        case .invalidData:
            return "The data provided is invalid for storage."
        }
    }
}
