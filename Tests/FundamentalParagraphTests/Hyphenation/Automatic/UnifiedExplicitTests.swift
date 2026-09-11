@testable import FundamentalParagraph
@testable import FundamentalNativeParagraph
import Testing

@MainActor
@Suite
struct UnifiedExplicitTests
{
    @Test(arguments: [18.0, 36.0])
    func priorExplicitFixturesKeepExactShapingAndSources(_ size: Double) throws
    {
        for fixture in ExplicitCases.all
        {
            let value = try AutomaticFixture.collection(
                ExplicitFixture.source(
                    fixture.text, language: fixture.language
                ),
                language: fixture.language == "ru_RU" ? .russian : .english
            )
            let end = value.source.source.utf16.count
            let whole = try AutomaticFixture.line(
                value, range: 0..<end, size: size
            )
            try AutomaticAssertions.explicitParity(
                whole, ShapingFixture.line(
                    value.explicit, range: 0..<end, size: size
                )
            )
            var lines = [whole]
            for index in ExplicitFixture.indices(value.explicit)
            {
                let mark = try value.explicit.select(index)
                let offset = try value.explicit.opportunity(at: index)
                    .sourceOffset
                let selected = try AutomaticFixture.line(
                    value, range: 0..<offset, end: .explicit(mark), size: size
                )
                let remainder = try AutomaticFixture.line(
                    value, range: offset..<end, size: size
                )
                try AutomaticAssertions.explicitParity(
                    selected, ShapingFixture.line(
                        value.explicit, range: 0..<offset,
                        end: .opportunity(mark), size: size
                    )
                )
                try AutomaticAssertions.explicitParity(
                    remainder, ShapingFixture.line(
                        value.explicit, range: offset..<end, size: size
                    )
                )
                lines += [selected, remainder]
            }
            try AutomaticEvidence.write(
                "explicit-" + fixture.name + "-" + String(Int(size)),
                collection: value, lines: lines
            )
        }
    }
}
