import Testing

@testable import FundamentalDocument
@testable import FundamentalPresentation

extension WritingMixedDocumentFixture
{
    static func expectSource(
        _ block: IdentifiedSemanticBlock, residents: [PresentedResident]
    ) throws
    {
        let runs = try #require(EditableSemanticBlock(block.block)).runs
        let text = runs.map(\.text).joined()
        let lines = residents.compactMap(\.content.textLine)
        try #require(!lines.isEmpty)
        #expect(lines.map(\.text).joined().utf16.elementsEqual(text.utf16))
        for line in lines
        {
            #expect(line.sourceSlices.map(\.text).joined().utf16
                .elementsEqual(line.text.utf16))
            for slice in line.sourceSlices
            {
                guard case let .block(id, index, range) = slice.source
                else
                {
                    Issue.record("Reader source is not the reopened block")
                    continue
                }
                #expect(id == block.blockID.value)
                try #require(runs.indices.contains(index))
                let lower = runs.prefix(index).reduce(0)
                {
                    $0 + $1.text.utf16.count
                }
                #expect(range == lower ..< lower + runs[index].text.utf16.count)
                try #require(slice.range.lowerBound >= range.lowerBound)
                try #require(slice.range.upperBound <= range.upperBound)
                #expect(slice.text.utf16.elementsEqual(
                    Array(text.utf16)[slice.range]
                ))
                #expect(slice.scope == scope(runs[index]))
            }
        }
        if case .listItem = block.block
        {
            let markers = residents.filter { $0.content.listMarker != nil }
            #expect(markers.count == 1)
        }
    }

    static func scope(_ run: SemanticRun) -> PresentationRunScope
    {
        switch run
        {
        case .direct:
            .direct
        case let .scoped(value):
            switch value.scopes
            {
            case let .link(link):
                .link(link.value)
            case let .language(language):
                .language(language.value)
            case let .linkAndLanguage(link, language):
                .linkAndLanguage(link: link.value, language: language.value)
            }
        }
    }
}
