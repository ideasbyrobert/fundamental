import Foundation
import FundamentalDocument

struct WritingRecoveryEnvelope: Codable
{
    let format: String
    let version: Int
    let identifier: UUID
    let sequence: UInt64
    let name: String
    let source: URL?
    let document: Data
    let anchor: WritingRecoveryPoint
    let focus: WritingRecoveryPoint

    init(_ record: WritingRecoveryRecord) throws
    {
        format = "fundamental-writing-recovery"
        version = 1
        identifier = record.identifier
        sequence = record.sequence
        name = record.name
        source = record.source
        document = try WritingRecoveryCodec.documentCodec.encode(
            record.snapshot.snapshot.document
        )
        anchor = WritingRecoveryPoint(record.snapshot.selection.range.start)
        focus = WritingRecoveryPoint(record.snapshot.selection.range.end)
    }

    func record() throws -> WritingRecoveryRecord
    {
        guard format == "fundamental-writing-recovery", version == 1
        else
        {
            throw WritingRecoveryFailure.invalidRecord
        }
        let document = try WritingRecoveryCodec.documentCodec.decode(document)
        guard let start = anchor.point(in: document),
              let end = focus.point(in: document),
              let range = DocumentRange(start: start, end: end),
              let snapshot = EditableDocumentSnapshot(
                  snapshot: DocumentSnapshot(generation: .zero,
                                             document: document),
                  selection: DocumentSelection(range: range)
              ), let record = WritingRecoveryRecord(
                  identifier: identifier, sequence: sequence, name: name,
                  source: source, snapshot: snapshot
              )
        else
        {
            throw WritingRecoveryFailure.invalidRecord
        }
        return record
    }
}
