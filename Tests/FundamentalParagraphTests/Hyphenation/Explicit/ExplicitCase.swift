@testable import FundamentalParagraph
struct ExplicitCase
{
    let name: String
    let text: String
    let unbroken: String
    let breaks: [ExplicitExpectedBreak]
    let language: String

    init(
        _ name: String, _ text: String, _ unbroken: String,
        _ breaks: [ExplicitExpectedBreak], language: String = "en_US"
    )
    {
        self.name = name
        self.text = text
        self.unbroken = unbroken
        self.breaks = breaks
        self.language = language
    }
}
