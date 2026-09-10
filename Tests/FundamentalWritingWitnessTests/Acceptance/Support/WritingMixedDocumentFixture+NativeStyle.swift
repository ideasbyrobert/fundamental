import AppKit
import Testing

@testable import FundamentalDocument
@testable import FundamentalWritingWitness

extension WritingMixedDocumentFixture
{
    static func styledWriter(_ window: WritingTestWindow) throws
    {
        let projection = try #require(WritingProjection(window.session.state))
        let storage = try #require(window.view.textStorage)
        var ordinal = 0
        let blocks = window.session.document.content.blocks
        for (index, block) in blocks.enumerated()
        {
            let base = try #require(WritingTypography.attributes(
                for: block.block, ordinal: &ordinal
            )?[.font] as? NSFont)
            let runs = try #require(EditableSemanticBlock(block.block)).runs
            var offset = projection.map.spans[index].range.location
            for run in runs
            {
                defer { offset += run.text.utf16.count }
                guard !run.text.isEmpty else { continue }
                let attributes = storage.attributes(
                    at: offset, effectiveRange: nil
                )
                try WritingInlineFixture.expect(
                    run.traits, in: attributes, base: base
                )
                switch run
                {
                case .direct:
                    #expect(attributes[.link] == nil)
                    #expect(attributes[.languageIdentifier] == nil)
                case let .scoped(value):
                    let form: Int
                    switch value.scopes
                    {
                    case .link: form = 0
                    case .language: form = 1
                    case .linkAndLanguage: form = 2
                    }
                    WritingScopeFixture.expect(form, in: attributes)
                }
            }
        }
    }
}
