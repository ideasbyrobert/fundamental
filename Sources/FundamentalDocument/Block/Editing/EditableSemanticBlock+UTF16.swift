extension EditableSemanticBlock
{
    var utf16Count: Int
    {
        canonicalTextForMeasurement.utf16.count
    }

    func admitsEditableBoundary(
        at offset: DocumentUTF16Offset
    ) -> Bool
    {
        let text = canonicalTextForMeasurement
        guard offset.value <= text.utf16.count
        else
        {
            return false
        }

        let utf16Index = text.utf16.index(
            text.utf16.startIndex,
            offsetBy: offset.value
        )
        guard let scalarIndex = utf16Index.samePosition(
            in: text.unicodeScalars
        )
        else
        {
            return false
        }
        return scalarIndex.samePosition(in: text) != nil
    }

    private var canonicalTextForMeasurement: String
    {
        runs.lazy.map(\.text).joined()
    }
}
