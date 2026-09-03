package struct PresentationColorSpaceIdentity: Equatable, Sendable
{
    package let name: String
    package let profile: [UInt8]
    package let componentCount: Int

    package init?(
        name: String,
        profile: [UInt8],
        componentCount: Int
    )
    {
        guard name.contains(where:
        {
            !$0.isWhitespace
        }),
              !profile.isEmpty,
              componentCount > 0
        else
        {
            return nil
        }
        self.name = name
        self.profile = profile
        self.componentCount = componentCount
    }
}
