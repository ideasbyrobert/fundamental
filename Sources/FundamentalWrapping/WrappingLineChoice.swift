package struct WrappingLineChoice: Equatable, Hashable, Sendable
{
    package let range: Range<Int>
    package let indentation: Double
    package let advance: Double
    package let breakKind: WrappingLineBreak

    package init(
        range: Range<Int>, indentation: Double, advance: Double,
        breakKind: WrappingLineBreak
    )
    {
        self.range = range
        self.indentation = indentation == 0 ? 0 : indentation
        self.advance = advance == 0 ? 0 : advance
        self.breakKind = breakKind
    }
}
