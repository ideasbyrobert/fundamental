extension LayoutMaterializationAccumulator
{
    mutating func consume(
        _ slices: [LayoutSourceSlice]
    ) -> Bool
    {
        for slice in slices
        {
            guard consumeSourceSlice()
            else
            {
                return false
            }
            guard consumeText(slice.text)
            else
            {
                return false
            }
            for payload in slice.scopePayloads
            {
                guard consumeText(payload)
                else
                {
                    return false
                }
            }
        }
        return true
    }

    mutating func consume(
        _ font: LayoutFontIdentity
    ) -> Bool
    {
        guard consumeFontVariations(font.variations.count),
              consumeText(font.postScriptName),
              consumeText(font.uniqueName),
              consumeText(font.versionName)
        else
        {
            return false
        }
        return true
    }

    mutating func consumeText(_ text: String) -> Bool
    {
        consumeUTF16Units(text.utf16.count)
    }
}
