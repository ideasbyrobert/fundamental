import AppKit
import CoreText
import Testing

@testable import FundamentalDocument
@testable import FundamentalMacOracle
@testable import FundamentalPresentation

extension WritingMixedDocumentFixture
{
    static func styledReader(
        _ block: IdentifiedSemanticBlock, residents: [PresentedResident]
    ) throws
    {
        let runs = try #require(EditableSemanticBlock(block.block)).runs
        let marks = residents.flatMap(\.marks)
        for (index, run) in runs.enumerated() where !run.traits.isEmpty
        {
            let batches = marks.compactMap
            {
                mark -> PresentationGlyphBatch? in
                guard case let .glyphs(batch) = mark,
                      containsRun(index, in: batch.sourceSlices)
                else { return nil }
                return batch
            }
            let batch = try #require(batches.first)
            let font = try #require(MacAdmittedFont(
                batch.font, sourceText: batch.sourceSlices.map(\.text).joined()
            ))
            let symbolic = CTFontGetSymbolicTraits(font.native)
            for trait in run.traits
            {
                switch trait
                {
                case .strong:
                    #expect(symbolic.contains(.traitBold))
                case .emphasis:
                    #expect(symbolic.contains(.traitItalic))
                case .inlineCode:
                    #expect(symbolic.contains(.traitMonoSpace))
                case .superscript:
                    #expect(batch.baselineOffset > 0)
                case .subscriptText:
                    #expect(batch.baselineOffset < 0)
                case .underline, .strikethrough:
                    let role: PresentationFillRole = trait == .underline
                        ? .underline : .strikethrough
                    #expect(marks.contains
                    {
                        guard case let .fill(fill) = $0
                        else { return false }
                        return fill.role == role
                            && containsRun(index, in: fill.sourceSlices)
                    })
                }
            }
        }
    }

    static func containsRun(
        _ index: Int, in slices: [PresentationSourceSlice]
    ) -> Bool
    {
        slices.contains
        {
            if case let .block(_, run, _) = $0.source
            {
                return run == index
            }
            return false
        }
    }
}
