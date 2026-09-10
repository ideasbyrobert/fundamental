package struct LayoutSelectionExtent: Equatable, Sendable
{
    package let leading: Double
    package let trailing: Double

    package init?(leading: Double, trailing: Double)
    {
        guard leading.isFinite, trailing.isFinite,
              (trailing - leading).isFinite
        else
        {
            return nil
        }
        self.leading = leading
        self.trailing = trailing
    }

    package var minX: Double
    {
        min(leading, trailing)
    }

    package var maxX: Double
    {
        max(leading, trailing)
    }
}
