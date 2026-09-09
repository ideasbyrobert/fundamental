struct AppliedSemanticCodeConversion: Equatable, Sendable
{
    let content: CanonicalDocumentContent
    let mappings: [CodeConversionPointMap]

    init?(_ conversion: SemanticCodeConversion, in source: CanonicalDocument)
    {
        let originalIDs = Set(source.content.blocks.map(\.blockID))
        guard source.content.blocks.allSatisfy(
            { EditableSemanticBlock($0.block) != nil }
        ),
              conversion.continuationBlockIDs.allSatisfy(
            { !originalIDs.contains($0) }
        ),
              let selection = SemanticBlockSelection(
                  range: conversion.range, in: source
              ),
              let result = CodeConversionResult(
                  conversion, selection: selection
              )
        else
        {
            return nil
        }
        var blocks = source.content.blocks
        blocks.replaceSubrange(selection.indices, with: result.blocks)
        guard let first = blocks.first,
              let content = CanonicalDocumentContent(
                  firstBlock: first, remainingBlocks: Array(blocks.dropFirst())
              )
        else
        {
            return nil
        }
        self.content = content
        mappings = result.mappings
    }
}
