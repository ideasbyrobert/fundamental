import Testing

@testable import FundamentalDocument

@Suite("Typing intent retains exact attribute spelling")
struct DocumentTypingIntentTests
{
    @Test("intent equality distinguishes exact scopes traits and forms")
    func equality() throws
    {
        let firstLink = try #require(SemanticLinkDestination(
            "https://a.test/\u{E9}"
        ))
        let nextLink = try #require(SemanticLinkDestination(
            "https://a.test/e\u{301}"
        ))
        let firstLanguage = try #require(SemanticLanguageIdentifier("français"))
        let nextLanguage = try #require(SemanticLanguageIdentifier(
            "franc\u{327}ais"
        ))
        #expect(!firstLink.value.utf16.elementsEqual(nextLink.value.utf16))
        #expect(!firstLanguage.value.utf16.elementsEqual(
            nextLanguage.value.utf16
        ))
        let scopes: [SemanticRunScopes] = [
            .link(firstLink), .link(nextLink),
            .language(firstLanguage), .language(nextLanguage),
            .linkAndLanguage(link: firstLink, language: firstLanguage),
            .linkAndLanguage(link: nextLink, language: firstLanguage),
            .linkAndLanguage(link: firstLink, language: nextLanguage)
        ]
        let values = scopes.map
        {
            DocumentTypingIntent(attributes: .scoped(traits: [], scopes: $0))
        } + [DocumentTypingIntent(attributes: .direct(traits: [])),
             DocumentTypingIntent(attributes: .direct(traits: [.strong]))]
        for (index, value) in values.enumerated()
        {
            #expect(value == value)
            for other in values.dropFirst(index + 1)
            {
                #expect(value != other)
            }
        }
    }
}
