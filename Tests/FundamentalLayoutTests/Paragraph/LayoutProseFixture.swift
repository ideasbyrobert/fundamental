import AppKit
import Foundation
import Testing

@testable import FundamentalDocument
@testable import FundamentalLayout
@testable import FundamentalProjection

@MainActor
enum LayoutProseFixture
{
    static func runs() throws -> [SemanticRun]
    {
        let language = try #require(SemanticLanguageIdentifier("ru_RU"))
        let link = try #require(SemanticLinkDestination("https://example.com"))
        return [
            LayoutFixture.direct("extra", traits: [.strong]),
            LayoutFixture.direct("", traits: [.inlineCode]),
            LayoutFixture.direct("ordinary re\u{AD}presentation 👩‍💻 "),
            .scoped(.init(
                text: "раи", traits: [.underline],
                scopes: .linkAndLanguage(link: link, language: language)
            )),
            LayoutFixture.direct("", traits: [.emphasis]),
            .scoped(.init(
                text: "\u{306}", traits: [.emphasis],
                scopes: .language(language)
            )),
            .scoped(.init(
                text: "он представление", traits: [],
                scopes: .language(language)
            )),
            LayoutFixture.direct("\r\n\tend  \u{2028}")
        ]
    }

    static func prose(_ runs: [SemanticRun]) -> ProjectedProse
    {
        ProjectedProse(
            role: .body, runs: runs, blockID: LayoutFixture.blockID(0)
        )
    }

    static func session(_ runs: [SemanticRun]) throws -> DocumentSession
    {
        let block = IdentifiedSemanticBlock(
            blockID: FundamentalBlockID(LayoutFixture.blockID(0)),
            block: .paragraph(.init(runs: runs))
        )
        let document = CanonicalDocument(
            documentID: FundamentalDocumentID(LayoutFixture.documentID),
            revision: DocumentRevision(7),
            content: try #require(CanonicalDocumentContent(
                firstBlock: block, remainingBlocks: []
            ))
        )
        let point = DocumentPoint(
            documentID: document.documentID, revision: document.revision,
            blockID: block.blockID,
            utf16Offset: try #require(DocumentUTF16Offset(0))
        )
        let editable = try #require(EditableDocumentSnapshot(
            snapshot: DocumentSnapshot(
                generation: SnapshotGeneration(9), document: document
            ),
            selection: .caret(at: point)
        ))
        return DocumentSession(state: .editable(editable), initiallySaved: true)
    }
}
