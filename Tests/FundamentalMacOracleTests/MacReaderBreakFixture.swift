import AppKit
import Testing

@testable import FundamentalDocument
@testable import FundamentalMacOracle
@testable import FundamentalPresentation

@MainActor
enum MacReaderBreakFixture
{
    static func copy(
        _ block: SemanticBlock
    ) throws -> PresentationSelectionAdornment
    {
        let source = try MacReaderDocumentFixture.source([block])
        let controller = try MacReaderDocumentFixture.window(
            source, width: 360, height: 360
        )
        let window = try #require(controller.window)
        defer { window.close() }
        controller.showWindow(nil)
        controller.synchronize()
        return try MacReaderDocumentFixture.copy(
            blockID: source.document.content.blocks[0].blockID.value,
            from: controller
        )
    }
}
