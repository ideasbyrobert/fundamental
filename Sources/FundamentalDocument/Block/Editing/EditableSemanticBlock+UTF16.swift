extension EditableSemanticBlock
{
    var utf16Count: Int
    {
        canonicalTextForMeasurement.utf16.count
    }

    func admitsCharacterBoundary(
        at offset: DocumentUTF16Offset
    ) -> Bool
    {
        let text = canonicalTextForMeasurement
        guard let scalarIndex = scalarIndex(
            at: offset,
            in: text
        )
        else
        {
            return false
        }

        return scalarIndex.samePosition(in: text) != nil
    }

    func admitsScalarBoundary(
        at offset: DocumentUTF16Offset
    ) -> Bool
    {
        scalarIndex(
            at: offset,
            in: canonicalTextForMeasurement
        ) != nil
    }

    private func scalarIndex(
        at offset: DocumentUTF16Offset,
        in text: String
    ) -> String.Index?
    {
        guard offset.value <= text.utf16.count
        else
        {
            return nil
        }

        let utf16Index = text.utf16.index(
            text.utf16.startIndex,
            offsetBy: offset.value
        )
        return utf16Index.samePosition(
            in: text.unicodeScalars
        )
    }

    private var canonicalTextForMeasurement: String
    {
        runs.lazy.map(\.text).joined()
    }
}
