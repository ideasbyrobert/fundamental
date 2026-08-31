import Foundation

struct FundamentalDocumentID: Equatable, Hashable, Sendable
{
    let value: UUID

    init(_ value: UUID)
    {
        self.value = value
    }
}
