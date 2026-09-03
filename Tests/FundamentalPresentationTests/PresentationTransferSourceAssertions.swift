import Testing

@testable import FundamentalPresentation
@testable import FundamentalRaster

extension PresentationTransferTests
{
    func expectSlices(
        _ source: [RasterSourceSlice],
        equals result: [PresentationSourceSlice]
    )
    {
        #expect(source.count == result.count)
        for pair in zip(source, result)
        {
            #expect(pair.0.text == pair.1.text)
            #expect(pair.0.range == pair.1.range)
            #expect(scopeSignature(pair.0.scope)
                == scopeSignature(pair.1.scope))
            #expect(sourceSignature(pair.0.source)
                == sourceSignature(pair.1.source))
        }
    }

    private func scopeSignature(_ value: RasterRunScope) -> String
    {
        switch value
        {
        case .direct: "direct"
        case let .link(value): "link:\(value)"
        case let .language(value): "language:\(value)"
        case let .linkAndLanguage(link, language):
            "both:\(link):\(language)"
        }
    }

    private func scopeSignature(_ value: PresentationRunScope) -> String
    {
        switch value
        {
        case .direct: "direct"
        case let .link(value): "link:\(value)"
        case let .language(value): "language:\(value)"
        case let .linkAndLanguage(link, language):
            "both:\(link):\(language)"
        }
    }
}
