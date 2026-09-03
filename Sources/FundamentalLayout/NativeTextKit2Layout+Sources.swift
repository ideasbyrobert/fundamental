import Foundation
import FundamentalProjection

extension NativeTextKit2Layout
{
    func slices(
        for range: NSRange,
        segments: [NativeSourceSegment],
        text: NSString
    ) -> [LayoutSourceSlice]
    {
        guard range.length > 0
        else
        {
            return []
        }
        let lower = range.location
        let upper = range.location + range.length
        return segments.compactMap
        {
            segment in
            let sliceLower = max(lower, segment.localRange.lowerBound)
            let sliceUpper = min(upper, segment.localRange.upperBound)
            guard sliceLower < sliceUpper
            else
            {
                return nil
            }
            let sourceLower = segment.sourceLowerBound
                + sliceLower - segment.localRange.lowerBound
            let sourceUpper = sourceLower + sliceUpper - sliceLower
            return LayoutSourceSlice(
                source: segment.source,
                scope: segment.scope,
                range: sourceLower ..< sourceUpper,
                text: text.substring(with: NSRange(
                    location: sliceLower,
                    length: sliceUpper - sliceLower
                ))
            )
        }
    }

    func sourceRange(_ source: ProjectedTextSource) -> Range<Int>
    {
        switch source
        {
        case let .block(_, _, range):
            range.value
        case let .caption(_, _, range):
            range.value
        case let .cell(_, _, _, _, range):
            range.value
        }
    }
}
