import Foundation

package struct FundamentalBlockID: Equatable, Hashable, Sendable
{
    package let value: UUID

    init(_ value: UUID)
    {
        self.value = value
    }
}
