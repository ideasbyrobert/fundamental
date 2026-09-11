@testable import FundamentalNativeParagraph
@testable import FundamentalParagraph
import CryptoKit
import Foundation
import Testing

@MainActor
struct SpacingWitnessTests
{
    @Test func EnglishRussianParagraphWitnessRetainsAllSourceAndInk() throws
    {
        let paragraphs = try ComposerWitness.paragraphs()
        for paragraph in paragraphs
        {
            try ParagraphAssertions.verify(paragraph)
            for plan in paragraph.segments.flatMap(\.lines)
            {
                try SpacingAssertions.geometry(SpacedNativeLine(plan))
            }
        }
        let raster = try ComposerWitness.raster(paragraphs)
        SpacingAssertions.unclipped(raster)
        try SpacingCapture.write(
            raster, name: "paragraphs", group: "spacing-witness"
        )
        try PatternEvidence.write(
            "paragraphs", group: "spacing-witness", record: [
                "lines": paragraphs.flatMap(\.segments).flatMap(\.lines).map
                {
                    ParagraphEvidence.describe($0)
                },
                "width": raster.width, "height": raster.height,
                "coveredPixels": raster.coveredPixels,
                "pixelBounds": SpacingEvidence.rectangle(raster.pixelBounds),
                "sha256": SHA256.hash(data: raster.bytes).map
                {
                    String(format: "%02x", $0)
                }.joined()
            ]
        )
    }
}
