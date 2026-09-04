import AppKit

extension NativeViewportObservationFixture
{
    func unique(
        _ fragments: [NSTextLayoutFragment]
    ) -> [NSTextLayoutFragment]
    {
        var ranges: Set<Range<Int>> = []
        return fragments.filter
        {
            ranges.insert(sourceRange($0)).inserted
        }
    }

    func sourceRanges(
        _ fragments: [NSTextLayoutFragment]
    ) -> [Range<Int>]
    {
        unique(fragments).map(sourceRange).sorted
        {
            $0.lowerBound < $1.lowerBound
        }
    }

    func viewportRange() -> Range<Int>?
    {
        guard let range = controller.viewportRange
        else
        {
            return nil
        }
        return sourceRange(range)
    }

    func sourceRange(
        _ fragment: NSTextLayoutFragment
    ) -> Range<Int>
    {
        sourceRange(fragment.rangeInElement)
    }

    func text(
        of fragment: NSTextLayoutFragment
    ) -> String
    {
        let range = sourceRange(fragment)
        return source.substring(with: NSRange(
            location: range.lowerBound,
            length: range.count
        ))
    }

    private func sourceRange(_ range: NSTextRange) -> Range<Int>
    {
        let origin = storage.documentRange.location
        let lower = storage.offset(from: origin, to: range.location)
        let upper = storage.offset(from: origin, to: range.endLocation)
        return lower ..< upper
    }
}
