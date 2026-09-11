import FundamentalParagraph
package struct HyphenatedDisplay: Sendable
{
    package let body: ExplicitDisplayMap
    package let suffix: HyphenatedSuffix
    package let units: [UInt16]

    package var text: String
    {
        String(decoding: units, as: UTF16.self)
    }

    package init(
        _ collection: ParagraphHyphens, range: Range<Int>,
        end: HyphenatedLineEnd = .unbroken
    ) throws
    {
        switch end
        {
        case .unbroken:
            body = try ExplicitDisplayMap(collection.explicit, range: range)
            suffix = .none
            units = body.units
        case let .explicit(selection):
            body = try ExplicitDisplayMap(
                collection.explicit, range: range,
                end: .opportunity(selection)
            )
            suffix = .none
            units = body.units
        case let .automatic(selection):
            let ink = try collection.ink(for: selection)
            guard range.upperBound == ink.candidate.sourceOffset
            else
            {
                throw AutomaticInkFailure.mismatchedEnd
            }
            guard range.lowerBound <= ink.character.lowerBound
            else
            {
                throw AutomaticInkFailure.excludedOwner
            }
            body = try ExplicitDisplayMap(collection.explicit, range: range)
            suffix = .automatic(ink)
            units = body.units + [0x2010]
        }
    }
}
