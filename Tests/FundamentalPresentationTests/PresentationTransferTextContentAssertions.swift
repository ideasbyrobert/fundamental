import Testing

@testable import FundamentalPresentation
@testable import FundamentalRaster

extension PresentationTransferTests
{
    func expectTextContent(
        _ source: RasterInteractionText,
        role: RasterInteractionRole,
        equals result: PresentedResidentContent
    )
    {
        switch (role, result)
        {
        case let (.body, .body(line)),
             let (.title, .title(line)),
             let (.code, .code(line)),
             let (.caption, .caption(line)):
            expectText(source, equals: line)
        case let (.section(level), .section(resultLevel, line)):
            #expect(level.rawValue == resultLevel.rawValue)
            expectText(source, equals: line)
        case let (
            .headerCell(row, cell),
            .headerCell(resultRow, resultCell, .line(line))
        ),
             let (
                 .bodyCell(row, cell),
                 .bodyCell(resultRow, resultCell, .line(line))
             ):
            #expect(row == resultRow)
            #expect(cell == resultCell)
            expectText(source, equals: line)
        default:
            Issue.record("Expected matching text role and content")
        }
    }

    func expectText(
        _ source: RasterInteractionText,
        equals result: PresentedTextLine
    )
    {
        #expect(source.text == result.text)
        #expect(rectangleSignature(source.lineBounds)
            == rectangleSignature(result.lineBounds))
        #expect(source.baseline.x == result.baseline.x)
        #expect(source.baseline.y == result.baseline.y)
        expectFont(source.defaultFont, equals: result.defaultFont)
        expectSlices(source.sourceSlices, equals: result.sourceSlices)
        #expect(source.caretSites.count == result.caretSites.count)
        for pair in zip(source.caretSites, result.caretSites)
        {
            #expect(pair.0.utf16Offset == pair.1.utf16Offset)
            #expect(pair.0.position.x == pair.1.position.x)
            #expect(pair.0.position.y == pair.1.position.y)
            #expect(pointSignature(pair.0.sourcePoint)
                == pointSignature(pair.1.sourcePoint))
        }
    }
}
