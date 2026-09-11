import FundamentalParagraph
final class AutomaticSelectionOwner: Sendable
{
}

package struct AutomaticSelection: Sendable
{
    let owner: AutomaticSelectionOwner
    let index: Int
}
