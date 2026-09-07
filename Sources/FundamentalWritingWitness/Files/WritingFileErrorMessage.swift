import Foundation
import FundamentalDocument
import FundamentalStorage

struct WritingFileErrorMessage
{
    let title: String
    let detail: String
    let recoveryLocations: [URL]

    init(_ error: Error)
    {
        recoveryLocations = Self.locations(in: error)
        switch error
        {
        case DocumentFileFailure.conflictingRevision:
            title = "This file changed outside Fundamental."
            detail = "Use Save As to keep your current writing in another file."
        case DocumentFileFailure.destinationExists:
            title = "A file already uses that name."
            detail = "Choose a different name for this document."
        case DocumentFileFailure.unconfirmedWrite:
            title = "The save could not be confirmed."
            detail = "Your writing is still open. Recovery files are available."
        case DocumentFileFailure.differentDocument:
            title = "The file now belongs to a different document."
            detail = "Use Save As to keep your current writing."
        case WritingFileFailure.unsupportedDocument:
            title = "This document cannot be edited here yet."
            detail = "It needs writing features that are not yet available."
        case DocumentRecordFailure.unsupportedVersion:
            title = "This document uses a newer file format."
            detail = "Open it with a version of Fundamental that supports it."
        default:
            title = "Fundamental could not complete the file operation."
            detail = (error as NSError).localizedDescription
        }
    }

    private static func locations(in error: Error) -> [URL]
    {
        if case let DocumentFileFailure.unconfirmedWrite(recovery) = error
        {
            return recovery.locations
        }
        return []
    }
}
