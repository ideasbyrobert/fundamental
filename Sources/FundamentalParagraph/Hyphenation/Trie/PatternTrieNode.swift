package struct PatternTrieNode: Sendable
{
    package var edges: [UInt32: Int] = [:]
    package var terminal: PatternTerminal = .branch
}
