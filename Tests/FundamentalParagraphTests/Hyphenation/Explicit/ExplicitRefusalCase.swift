@testable import FundamentalParagraph
struct ExplicitRefusalCase
{
    let name: String
    let text: String
    let refusal: ExplicitBreakRefusal

    init(_ name: String, _ text: String, _ refusal: ExplicitBreakRefusal)
    {
        self.name = name
        self.text = text
        self.refusal = refusal
    }
}
