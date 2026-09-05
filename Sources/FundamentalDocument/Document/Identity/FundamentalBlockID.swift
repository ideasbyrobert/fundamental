import Foundation

package struct FundamentalBlockID: Equatable, Hashable, Sendable
{
    package let value: UUID

    package init(_ value: UUID)
    {
        self.value = value
    }
}
