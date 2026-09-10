import Testing

@testable import FundamentalDocument
@testable import FundamentalWritingWitness

extension WritingProposalTests
{
    @Test("scope control state distinguishes exact spelling and absence",
          arguments: WritingScopeKind.allCases)
    func scopeControlsExactState(_ kind: WritingScopeKind) throws
    {
        let fixture = try WritingScopeControlFixture.document(kind: kind)
        let selected = try #require(WritingSelectedAttributes(
            fixture.projection()
        ))
        let mixed = WritingScopeSelection(kind: kind, in: selected)
        #expect(mixed.isMixed && mixed.hasScope && mixed.value.isEmpty)
        #expect(mixed.state == .mixed && mixed.uniform == nil)
        #expect(WritingInlineSelection(selected).state(of: .strong) == .on)
        let other: WritingScopeKind = kind == .link ? .language : .link
        let absent = WritingScopeSelection(kind: other, in: selected)
        #expect(!absent.isMixed && !absent.hasScope && absent.value.isEmpty)
        #expect(absent.state == .off)
        let block = try #require(fixture.state.snapshot.document.content
            .blocks.first).block
        let source = try WritingTestDocument(blocks: [block], start: 0, end: 1)
        let one = try #require(WritingSelectedAttributes(source.projection()))
        let uniform = WritingScopeSelection(kind: kind, in: one)
        #expect(!uniform.isMixed && uniform.hasScope && uniform.state == .on)
        #expect(uniform.value.utf16.elementsEqual("é".utf16))
        let caret = try #require(WritingSelectedAttributes(
            WritingTestDocument().projection()
        ))
        let empty = WritingScopeSelection(kind: kind, in: caret)
        #expect(empty.state == .off && !empty.hasScope)
    }

    @Test("scope requests refuse blank values and stale completion",
          arguments: WritingScopeKind.allCases)
    func scopeControlsRequestAdmission(_ kind: WritingScopeKind) throws
    {
        let fixture = try WritingScopeControlFixture.document(kind: kind)
        let request = try #require(WritingScopeRequest(
            kind: kind, in: fixture.projection()
        ))
        for value in ["", " ", "\t\r\n"]
        {
            #expect(request.setting(value) == nil)
        }
        let value = " New e\u{301} 😀 "
        let command = try #require(request.setting(value))
        let result = try applied(command, to: fixture.state)
        let current = try #require(WritingProjection(.editable(result)))
        let selected = try #require(WritingSelectedAttributes(current))
        let state = WritingScopeSelection(kind: kind, in: selected)
        #expect(state.value.utf16.elementsEqual(value.utf16))
        #expect(!state.isMixed && state.state == .on)
        #expect(current.text == "AB")
        #expect(DocumentSessionTransition(command, in: .editable(result)) ==
            .refused(.staleObservation))
    }
}
