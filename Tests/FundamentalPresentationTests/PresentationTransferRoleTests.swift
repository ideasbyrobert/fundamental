import Testing

@testable import FundamentalDocument
@testable import FundamentalPresentation

extension PresentationTransferTests
{
    @MainActor
    @Test("body title six section levels and code retain closed roles")
    func textRoles() throws
    {
        var blocks: [SemanticBlock] = [
            .paragraph(SemanticParagraph(runs: [
                PresentationFixture.run("Body")
            ])),
            .heading(.title(TitleSemanticHeading(runs: [
                PresentationFixture.run("Title")
            ])))
        ]
        blocks.append(contentsOf: SemanticHeadingLevel.allCases.map
        {
            .heading(.section(SectionSemanticHeading(
                runs: [PresentationFixture.run("Section \($0.rawValue)")],
                level: $0
            )))
        })
        blocks.append(.code(.plain(PlainSemanticCodeBlock(runs: [
            PresentationFixture.run("let answer = 42")
        ]))))
        let contents = try PresentationFixture.snapshot(
            PresentationFixture.raster(
                PresentationFixture.viewport(
                    PresentationFixture.layout(blocks, width: 500)
                )
            )
        ).presentedDocument.residents.all.map(\.content)
        #expect(contents.count == 9)
        guard case .body = contents[0],
              case .title = contents[1],
              case .code = contents[8]
        else
        {
            Issue.record("Expected body title and code roles")
            return
        }
        let levels: [Int] = contents[2 ... 7].compactMap
        {
            guard case let .section(level, _) = $0
            else
            {
                return nil
            }
            return level.rawValue
        }
        #expect(levels == [1, 2, 3, 4, 5, 6])
    }
}
