import Foundation
import Testing

@testable import FundamentalDocument

@Suite("Legacy semantic table record decoding")
struct LegacySemanticTableRecordCodecTests
{
    static func regularData() -> Data
    {
        Data(
            #"""
            {
                "rows": [],
                "headerRowCount": 0,
                "columnAlignments": [],
                "confidence": 1,
                "unknown": true
            }
            """#.utf8
        )
    }
    static func captionedData() -> Data
    {
        Data(
            #"""
            {
                "rows": [{
                    "cells": [{
                        "runs": [{"text": "Head", "traits": []}],
                        "isHeader": true,
                        "rowSpan": 1,
                        "columnSpan": 1,
                        "alignment": "leading",
                        "confidence": 1
                    }],
                    "sourceLocation": "row:0"
                }],
                "headerRowCount": 1,
                "columnAlignments": ["leading"],
                "caption": [{"text": "Caption", "traits": []}],
                "sourceLocation": "table:1",
                "confidence": 0.75
            }
            """#.utf8
        )
    }
    static func sourced(
        _ data: Data
    ) throws -> SourcedSemanticTable
    {
        let record = try SemanticTableRecordCodec.decode(data)
        let sourced: SourcedSemanticTable?
        switch record
        {
        case .semantic:
            sourced = nil
        case let .sourced(table):
            sourced = table
        }
        return try #require(sourced)
    }
    @Test("legacy regular table decodes without mutating input")
    func legacyRegularTableDecodesWithoutMutatingInput() throws
    {
        let data = Self.regularData()
        let original = data
        let sourced = try Self.sourced(data)

        #expect(data == original)
        guard case let .regular(table) = sourced.table
        else
        {
            Issue.record("Expected a regular table")
            return
        }
        #expect(table.content.headerRows.isEmpty)
        #expect(table.content.bodyRows.isEmpty)
        #expect(sourced.evidence.facts.count == 1)
    }

    @Test("legacy captioned table preserves nested facts")
    func legacyCaptionedTablePreservesNestedFacts() throws
    {
        let sourced = try Self.sourced(Self.captionedData())
        guard case let .captioned(table) = sourced.table
        else
        {
            Issue.record("Expected a captioned table")
            return
        }

        #expect(table.caption.runs == [SemanticRun(text: "Caption")])
        #expect(table.content.headerRows
            .flatMap(\.cells).map(\.plainText) == ["Head"])
        #expect(table.content.columnAlignments == [.leading])
        #expect(sourced.evidence.facts.count == 4)
    }
}
