@testable import FundamentalParagraph
struct ExplicitExpectedBreak
{
    let offset: Int
    let prefix: String
    let suffix: String
    let ink: ExplicitHyphenInk

    init(
        _ offset: Int, _ prefix: String, _ suffix: String,
        _ ink: ExplicitHyphenInk
    )
    {
        self.offset = offset
        self.prefix = prefix
        self.suffix = suffix
        self.ink = ink
    }
}
