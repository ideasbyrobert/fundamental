extension OwnedPatternCatalog
{
    package static func bundled() throws -> OwnedPatternCatalog
    {
        try BundledParagraphPatterns.catalog()
    }
}
