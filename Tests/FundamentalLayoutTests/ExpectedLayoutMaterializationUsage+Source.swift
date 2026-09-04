@testable import FundamentalLayout

extension ExpectedLayoutMaterializationUsage
{
    mutating func consume(_ text: String)
    {
        residentUTF16Units += text.utf16.count
    }

    mutating func consume(_ font: LayoutFontIdentity)
    {
        consume(font.postScriptName)
        consume(font.uniqueName)
        consume(font.versionName)
        fontVariations += font.variations.count
    }

    mutating func consume(_ slices: [LayoutSourceSlice])
    {
        for slice in slices
        {
            sourceSlices += 1
            consume(slice.text)
            for payload in slice.scopePayloads
            {
                consume(payload)
            }
        }
    }
}
