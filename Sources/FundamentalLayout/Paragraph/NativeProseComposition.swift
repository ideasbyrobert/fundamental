import AppKit
import FundamentalNativeParagraph
import FundamentalParagraph
import FundamentalProjection

@MainActor
struct NativeProseComposition
{
    let prose: ProjectedProse
    let paragraph: ParagraphComposition

    init(
        _ prose: ProjectedProse, width: Double, font: NSFont,
        language: NativeWordLanguage, defaultLanguage: String
    ) throws
    {
        guard width.isFinite, width > 0
        else
        {
            throw ParagraphFailure.invalidWidth
        }
        let words = try NativeParagraphWords(
            prose.paragraph, language: language,
            defaultLanguage: defaultLanguage
        )
        let collection = try ParagraphHyphens(
            words, catalog: OwnedPatternCatalog.bundled()
        )
        let layout = NativeTextKit2Layout()
        paragraph = try ParagraphComposition(collection, width: width)
        {
            try layout.attributes(
                font: font,
                traits: Set($0.traits.map(ProjectionSnapshot.project))
            )
        }
        self.prose = prose
    }
}
