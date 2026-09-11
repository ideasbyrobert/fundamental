@testable import FundamentalParagraph
@testable import FundamentalNativeParagraph
import Testing

@MainActor
@Suite
struct AutomaticLiteralTests
{
    @Test(arguments: [18.0, 36.0])
    func everyCandidateShapesWithoutConsumingSource(_ size: Double) throws
    {
        for fixture in AutomaticLiteralCase.all
        {
            let source = try ExplicitFixture.source(
                fixture.text, language: fixture.language
            )
            let value = try AutomaticFixture.collection(
                source, language: fixture.nativeLanguage
            )
            #expect(value.inks.map(\.candidate.sourceOffset) == fixture.offsets)
            let units = Array(fixture.text.utf16)
            let whole = try AutomaticFixture.line(
                value, range: units.indices, size: size
            )
            try AutomaticAssertions.compare(
                whole, text: fixture.text,
                reference: ShapingReference.line(
                    [(fixture.text, [])], size: size
                )
            )
            var lines = [whole]
            for (index, offset) in fixture.offsets.enumerated()
            {
                let line = try AutomaticFixture.line(
                    value, range: 0..<offset,
                    end: .automatic(value.selectAutomatic(index)), size: size
                )
                let prefix = String(decoding: units[..<offset], as: UTF16.self)
                try AutomaticAssertions.compare(
                    line, text: prefix + "‐",
                    reference: ShapingReference.line(
                        [(prefix + "‐", [])], size: size
                    )
                )
                let remainder = try value.explicit.project(offset..<units.count)
                let recovered = try ExplicitFixture.reconstructed(
                    line.display.body.slice
                )
                #expect(try recovered
                    + ExplicitFixture.reconstructed(remainder) == units)
                #expect(value.inks[index].sourceRange == offset..<offset)
                lines.append(line)
            }
            try AutomaticEvidence.write(
                fixture.name + "-" + String(Int(size)),
                collection: value, lines: lines
            )
        }
    }
}
