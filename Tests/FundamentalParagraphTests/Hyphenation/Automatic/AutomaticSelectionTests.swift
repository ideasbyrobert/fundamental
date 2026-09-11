@testable import FundamentalParagraph
@testable import FundamentalNativeParagraph
import Testing

@MainActor
@Suite
struct AutomaticSelectionTests
{
    @Test
    func selectionsRemainBoundToTheOriginalCollection() throws
    {
        let first = try AutomaticFixture.text("extraordinary")
        let copy = first
        let second = try AutomaticFixture.text("extraordinary")
        let selection = try first.selectAutomatic(1)
        let line = try AutomaticFixture.line(
            copy, range: 0..<5, end: .automatic(selection)
        )
        #expect(line.display.text == "extra‐")
        #expect(throws: AutomaticInkFailure.foreignSelection)
        {
            try AutomaticFixture.line(
                second, range: 0..<5, end: .automatic(selection)
            )
        }
        let a = try AutomaticFixture.text("extra\u{AD}ordinary")
        let b = try AutomaticFixture.text("extra\u{AD}ordinary")
        #expect(throws: ExplicitProjectionFailure.foreignSelection)
        {
            try AutomaticFixture.line(
                b, range: 0..<6, end: .explicit(a.explicit.select(0))
            )
        }
        try AutomaticEvidence.write(
            "parent-selection", collection: copy, lines: [line],
            extra: ["foreignAutomatic": 1, "foreignExplicit": 1]
        )
    }

    @Test
    func invalidIndicesEndsAndOwnersCannotAuthorizeInk() throws
    {
        let value = try AutomaticFixture.text("extraordinary")
        for index in [-1, 4, Int.max]
        {
            #expect(throws: AutomaticInkFailure.invalidIndex(index))
            {
                try value.selectAutomatic(index)
            }
            #expect(throws: AutomaticInkFailure.invalidIndex(index))
            {
                try value.ink(for: AutomaticSelection(
                    owner: value.identity, index: index
                ))
            }
        }
        let selection = try value.selectAutomatic(1)
        #expect(throws: AutomaticInkFailure.mismatchedEnd)
        {
            try AutomaticFixture.line(
                value, range: 0..<6, end: .automatic(selection)
            )
        }
        #expect(throws: AutomaticInkFailure.excludedOwner)
        {
            try AutomaticFixture.line(
                value, range: 5..<5, end: .automatic(selection)
            )
        }
        #expect(throws: ExplicitProjectionFailure.invalidRange(-1..<5))
        {
            try AutomaticFixture.line(
                value, range: -1..<5, end: .automatic(selection)
            )
        }
        let hard = try AutomaticFixture.text("hi\nextraordinary")
        #expect(throws: ExplicitProjectionFailure.hardEnding)
        {
            try AutomaticFixture.line(
                hard, range: 0..<5, end: .automatic(hard.selectAutomatic(0))
            )
        }
        try PatternEvidence.write("selection", group: "automatic-controls",
                                  record: ["indexRefusals": 6, "wrongEnd": 1,
                                           "excludedOwner": 1, "range": 1,
                                           "hardEnding": 1])
    }
}
