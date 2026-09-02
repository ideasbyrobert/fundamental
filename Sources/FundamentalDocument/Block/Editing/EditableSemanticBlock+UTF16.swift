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

    func characterBoundary(
        resolving offset: DocumentUTF16Offset,
        affinity: PostEditCaretAffinity
    ) -> DocumentUTF16Offset?
    {
        let text = canonicalTextForMeasurement
        guard let scalarIndex = scalarIndex(
            at: offset,
            in: text
        )
        else
        {
            return nil
        }

        guard scalarIndex.samePosition(in: text) == nil
        else
        {
            return offset
        }

        let characterIndex: String.Index
        switch affinity
        {
        case .preceding:
            guard let preceding = text.indices.last(
                where: { $0 < scalarIndex }
            )
            else
            {
                return nil
            }
            characterIndex = preceding
        case .following:
            characterIndex = text.indices.first(
                where: { $0 > scalarIndex }
            ) ?? text.endIndex
        }

        guard let utf16Index = characterIndex.samePosition(
            in: text.utf16
        )
        else
        {
            return nil
        }
        let distance = text.utf16.distance(
            from: text.utf16.startIndex,
            to: utf16Index
        )
        return DocumentUTF16Offset(distance)
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
