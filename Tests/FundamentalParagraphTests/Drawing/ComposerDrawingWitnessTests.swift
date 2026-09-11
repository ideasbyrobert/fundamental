import FundamentalNativeParagraph
import Testing

@MainActor
struct ComposerDrawingWitnessTests
{
    @Test func stagedEnglishRussianParagraphsPreserveRenderedInk() throws
    {
        let paragraphs = try ComposerWitness.paragraphs().map
        {
            try ComposerDirectFixture.compose($0, width: $0.width).paragraph
        }
        for paragraph in paragraphs
        {
            try ParagraphAssertions.verify(paragraph)
        }
        let raster = try ComposerWitness.raster(paragraphs)
        SpacingAssertions.unclipped(raster)
        try SpacingCapture.write(
            raster, name: "paragraphs", group: "composer-witness"
        )
        try PatternEvidence.write(
            "witness", group: "composer-rendering-controls",
            record: SpacingEvidence.describe(raster)
        )
    }
}
