import Foundation
import Testing

@testable import FundamentalDocument
@testable import FundamentalProjection

enum ProjectionListFixture
{
    static func item(_ kind: SemanticListKind, _ text: String) -> SemanticBlock
    {
        .listItem(SemanticListItem(kind: kind, runs: [SemanticRun(text: text)]))
    }

    static func body(_ text: String = "Body") -> SemanticBlock
    {
        .paragraph(SemanticParagraph(runs: [SemanticRun(text: text)]))
    }

    static func prose(_ block: ProjectedBlock) throws -> ProjectedProse
    {
        guard case let .prose(_, value) = block
        else
        {
            Issue.record("Expected projected prose")
            throw CocoaError(.coderReadCorrupt)
        }
        return value
    }

    static func position(_ block: ProjectedBlock) -> ProjectedListPosition?
    {
        guard case let .prose(_, prose) = block
        else
        {
            return nil
        }
        switch prose.role
        {
        case let .bulleted(position), let .numbered(position):
            return position
        case .body, .title, .section:
            return nil
        }
    }
}
