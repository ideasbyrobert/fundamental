import Foundation
import Testing

@testable import FundamentalDocument

extension LegacySemanticTableRecordCodecTests
{
    static func normalizationData() -> Data
    {
        Data(
            #"""
            {
                "rows": [
                    {
                        "cells": [{
                            "runs": [{"text": "A", "traits": []}],
                            "isHeader": true, "rowSpan": 0,
                            "columnSpan": -1,
                            "alignment": "leading",
                            "sourceLocation": " ",
                            "confidence": 1
                        }],
                        "sourceLocation": " "
                    },
                    {
                        "cells": [{
                            "runs": [{"text": "B", "traits": []}],
                            "isHeader": true, "rowSpan": 1,
                            "columnSpan": 1,
                            "alignment": "center",
                            "sourceLocation": "cell:1",
                            "confidence": 0.5
                        }],
                        "sourceLocation": "row:1"
                    }
                ],
                "headerRowCount": -1,
                "columnAlignments": ["leading", "center"],
                "sourceLocation": " ",
                "confidence": 0.75
            }
            """#.utf8
        )
    }
    @Test("legacy normalization publishes every exact repair")
    func legacyNormalizationPublishesEveryExactRepair() throws
    {
        let sourced = try Self.sourced(Self.normalizationData())
        let row0 = try SemanticTableEvidenceTests.row(0)
        let row1 = try SemanticTableEvidenceTests.row(1)
        let cell = try SemanticTableEvidenceTests.cell(0)
        let repairs = sourced.evidence.facts.compactMap
        { fact -> SemanticTableRepair? in
            guard case let .repair(repair) = fact
            else
            {
                return nil
            }
            return repair
        }
        #expect(repairs.map(\.kind) == [
            .headerRowCountClamped,
            .blankSourceLocationDiscarded,
            .blankSourceLocationDiscarded,
            .nonpositiveRowSpanNormalizedToOne,
            .nonpositiveColumnSpanNormalizedToOne,
            .contradictoryCellHeaderFlagDiscarded,
            .blankSourceLocationDiscarded,
            .contradictoryCellHeaderFlagDiscarded
        ])
        #expect(repairs.map(\.target) == [
            .table,
            .table,
            .row(row0),
            .cell(row: row0, cell: cell),
            .cell(row: row0, cell: cell),
            .cell(row: row0, cell: cell),
            .cell(row: row0, cell: cell),
            .cell(row: row1, cell: cell)
        ])
    }
    @Test("legacy evidence targets use normalized positions")
    func legacyEvidenceTargetsUseNormalizedPositions() throws
    {
        let sourced = try Self.sourced(Self.normalizationData())
        let row = try SemanticTableEvidenceTests.row(1)
        let cell = try SemanticTableEvidenceTests.cell(0)
        let rowLocation = try SemanticTableEvidenceTests.location(
            target: .row(row), value: "row:1")
        let cellLocation = try SemanticTableEvidenceTests.location(
            target: .cell(row: row, cell: cell), value: "cell:1")
        #expect(sourced.table.content.bodyRows
            .flatMap(\.cells).map(\.plainText) == ["A", "B"])
        #expect(sourced.evidence.facts.contains(rowLocation))
        #expect(sourced.evidence.facts.contains(cellLocation))
    }
}
