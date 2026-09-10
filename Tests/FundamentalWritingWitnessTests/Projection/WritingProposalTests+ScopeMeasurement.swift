import Testing

@testable import FundamentalDocument

extension WritingProposalTests
{
    @Test("scoped timing corpus preserves the original text and block roles")
    func nativeScopeMeasurementCorpus() throws
    {
        let plain = try WritingMeasurementCorpus(paragraphs: 12, semantic: true)
        let scoped = try WritingMeasurementCorpus(
            paragraphs: 12, semantic: true, scoped: true
        )
        #expect(!plain.scoped && scoped.scoped)
        #expect(plain.utf16Count == scoped.utf16Count)
        for (index, pair) in zip(plain.document.content.blocks,
                                 scoped.document.content.blocks).enumerated()
        {
            let original = try #require(EditableSemanticBlock(pair.0.block))
            let changed = try #require(EditableSemanticBlock(pair.1.block))
            #expect(changed.replacingRuns(original.runs) == pair.0.block)
            let run = try #require(changed.runs.first)
            #expect(run.text.utf16.elementsEqual(original.runs[0].text.utf16))
            guard case let .scoped(traits, scopes) = run.attributes
            else
            {
                Issue.record("Expected an explicitly scoped timing run")
                continue
            }
            #expect(traits.isEmpty)
            switch scopes
            {
            case let .link(link):
                #expect(index % 3 == 0)
                #expect(link.value == "https://example.invalid/manuscript")
            case let .language(language):
                #expect(index % 3 == 1 && language.value == "en")
            case let .linkAndLanguage(link, language):
                #expect(index % 3 == 2 && language.value == "en")
                #expect(link.value == "https://example.invalid/manuscript")
            }
        }
    }
}
