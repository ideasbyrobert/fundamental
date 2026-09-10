import AppKit
import Testing

@testable import FundamentalDocument
@testable import FundamentalMacOracle
@testable import FundamentalPresentation

@MainActor
enum MacReaderDocumentFixture
{
    static func model(
        _ source: DocumentSnapshot,
        width: Double = 820, height: Double = 680
    ) throws -> MacReaderModel
    {
        let screen = try MacOracleTestSurface.screen()
        let appearance = try MacOracleTestSurface.appearance()
        return try #require(MacReaderModel(
            viewportWidth: width,
            viewportHeight: height,
            screen: screen,
            appearance: appearance,
            projection: MacReaderDocumentProjection(source)
        ))
    }

    static func texts(_ model: MacReaderModel) -> [String]
    {
        model.snapshot.presentedDocument.residents.all.compactMap
        {
            line($0.content)?.text
        }
    }

    static func line(_ content: PresentedResidentContent) -> PresentedTextLine?
    {
        switch content
        {
        case let .body(line), let .title(line), let .section(_, line),
             let .code(line), let .caption(line),
             let .headerCell(_, _, .line(line)),
             let .bodyCell(_, _, .line(line)):
            line
        case .table, .tableColumn, .headerRow, .bodyRow,
             .headerCell(_, _, .area), .bodyCell(_, _, .area):
            nil
        }
    }
}
