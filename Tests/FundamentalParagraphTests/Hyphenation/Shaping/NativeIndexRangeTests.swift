@testable import FundamentalParagraph
@testable import FundamentalNativeParagraph
import Testing

@Suite
struct NativeIndexRangeTests
{
    @Test
    func logicalIntervalsPreserveRepeatedAndReorderedGlyphIndices() throws
    {
        let inputs = [[0, 2, 2, 3], [3, 2, 0], [2, 0, 3, 2]]
        var records: [[[Int]]] = []
        for input in inputs
        {
            let mapped = try NativeIndexRanges(
                range: 0..<4, indices: input, displayLength: 4
            )
            let expected = input.map
            {
                switch $0
                {
                case 0: 0..<2
                case 2: 2..<3
                default: 3..<4
                }
            }
            #expect(mapped.ranges == expected)
            records.append(mapped.ranges.map { [$0.lowerBound, $0.upperBound] })
        }
        #expect(try NativeIndexRanges(
            range: 0..<0, indices: [], displayLength: 0
        ).ranges.isEmpty)
        try PatternEvidence.write("native-valid", group: "shaping-controls",
                                  record: ["inputs": inputs, "ranges": records])
    }

    @Test
    func unavailableOrIncompleteNativeIndicesAreRefused() throws
    {
        for indices in [[-1], [0, 4], [0, Int.max]]
        {
            #expect(throws: ExplicitShapingFailure.nativeIndex)
            {
                try NativeIndexRanges(
                    range: 0..<4, indices: indices, displayLength: 4
                )
            }
        }
        for indices in [[], [1, 2, 3]]
        {
            #expect(throws: ExplicitShapingFailure.missingNativeIndices)
            {
                try NativeIndexRanges(
                    range: 0..<4, indices: indices, displayLength: 4
                )
            }
        }
        for range in [-1..<4, 0..<5]
        {
            #expect(throws: ExplicitShapingFailure.nativeRange)
            {
                try NativeIndexRanges(
                    range: range, indices: [0], displayLength: 4
                )
            }
        }
        try PatternEvidence.write("native-invalid", group: "shaping-controls",
                                  record: ["invalidIndex": 3,
                                           "missingIndices": 2,
                                           "invalidRange": 2])
    }
}
