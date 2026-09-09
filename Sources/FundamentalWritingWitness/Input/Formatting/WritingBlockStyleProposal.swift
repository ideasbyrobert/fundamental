import Foundation
import FundamentalDocument

struct WritingBlockStyleProposal: Equatable, Sendable
{
    let command: DocumentSessionCommand

    init?(
        style: CanonicalBlockStyle, range: DocumentRange,
        in projection: WritingProjection
    )
    {
        let document = projection.snapshot.snapshot.document
        guard let selection = SemanticBlockSelection(range: range,
                                                      in: document)
        else
        {
            return nil
        }
        if style == .monostyled
        {
            var language: SemanticCodeLanguageIdentifier?
            if selection.blocks.count == 1,
               case let .code(.languageTagged(code)) =
                   selection.blocks[0].block
            {
                language = code.language
            }
            command = .convertCode(projection.observation,
                SemanticCodeConversion(range: range, codeLanguage: language)
            )
            return
        }
        let containsCode = selection.blocks.contains
        {
            if case .code = $0.block
            {
                return true
            }
            return false
        }
        guard containsCode
        else
        {
            command = .style(projection.observation,
                SemanticBlockStyleChange(range: range, style: style)
            )
            return
        }
        guard let count = SemanticCodeConversion.proseContinuationCount(
            in: range, of: document
        ), count <= WritingSurfacePolicy.maximumParagraphs -
            projection.map.spans.count,
              let conversion = SemanticCodeConversion(
                  range: range, proseStyle: style,
                  continuationBlockIDs: (0 ..< count).map
                    { _ in FundamentalBlockID(UUID()) }
              )
        else
        {
            return nil
        }
        command = .convertCode(projection.observation, conversion)
    }
}
