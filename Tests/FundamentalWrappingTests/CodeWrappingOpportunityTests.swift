import Foundation
import Testing

@testable import FundamentalWrapping

@Suite("Language-neutral code wrapping opportunities")
struct CodeWrappingOpportunityTests
{
    @Test("operators and whitespace remain complete preferred tokens")
    func preferred() throws
    {
        let text = "call(value: alpha   <= beta, next)"
        let source = WrappingSource(text)
        let result = CodeWrappingOpportunities(source)
        let prefixes = result.priorities.filter { $0.value == .preferred }
            .keys.sorted().compactMap { source.substring(in: 0 ..< $0) }
        #expect(prefixes == [
            "call(", "call(value:", "call(value: ",
            "call(value: alpha   ", "call(value: alpha   <=",
            "call(value: alpha   <= ", "call(value: alpha   <= beta,",
            "call(value: alpha   <= beta, ", text
        ])
    }

    @Test("escaped quotes and paths keep internal breaks subordinate")
    func quoted() throws
    {
        let text = #"let path = "/alpha/a\"b/file.swift" + name"#
        let source = WrappingSource(text)
        let result = CodeWrappingOpportunities(source)
        let quoted = try #require(text.range(of: #""/alpha/a\"b/file.swift""#))
        let lower = text[..<quoted.lowerBound].utf16.count
        let upper = text[..<quoted.upperBound].utf16.count
        let interior = result.priorities.filter
        {
            $0.key > lower && $0.key < upper
        }
        #expect(!interior.isEmpty)
        #expect(interior.values.allSatisfy { $0 == .secondary })
        #expect(result.priorities.keys.allSatisfy(source.isBoundary))
    }

    @Test("hard endings reset incomplete quotes without splitting graphemes")
    func boundaries() throws
    {
        let source = WrappingSource("\"👩🏽‍💻\r\nalpha beta e\u{301}")
        let result = CodeWrappingOpportunities(source)
        let first = source.lines[1].range.lowerBound
        #expect(result.priorities[first + 6] == .preferred)
        #expect(result.priorities.keys.allSatisfy(source.isBoundary))
        for offset in 0 ... source.utf16.count
        {
            let index = source.boundaryIndex(atOrBefore: offset)
            #expect(source.graphemeBoundaries[index] <= offset)
            if index + 1 < source.graphemeBoundaries.count
            {
                #expect(source.graphemeBoundaries[index + 1] > offset)
            }
        }
    }
}
