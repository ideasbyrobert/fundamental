import FundamentalNativeParagraph

extension ComposerReplayFixture
{
    static func native() throws -> [(String, ParagraphComposition)]
    {
        let cases = [
            ("english", "extraordinary", "en_US", 60.0),
            ("russian", "район", "ru_RU", 35.0),
            ("decomposed", "раи\u{306}он", "ru_RU", 35.0),
            ("authored", "re\u{AD}presentation", "en_US", 100.0),
            ("mixed", "a re\u{AD}presentation extraordinary word",
             "en_US", 100.0),
            ("emoji", "👩‍💻 extraordinary раи\u{306}он", "en_US", 65.0)
        ]
        var values: [(String, ParagraphComposition)] = []
        for (name, text, language, width) in cases
        {
            let source = try AutomaticFixture.collection(
                ExplicitFixture.source(text, language: language),
                language: language == "ru_RU" ? .russian : .english
            )
            for size in [18.0, 36]
            {
                values.append((
                    "\(name)-\(Int(size))",
                    try ParagraphFixture.compose(
                        source, width: width * size / 18, size: size
                    )
                ))
            }
        }
        return values
    }
}
