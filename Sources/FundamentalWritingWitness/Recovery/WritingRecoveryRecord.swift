import Foundation
import FundamentalDocument

struct WritingRecoveryRecord: Sendable
{
    let identifier: UUID
    let sequence: UInt64
    let name: String
    let source: URL?
    let requiresRecovery: Bool
    let snapshot: EditableDocumentSnapshot

    var revision: UInt64 { snapshot.snapshot.document.revision.value }

    init?(
        identifier: UUID, sequence: UInt64, name: String, source: URL?,
        snapshot: EditableDocumentSnapshot, requiresRecovery: Bool = true
    )
    {
        guard name.utf16.count <= 1_024,
              source == nil || source?.isFileURL == true,
              WritingProjection(.editable(snapshot)) != nil
        else
        {
            return nil
        }
        self.identifier = identifier
        self.sequence = sequence
        self.name = name
        self.source = source
        self.requiresRecovery = requiresRecovery
        self.snapshot = snapshot
    }
}
