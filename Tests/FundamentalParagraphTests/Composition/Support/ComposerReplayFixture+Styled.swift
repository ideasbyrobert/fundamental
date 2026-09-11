import FundamentalNativeParagraph

extension ComposerReplayFixture
{
    static func styled() throws -> [(String, ParagraphComposition)]
    {
        let source = try WordFixture.source([
            WordFixture.run("👩‍💻 раи", traits: [.strong]),
            WordFixture.run("\u{306}", traits: [.emphasis]),
            WordFixture.run("он и "),
            WordFixture.run("", traits: [.underline]),
            WordFixture.run("район", traits: [.underline])
        ], language: "ru_RU")
        let formatting = try ParagraphFixture.compose(
            AutomaticFixture.collection(source, language: .russian), width: 36
        )
        let identical = try WordFixture.source([
            WordFixture.run("aa"), WordFixture.run("aa"), WordFixture.run("")
        ])
        var index = 0
        let fonts = try ParagraphComposition(
            legacy: AutomaticFixture.collection(identical), width: 200
        )
        {
            run in
            index += 1
            return try ShapingFixture.attributes(run, size: Double(index * 10))
        }
        return [("formatting", formatting), ("indexed-fonts", fonts)]
    }
}
