import Foundation
import FundamentalDocument

struct DocumentFileWriter
{
    let document: CanonicalDocument
    let location: DocumentFileLocation
    let condition: DocumentFileWriteCondition
    let codec: DocumentRecordCodec

    func write() throws -> DocumentFileSaveReceipt
    {
        let bytes = try codec.encode(document)
        let candidate = try DocumentFileCandidate(
            bytes: bytes, destination: location
        )
        let previous = try requirePriorState()
        return try publish(candidate, previous: previous, bytes: bytes)
    }
}
