extension RasterAccumulator
{
    func fontUTF16Count(
        _ font: RasterFontIdentity
    ) -> Int?
    {
        guard let names = adding(
            font.postScriptName.utf16.count,
            font.uniqueName.utf16.count
        )
        else
        {
            return nil
        }
        return adding(names, font.versionName.utf16.count)
    }
}
