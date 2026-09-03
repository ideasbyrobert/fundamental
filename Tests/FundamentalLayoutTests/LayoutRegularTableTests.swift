import Testing

@testable import FundamentalDocument
@testable import FundamentalLayout

extension LayoutTableTests
{
    @MainActor
    @Test("regular tables carry no caption lines")
    func regularTable() throws
    {
        let block = SemanticBlock.table(
            try LayoutFixture.table(captioned: false)
        )
        let snapshot = try NativeTextKit2Layout().layout(
            LayoutFixture.projection([block]),
            request: LayoutFixture.request(width: 360)
        )
        #expect(snapshot.grids.first?.captionLines == [])
        #expect(snapshot.fragments.allSatisfy
        {
            guard case let .grid(fragment) = $0
            else
            {
                return false
            }
            guard case .captionLine = fragment.content
            else
            {
                return true
            }
            return false
        })
    }
}
