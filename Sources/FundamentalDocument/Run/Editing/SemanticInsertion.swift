package struct SemanticInsertion: Equatable, Sendable
{
    let text: String
    let attributes: SemanticRunAttributes

    package init?(
        text: String,
        attributes: SemanticRunAttributes
    )
    {
        guard !text.isEmpty
        else
        {
            return nil
        }

        self.text = text
        self.attributes = attributes
    }

    var run: SemanticRun
    {
        SemanticRun(
            text: text,
            attributes: attributes
        )
    }
}
