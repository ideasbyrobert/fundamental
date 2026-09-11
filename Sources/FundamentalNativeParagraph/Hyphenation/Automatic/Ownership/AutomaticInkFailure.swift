import FundamentalParagraph
package enum AutomaticInkFailure: Error, Equatable, Sendable
{
    case invalidOwner
    case invalidIndex(Int)
    case foreignSelection
    case mismatchedEnd
    case excludedOwner
}
