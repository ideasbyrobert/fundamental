import Foundation

enum WritingTextFailure: Error, LocalizedError, Equatable
{
    case invalidUTF8
    case excessiveText
    case unsupportedDocument
    case invalidLocation
    case unconfirmedExport

    var errorDescription: String?
    {
        switch self
        {
        case .invalidUTF8:
            "This file is not valid UTF-8 text. No document was imported."
        case .excessiveText:
            "This text exceeds the editor's current document capacity."
        case .unsupportedDocument:
            "This document contains content that cannot be exported as text."
        case .invalidLocation:
            "Choose a regular local text file."
        case .unconfirmedExport:
            "The exported text could not be verified. Your writing stays open."
        }
    }
}
