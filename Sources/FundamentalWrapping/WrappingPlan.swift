package struct WrappingPlan: Equatable, Hashable, Sendable
{
    package let source: WrappingSource
    package let width: Double
    package let lines: [WrappingLineChoice]

    package init?(
        source: WrappingSource, width: Double, lines: [WrappingLineChoice]
    )
    {
        guard width.isFinite, width > 0,
              Self.accepts(source: source, width: width, lines: lines)
        else
        {
            return nil
        }
        self.source = source
        self.width = width
        self.lines = lines
    }
}
