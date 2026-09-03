import Foundation
import FundamentalDocument

package extension ProjectionSnapshot
{
    init(_ snapshot: DocumentSnapshot)
    {
        let document = snapshot.document
        let blocks = document.content.blocks.enumerated().map
        {
            Self.project(
                $0.element,
                ordinal: $0.offset
            )
        }
        lineage = ProjectionLineage(
            documentID: document.documentID.value,
            revision: document.revision.value,
            generation: snapshot.generation.value
        )
        firstBlock = blocks[0]
        remainingBlocks = Array(blocks.dropFirst())
    }

    private static func project(
        _ identified: IdentifiedSemanticBlock,
        ordinal: Int
    ) -> ProjectedBlock
    {
        let blockID = identified.blockID.value
        let source = ProjectedBlockSource(
            blockID: blockID,
            ordinal: ordinal
        )
        switch identified.block
        {
        case let .paragraph(paragraph):
            return .prose(
                source: source,
                prose: ProjectedProse(
                    role: .body,
                    runs: projectBlockRuns(
                        paragraph.runs,
                        blockID: blockID
                    )
                )
            )
        case let .heading(heading):
            return project(
                heading,
                source: source
            )
        case let .code(code):
            return project(
                code,
                source: source
            )
        case let .table(table):
            return .table(
                source: source,
                table: project(
                    table,
                    blockID: blockID
                )
            )
        }
    }

    private static func project(
        _ heading: SemanticHeading,
        source: ProjectedBlockSource
    ) -> ProjectedBlock
    {
        let role: ProjectedProseRole
        switch heading
        {
        case .title:
            role = .title
        case let .section(section):
            role = .section(project(section.level))
        }
        return .prose(
            source: source,
            prose: ProjectedProse(
                role: role,
                runs: projectBlockRuns(
                    heading.runs,
                    blockID: source.blockID
                )
            )
        )
    }

    private static func project(
        _ code: SemanticCodeBlock,
        source: ProjectedBlockSource
    ) -> ProjectedBlock
    {
        let projected: ProjectedCode
        switch code
        {
        case let .plain(block):
            projected = .plain(
                projectBlockRuns(
                    block.runs,
                    blockID: source.blockID
                )
            )
        case let .languageTagged(block):
            projected = .languageTagged(
                language: block.language.value,
                runs: projectBlockRuns(
                    block.runs,
                    blockID: source.blockID
                )
            )
        }
        return .code(
            source: source,
            code: projected
        )
    }

    private static func project(
        _ record: SemanticTableRecord,
        blockID: UUID
    ) -> ProjectedTableRecord
    {
        switch record
        {
        case let .semantic(table):
            return .semantic(
                project(
                    table,
                    blockID: blockID
                )
            )
        case let .sourced(sourced):
            return .sourced(
                table: project(
                    sourced.table,
                    blockID: blockID
                ),
                evidence: project(sourced.evidence)
            )
        }
    }

    private static func project(
        _ table: SemanticTable,
        blockID: UUID
    ) -> ProjectedTable
    {
        switch table
        {
        case let .regular(table):
            return .regular(
                project(
                    table.content,
                    blockID: blockID
                )
            )
        case let .captioned(table):
            return .captioned(
                content: project(
                    table.content,
                    blockID: blockID
                ),
                caption: project(
                    table.caption,
                    blockID: blockID
                )
            )
        }
    }

    private static func project(
        _ content: SemanticTableContent,
        blockID: UUID
    ) -> ProjectedTableContent
    {
        let headerRows = content.headerRows.enumerated().map
        {
            project(
                $0.element.cells,
                row: $0.offset,
                blockID: blockID
            )
        }
        let headerCount = headerRows.count
        let bodyRows = content.bodyRows.enumerated().map
        {
            project(
                $0.element.cells,
                row: headerCount + $0.offset,
                blockID: blockID
            )
        }
        return ProjectedTableContent(
            headerRows: headerRows,
            bodyRows: bodyRows,
            columnAlignments: content.columnAlignments.map(project)
        )
    }

    private static func project(
        _ cells: [SemanticTableCell],
        row: Int,
        blockID: UUID
    ) -> ProjectedTableRow
    {
        ProjectedTableRow(
            index: row,
            cells: cells.enumerated().map
            {
                project(
                    $0.element,
                    row: row,
                    cell: $0.offset,
                    blockID: blockID
                )
            }
        )
    }

    private static func project(
        _ cell: SemanticTableCell,
        row: Int,
        cell cellIndex: Int,
        blockID: UUID
    ) -> ProjectedTableCell
    {
        switch cell
        {
        case let .regular(cell):
            return .regular(
                runs: projectCellRuns(
                    cell.runs,
                    blockID: blockID,
                    row: row,
                    cell: cellIndex
                ),
                alignment: project(cell.alignment)
            )
        case let .spanning(cell):
            return .spanning(
                runs: projectCellRuns(
                    cell.runs,
                    blockID: blockID,
                    row: row,
                    cell: cellIndex
                ),
                alignment: project(cell.alignment),
                extent: ProjectedTableCellExtent(cell.extent)
            )
        }
    }

    private static func project(
        _ caption: SemanticTableCaption,
        blockID: UUID
    ) -> ProjectedTableCaption
    {
        let runs = projectCaptionRuns(
            caption.runs,
            blockID: blockID
        )
        return ProjectedTableCaption(
            firstRun: runs[0],
            remainingRuns: Array(runs.dropFirst())
        )
    }

    private static func project(
        _ evidence: SemanticTableEvidence
    ) -> ProjectedTableEvidence
    {
        let facts = evidence.facts.map(project)
        return ProjectedTableEvidence(
            firstFact: facts[0],
            remainingFacts: Array(facts.dropFirst())
        )
    }

    private static func project(
        _ fact: SemanticTableEvidenceFact
    ) -> ProjectedTableEvidenceFact
    {
        switch fact
        {
        case let .sourceLocation(target, location):
            return .sourceLocation(
                target: project(target),
                location: location.value
            )
        case let .confidence(target, confidence):
            return .confidence(
                target: project(target),
                value: confidence.value
            )
        case let .repair(repair):
            return .repair(
                target: project(repair.target),
                kind: project(repair.kind)
            )
        }
    }

    private static func projectBlockRuns(
        _ runs: [SemanticRun],
        blockID: UUID
    ) -> [ProjectedRun]
    {
        projectRuns(runs)
        {
            .block(
                blockID: blockID,
                run: $0,
                range: range($1, $2)
            )
        }
    }

    private static func projectCaptionRuns(
        _ runs: [SemanticRun],
        blockID: UUID
    ) -> [ProjectedRun]
    {
        projectRuns(runs)
        {
            .caption(
                blockID: blockID,
                run: $0,
                range: range($1, $2)
            )
        }
    }

    private static func projectCellRuns(
        _ runs: [SemanticRun],
        blockID: UUID,
        row: Int,
        cell: Int
    ) -> [ProjectedRun]
    {
        projectRuns(runs)
        {
            .cell(
                blockID: blockID,
                row: row,
                cell: cell,
                run: $0,
                range: range($1, $2)
            )
        }
    }

    private static func projectRuns(
        _ runs: [SemanticRun],
        source: (Int, Int, Int) -> ProjectedTextSource
    ) -> [ProjectedRun]
    {
        var offset = 0
        return runs.enumerated().map
        {
            let lower = offset
            offset += $0.element.text.utf16.count
            let projectedSource = source($0.offset, lower, offset)
            let traits = Set($0.element.traits.map(project))
            switch $0.element
            {
            case let .direct(run):
                return .direct(
                    source: projectedSource,
                    text: run.text,
                    traits: traits
                )
            case let .scoped(run):
                return .scoped(
                    source: projectedSource,
                    text: run.text,
                    traits: traits,
                    scope: project(run.scopes)
                )
            }
        }
    }

    private static func range(
        _ lowerBound: Int,
        _ upperBound: Int
    ) -> ProjectedUTF16Range
    {
        ProjectedUTF16Range(lowerBound..<upperBound)
    }

    private static func project(
        _ trait: SemanticInlineTrait
    ) -> ProjectedInlineTrait
    {
        switch trait
        {
        case .strong:
            .strong
        case .emphasis:
            .emphasis
        case .underline:
            .underline
        case .strikethrough:
            .strikethrough
        case .inlineCode:
            .inlineCode
        case .superscript:
            .superscript
        case .subscriptText:
            .subscriptText
        }
    }

    private static func project(
        _ scopes: SemanticRunScopes
    ) -> ProjectedRunScope
    {
        switch scopes
        {
        case let .link(link):
            .link(link.value)
        case let .language(language):
            .language(language.value)
        case let .linkAndLanguage(link, language):
            .linkAndLanguage(
                link: link.value,
                language: language.value
            )
        }
    }

    private static func project(
        _ level: SemanticHeadingLevel
    ) -> ProjectedHeadingLevel
    {
        switch level
        {
        case .one:
            .one
        case .two:
            .two
        case .three:
            .three
        case .four:
            .four
        case .five:
            .five
        case .six:
            .six
        }
    }

    private static func project(
        _ alignment: SemanticTableColumnAlignment
    ) -> ProjectedTableColumnAlignment
    {
        switch alignment
        {
        case .leading:
            .leading
        case .center:
            .center
        case .trailing:
            .trailing
        case .unspecified:
            .unspecified
        }
    }

    private static func project(
        _ target: SemanticTableEvidenceTarget
    ) -> ProjectedTableEvidenceTarget
    {
        switch target
        {
        case .table:
            .table
        case let .row(row):
            .row(row.value)
        case let .cell(row, cell):
            .cell(
                row: row.value,
                cell: cell.value
            )
        }
    }

    private static func project(
        _ target: SemanticTableConfidenceTarget
    ) -> ProjectedTableConfidenceTarget
    {
        switch target
        {
        case .table:
            .table
        case let .cell(row, cell):
            .cell(
                row: row.value,
                cell: cell.value
            )
        }
    }

    private static func project(
        _ kind: SemanticTableRepairKind
    ) -> ProjectedTableRepairKind
    {
        switch kind
        {
        case .nonpositiveRowSpanNormalizedToOne:
            .nonpositiveRowSpanNormalizedToOne
        case .nonpositiveColumnSpanNormalizedToOne:
            .nonpositiveColumnSpanNormalizedToOne
        case .headerRowCountClamped:
            .headerRowCountClamped
        case .contradictoryCellHeaderFlagDiscarded:
            .contradictoryCellHeaderFlagDiscarded
        case .blankSourceLocationDiscarded:
            .blankSourceLocationDiscarded
        }
    }
}
