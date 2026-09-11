import FundamentalNativeParagraph

extension ComposerReplayFixture
{
    static func sources() throws -> [(String, ParagraphComposition)]
    {
        var values: [(String, ParagraphComposition)] = []
        let endings = ["\n", "\r", "\r\n", "\u{B}", "\u{C}", "\u{85}",
                       "\u{2028}", "\u{2029}"]
        for (index, ending) in endings.enumerated()
        {
            let text = "aa \t" + ending + ending + " bb\t " + ending
            values.append((
                "ending-\(index)",
                try ParagraphFixture.compose(
                    AutomaticFixture.text(text), width: 80
                )
            ))
        }
        for (index, text) in ["", "\u{AD}", " \t ", "\u{AD}\u{AD}"]
            .enumerated()
        {
            values.append((
                "empty-\(index)",
                try ParagraphFixture.compose(
                    AutomaticFixture.text(text), width: 20
                )
            ))
        }
        let cases = [
            ("emergency", "WWWWWWWWWW", 40.0),
            ("whitespace", "  aa  \t bb \t", 40.0),
            ("greedy", "of of line of line wide to", 47.5),
            ("fitness", "wide in wide the in the word wide in the a", 52.5)
        ]
        for (name, text, width) in cases
        {
            values.append((
                name, try ParagraphFixture.compose(
                    AutomaticFixture.text(text), width: width
                )
            ))
        }
        return values
    }
}
