struct ViewportQueryDiagnostics: Equatable, Sendable
{
    let visibleFragmentsExamined: Int
    let precedingFragmentsExamined: Int
    let followingFragmentsExamined: Int

    var totalFragmentsExamined: Int
    {
        visibleFragmentsExamined
            + precedingFragmentsExamined
            + followingFragmentsExamined
    }

    static let zero = ViewportQueryDiagnostics(
        visibleFragmentsExamined: 0,
        precedingFragmentsExamined: 0,
        followingFragmentsExamined: 0
    )
}
