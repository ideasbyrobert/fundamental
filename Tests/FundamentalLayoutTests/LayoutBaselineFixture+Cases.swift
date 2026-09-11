import AppKit
import Testing

@testable import FundamentalLayout

extension LayoutBaselineFixture
{
    static func cases() throws -> [Self]
    {
        var result: [Self] = []
        for size in [18.0, 36]
        {
            let times = try #require(NSFont(
                name: "TimesNewRomanPSMT", size: size
            ))
            let descriptor = try #require(
                NSFont.systemFont(ofSize: size)
                    .fontDescriptor.withDesign(.serif)
            )
            let system = try #require(NSFont(
                descriptor: descriptor, size: size
            ))
            for (fontName, font) in [("times", times), ("system", system)]
            {
                for (traitName, traits) in traits
                {
                    for (index, origin) in [
                        (0, (16.0, 64.0)), (1, (32.25, 83.5))
                    ]
                    {
                        let baseline = try #require(LayoutPoint(
                            x: origin.0, y: origin.1
                        ))
                        result.append(try Self(
                            name: "\(fontName)-\(Int(size))-"
                                + "\(traitName)-\(index)",
                            font: font, traits: traits, baseline: baseline
                        ))
                    }
                }
            }
        }
        return result
    }
}
