import Foundation

struct FundamentalBlockID: Equatable, Hashable, Sendable
{
    let value: UUID

    init(_ value: UUID)
    {
        self.value = value
    }
}
