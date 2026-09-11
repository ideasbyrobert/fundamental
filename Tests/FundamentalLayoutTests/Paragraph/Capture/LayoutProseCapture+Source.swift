import FundamentalNativeParagraph
import FundamentalParagraph

extension LayoutProseCapture
{
    static func source(_ value: HyphenatedGlyphSource) -> [String: Any]
    {
        switch value
        {
        case let .source(atom):
            return [
                "kind": atom.kind.rawValue,
                "fragment": fragment(atom.fragment)
            ]
        case let .generated(ink):
            return [
                "kind": "generated",
                "range": range(ink.sourceRange),
                "character": range(ink.character),
                "context": ink.context.map(fragment),
                "styleOrigin": fragment(ink.styleOrigin)
            ]
        }
    }

    static func fragment(_ value: WordRunFragment) -> [String: Any]
    {
        [
            "run": value.runIndex,
            "paragraphRange": range(value.paragraphRange),
            "runRange": range(value.runRange)
        ]
    }
}
