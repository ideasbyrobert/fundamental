import Foundation

struct WritingUIRecoveryRecord: Decodable
{
    let identifier: UUID
    let sequence: UInt64
    let name: String
    let document: Data
    let requiresRecovery: Bool?
    let anchor: Point
    let focus: Point

    struct Point: Decodable
    {
        let block: UUID
        let offset: Int
    }

    func content() throws -> WritingUIRecord
    {
        try JSONDecoder().decode(WritingUIRecord.self, from: document)
    }
}
