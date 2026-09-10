import FundamentalDocument

extension WritingRunSequence
{
    func matches(_ other: WritingRunSequence) -> Bool
    {
        guard text.utf16.elementsEqual(other.text.utf16)
        else
        {
            return false
        }
        let left = runs.filter { !$0.text.isEmpty }
        let right = other.runs.filter { !$0.text.isEmpty }
        var first = 0
        var second = 0
        var firstOffset = 0
        var secondOffset = 0
        while first < left.count && second < right.count
        {
            guard DocumentTypingIntent(attributes: left[first].attributes) ==
                DocumentTypingIntent(attributes: right[second].attributes)
            else
            {
                return false
            }
            let count = min(left[first].text.utf16.count - firstOffset,
                            right[second].text.utf16.count - secondOffset)
            firstOffset += count
            secondOffset += count
            if firstOffset == left[first].text.utf16.count
            {
                first += 1
                firstOffset = 0
            }
            if secondOffset == right[second].text.utf16.count
            {
                second += 1
                secondOffset = 0
            }
        }
        return first == left.count && second == right.count
    }
}
