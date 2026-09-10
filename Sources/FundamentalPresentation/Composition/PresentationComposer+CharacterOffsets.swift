extension PresentationComposer
{
    static func characterOffsets(_ value: String) -> [Int]
    {
        var result = [0]
        var offset = 0
        for character in value
        {
            offset += String(character).utf16.count
            result.append(offset)
        }
        return result
    }
}
