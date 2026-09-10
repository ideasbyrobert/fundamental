extension WrappingSource
{
    package static func == (lhs: Self, rhs: Self) -> Bool
    {
        lhs.utf16 == rhs.utf16
    }

    package func hash(into hasher: inout Hasher)
    {
        hasher.combine(utf16)
    }
}
