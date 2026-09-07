package enum DocumentFileWriteCondition: Sendable
{
    case absent
    case unchanged(DocumentFileRevision)
}
