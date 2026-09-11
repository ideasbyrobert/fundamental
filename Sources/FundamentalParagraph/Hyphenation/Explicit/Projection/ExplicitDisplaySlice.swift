package struct ExplicitDisplaySlice: Sendable
{
    package let source: ParagraphWordSource
    package let range: Range<Int>
    package let selection: ExplicitSelectedBreak
    package let atoms: [ExplicitDisplayAtom]

    package var text: String
    {
        atoms.map
        {
            switch $0.kind
            {
            case .source:
                String(
                    decoding: source.source.utf16[$0.fragment.paragraphRange],
                    as: UTF16.self
                )
            case .suppressedSoftHyphen:
                ""
            case .conditionalHyphen:
                "\u{2010}"
            }
        }.joined()
    }
}
