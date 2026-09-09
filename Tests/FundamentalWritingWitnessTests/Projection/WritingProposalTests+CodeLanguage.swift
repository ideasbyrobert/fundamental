import Foundation
import Testing

@testable import FundamentalDocument
@testable import FundamentalWritingWitness

extension WritingProposalTests
{
    @Test
    func languageRequestsRetainExactSpellingAndOneCodeTarget() throws
    {
        let fixture = try WritingCodeFixture.document("A\r\n", tagged: false)
        let projection = try fixture.projection()
        let range = try #require(projection.range(NSRange(location: 7,
                                                          length: 0)))
        let request = try #require(WritingCodeLanguageRequest(
            in: projection, range: range
        ))
        #expect(request.value.isEmpty)
        for value in [" ", "\t\r\n"]
        {
            #expect(request.command(setting: value) == nil)
        }
        let value = " Swift e\u{301} 😀 "
        let command = try #require(request.command(setting: value))
        let result = try applied(command, to: fixture.state)
        guard case let .code(.languageTagged(code)) =
            result.snapshot.document.content.blocks[1].block
        else
        {
            Issue.record("Expected one tagged code block")
            return
        }
        #expect(code.language.value.utf16.elementsEqual(value.utf16))
        #expect(code.runs.map(\.text).joined().utf16
            .elementsEqual("A\r\n".utf16))
        let all = try #require(projection.range(NSRange(location: 0,
            length: projection.map.utf16Count)))
        #expect(WritingCodeLanguageRequest(in: projection, range: all) == nil)
        #expect(WritingCodeLanguageRequest(in: projection) == nil)
    }

    @Test
    func languageRequestsClearTagsAndRefuseStaleCompletion() throws
    {
        let fixture = try WritingCodeFixture.document("A", tagged: true)
        let projection = try fixture.projection()
        let range = try #require(projection.range(NSRange(location: 7,
                                                          length: 0)))
        let request = try #require(WritingCodeLanguageRequest(
            in: projection, range: range
        ))
        let command = try #require(request.command(setting: ""))
        let result = try applied(command, to: fixture.state)
        try WritingCodeFixture.expect(result.snapshot.document.content
            .blocks[1].block, text: "A", tagged: false)
        #expect(DocumentSessionTransition(command, in: .editable(result)) ==
            .refused(.staleObservation))
    }
}
