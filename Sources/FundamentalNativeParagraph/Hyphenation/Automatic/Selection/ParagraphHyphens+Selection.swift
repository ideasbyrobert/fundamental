import FundamentalParagraph
extension ParagraphHyphens
{
    package func selectAutomatic(_ index: Int) throws -> AutomaticSelection
    {
        guard inks.indices.contains(index)
        else
        {
            throw AutomaticInkFailure.invalidIndex(index)
        }
        return AutomaticSelection(owner: identity, index: index)
    }

    package func ink(for selection: AutomaticSelection) throws
        -> AutomaticHyphenInk
    {
        guard selection.owner === identity
        else
        {
            throw AutomaticInkFailure.foreignSelection
        }
        guard inks.indices.contains(selection.index)
        else
        {
            throw AutomaticInkFailure.invalidIndex(selection.index)
        }
        return inks[selection.index]
    }
}
