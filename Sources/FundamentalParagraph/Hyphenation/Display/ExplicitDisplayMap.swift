package struct ExplicitDisplayMap: Sendable
{
    package let slice: ExplicitDisplaySlice
    package let intervals: [ExplicitDisplayInterval]
    package let occupied: [ExplicitDisplayInterval]
    package let text: String
    package let units: [UInt16]

    package init(
        _ collection: ExplicitParagraphHyphens,
        range: Range<Int>, end: ExplicitSliceEnd = .unbroken
    ) throws
    {
        let slice = try collection.project(range, end: end)
        var offset = 0
        let intervals = slice.atoms.map
        {
            atom in
            let length: Int
            switch atom.kind
            {
            case .source:
                length = atom.fragment.paragraphRange.count
            case .suppressedSoftHyphen:
                length = 0
            case .conditionalHyphen:
                length = 1
            }
            let end = offset + length
            let interval = ExplicitDisplayInterval(
                atom: atom, range: offset..<end
            )
            offset = end
            return interval
        }
        self.slice = slice
        self.intervals = intervals
        occupied = intervals.filter { !$0.range.isEmpty }
        text = slice.text
        units = Array(text.utf16)
        guard units.count == offset
        else
        {
            throw ExplicitShapingFailure.displayLength
        }
    }
}
