import FundamentalDocument

package struct SummitProjectionCorpus: Sendable
{
    package let snapshot: ProjectionSnapshot

    package init?()
    {
        guard let corpus = SummitDocumentCorpus()
        else
        {
            return nil
        }
        snapshot = ProjectionSnapshot(corpus.snapshot)
    }
}
