extension RasterAccumulator
{
    func interactionSourceSliceCount(
        _ text: RasterInteractionText
    ) -> Int?
    {
        text.sourceSlices.count
    }

    func interactionSourceUTF16Count(
        _ text: RasterInteractionText
    ) -> Int?
    {
        guard let count = sourceSliceUTF16Count(text.sourceSlices)
        else
        {
            return nil
        }
        return adding(count, text.marker?.source.label.utf16.count ?? 0)
    }

    func sourceSliceUTF16Count(
        _ slices: [RasterSourceSlice]
    ) -> Int?
    {
        var count = 0
        for slice in slices
        {
            guard let scopeCount = scopeUTF16Count(slice.scope),
                  let textCount = adding(
                      slice.text.utf16.count,
                      scopeCount
                  ),
                  let next = adding(count, textCount)
            else
            {
                return nil
            }
            count = next
        }
        return count
    }

    func scopeUTF16Count(
        _ scope: RasterRunScope
    ) -> Int?
    {
        switch scope
        {
        case .direct:
            0
        case let .link(destination):
            destination.utf16.count
        case let .language(identifier):
            identifier.utf16.count
        case let .linkAndLanguage(link, language):
            adding(link.utf16.count, language.utf16.count)
        }
    }
}
