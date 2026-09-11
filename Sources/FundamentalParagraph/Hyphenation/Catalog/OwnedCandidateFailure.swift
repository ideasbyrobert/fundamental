package enum OwnedCandidateFailure: Error, Equatable, Sendable
{
    case invalidCatalog
    case contextualCaseMapping
    case unmappedLowercase(Int)
    case changedIdentity
    case changedSpelling
    case invalidBoundary(Int)
}
