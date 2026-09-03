import FundamentalProjection

struct NativeSourceSegment
{
    let source: ProjectedTextSource
    let scope: LayoutRunScope
    let localRange: Range<Int>
    let sourceLowerBound: Int
}
