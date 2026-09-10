import Testing

@testable import FundamentalDocument
@testable import FundamentalWritingWitness

extension WritingScopeFixture
{
    @MainActor
    static func choose(_ form: Int, in window: WritingTestWindow) throws
    {
        let destination = try #require(SemanticLinkDestination(link))
        let identifier = try #require(SemanticLanguageIdentifier(language))
        let choices: [[SemanticRunScopeAssignment]] = [
            [.link(destination)], [.language(identifier)],
            [.link(destination), .language(identifier)]
        ]
        for assignment in choices[form]
        {
            try choose(assignment, in: window)
        }
    }

    @MainActor
    static func choose(
        _ assignment: SemanticRunScopeAssignment, in window: WritingTestWindow
    ) throws
    {
        let result = window.session.submit(.typingScope(
            window.session.observation, assignment
        ))
        switch result
        {
        case .applied, .unchanged:
            break
        case .refused:
            Issue.record("Expected a canonical scope choice")
            return
        }
        try #require(window.controller.bridge.project(in: window.view))
    }
}
