enum WritingScopeDecision: Sendable
{
    case apply(String)
    case remove
    case cancel
}
