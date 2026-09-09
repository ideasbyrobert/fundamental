struct CodeConversionResult: Equatable, Sendable
{
    let blocks: [IdentifiedSemanticBlock]
    let mappings: [CodeConversionPointMap]

    init?(
        _ conversion: SemanticCodeConversion,
        selection: SemanticBlockSelection
    )
    {
        switch conversion.target
        {
        case let .code(language):
            guard let result = Self.join(
                selection.blocks, language: language
            )
            else
            {
                return nil
            }
            self = result
        case let .prose(style):
            guard let result = Self.split(
                selection.blocks, style: style,
                continuationBlockIDs: conversion.continuationBlockIDs
            )
            else
            {
                return nil
            }
            self = result
        }
    }

    init(
        blocks: [IdentifiedSemanticBlock],
        mappings: [CodeConversionPointMap]
    )
    {
        self.blocks = blocks
        self.mappings = mappings
    }
}
