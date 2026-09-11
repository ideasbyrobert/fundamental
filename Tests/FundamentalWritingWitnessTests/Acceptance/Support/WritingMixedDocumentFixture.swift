import Testing

@testable import FundamentalDocument

@MainActor
enum WritingMixedDocumentFixture
{
    static let roleCount = 12

    static func document(edited: Int = 0) throws -> WritingTestDocument
    {
        var blocks: [SemanticBlock] = []
        for index in 0 ..< roleCount
        {
            var source = try runs(edited: index < edited)
            if index >= 10
            {
                source.append(SemanticRun(text: "\r\n\treturn \"😀\"\n"))
            }
            blocks.append(try WritingInlineFixture.roles(source)[index])
        }
        blocks += [
            .listItem(SemanticListItem(kind: .numbered, runs: [])),
            .listItem(SemanticListItem(kind: .numbered, runs: [
                SemanticRun(text: "\n")
            ])),
            .listItem(SemanticListItem(kind: .bulleted, runs: []))
        ]
        return try WritingTestDocument(blocks: blocks)
    }

    static func runs(edited: Bool) throws -> [SemanticRun]
    {
        let text = ["A ", "e\u{301} ", "Я ", "B ",
                    "C ", "2 ", "3", " 👩🏽‍💻"]
        let result: [SemanticRun] = try text.enumerated().map
        {
            index, value in
            let traits: Set<SemanticInlineTrait> = index < 7
                ? [WritingInlineFixture.traits[index]] : []
            if index % 4 == 0
            {
                return SemanticRun(text: value, traits: traits)
            }
            return try WritingScopeFixture.run(
                value, form: index % 4 - 1, traits: traits
            )
        }
        guard edited else { return result }
        return ["A", "z", " "].map
        {
            SemanticRun(text: $0, traits: [.strong])
        } + result.dropFirst()
    }

    static func expect(
        _ session: DocumentSession, edited: Int
    ) throws
    {
        let expected = try document(edited: edited).state.snapshot.document
        #expect(session.document.documentID == expected.documentID)
        let exact = session.document.content == expected.content
        #expect(exact, "Mixed document differs after \(edited) edits")
        #expect(session.history.undo.count == edited)
    }
}
