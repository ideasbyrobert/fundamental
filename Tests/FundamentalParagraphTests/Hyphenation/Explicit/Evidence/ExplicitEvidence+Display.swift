@testable import FundamentalParagraph
extension ExplicitEvidence
{
    static func describe(_ outcome: ExplicitBreakOutcome) -> [String: Any]
    {
        switch outcome
        {
        case let .refused(reason):
            ["status": "refused", "reason": String(reflecting: reason)]
        case let .opportunity(value):
            [
                "status": "opportunity", "offset": value.sourceOffset,
                "ink": value.ink.rawValue, "owner": describe(value.owner)
            ]
        }
    }

    static func describe(_ slice: ExplicitDisplaySlice) -> [String: Any]
    {
        let selected: [String: Any]
        switch slice.selection
        {
        case .unbroken:
            selected = ["status": "unbroken"]
        case let .explicit(value):
            selected = describe(.opportunity(value))
        }
        return [
            "range": [slice.range.lowerBound, slice.range.upperBound],
            "displayUTF16": Array(slice.text.utf16),
            "selection": selected,
            "atoms": slice.atoms.map
            {
                [
                    "kind": $0.kind.rawValue,
                    "fragment": describe($0.fragment)
                ] as [String: Any]
            }
        ]
    }
}
