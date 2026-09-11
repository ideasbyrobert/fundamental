@testable import FundamentalParagraph
import Testing

enum ExplicitFixture
{
    static func source(_ text: String, language: String = "en_US") throws
        -> ParagraphWordSource
    {
        try WordFixture.source([WordFixture.run(text)], language: language)
    }

    static func indices(_ value: ExplicitParagraphHyphens) -> [Int]
    {
        value.records.indices.filter
        {
            if case .opportunity = value.records[$0].outcome
            {
                return true
            }
            return false
        }
    }

    static func reconstructed(_ slice: ExplicitDisplaySlice) throws -> [UInt16]
    {
        let positions = slice.atoms.flatMap
        {
            Array($0.fragment.paragraphRange)
        }
        #expect(positions == Array(slice.range))
        var result: [UInt16] = []
        for atom in slice.atoms
        {
            let fragment = atom.fragment
            let run = slice.source.paragraph.runs[fragment.runIndex]
            let units = Array(run.text.utf16)
            try #require(fragment.runRange.lowerBound >= 0)
            try #require(fragment.runRange.upperBound <= units.count)
            let part = Array(units[fragment.runRange])
            #expect(part == Array(
                slice.source.source.utf16[fragment.paragraphRange]
            ))
            if atom.kind != .source
            {
                #expect(part == [173])
            }
            result += part
        }
        #expect(result == Array(slice.source.source.utf16[slice.range]))
        return result
    }

    static func allSlices(_ value: ExplicitParagraphHyphens) throws
        -> [ExplicitDisplaySlice]
    {
        let count = value.source.source.utf16.count
        var slices = [try value.project(0..<count)]
        for index in indices(value)
        {
            let offset = try value.opportunity(at: index).sourceOffset
            slices.append(try value.project(
                0..<offset, end: .opportunity(value.select(index))
            ))
            slices.append(try value.project(offset..<count))
        }
        return slices
    }
}
