import Foundation
import FundamentalDocument

struct WritingFindResults: Equatable, Sendable
{
    let observation: DocumentObservation
    let query: WritingFindQuery
    let ranges: [NSRange]

    init(_ query: WritingFindQuery, in projection: WritingProjection)
    {
        observation = projection.observation
        self.query = query
        var boundaries: Set<Int> = [0]
        var position = 0
        for character in projection.text
        {
            position += character.utf16.count
            boundaries.insert(position)
        }
        let text = projection.text as NSString
        let options: NSString.CompareOptions = query.caseSensitive
            ? [] : [.caseInsensitive]
        var ranges: [NSRange] = []
        var offset = 0
        while offset < text.length
        {
            let match = text.range(of: query.text, options: options,
                range: NSRange(location: offset, length: text.length - offset))
            guard match.location != NSNotFound, match.length > 0
            else
            {
                break
            }
            let end = NSMaxRange(match)
            if boundaries.contains(match.location), boundaries.contains(end),
               let source = projection.range(match),
               source.start.blockID == source.end.blockID
            {
                ranges.append(match)
            }
            offset = end
        }
        self.ranges = ranges
    }

    func next(from selection: NSRange, backwards: Bool) -> NSRange?
    {
        if backwards
        {
            return ranges.last(where:
                { NSMaxRange($0) <= selection.location }) ?? ranges.last
        }
        return ranges.first(where:
            { $0.location >= NSMaxRange(selection) }) ?? ranges.first
    }
}
