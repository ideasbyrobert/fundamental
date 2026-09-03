import Foundation

package struct FundamentalDocumentID: Equatable, Hashable, Sendable
{
    package let value: UUID

    init(_ value: UUID)
    {
        self.value = value
    }
}
