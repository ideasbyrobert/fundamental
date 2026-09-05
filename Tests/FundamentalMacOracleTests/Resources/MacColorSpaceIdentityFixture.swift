import FundamentalPresentation
import Testing

enum MacColorSpaceIdentityFixture
{
    static func mismatches(
        _ identity: PresentationColorSpaceIdentity
    ) throws -> [PresentationColorSpaceIdentity]
    {
        [
            try #require(PresentationColorSpaceIdentity(
                name: identity.name + " mismatched",
                profile: identity.profile,
                componentCount: identity.componentCount
            )),
            try #require(PresentationColorSpaceIdentity(
                name: identity.name,
                profile: [0, 1, 2, 3],
                componentCount: identity.componentCount
            )),
            try #require(PresentationColorSpaceIdentity(
                name: identity.name,
                profile: identity.profile,
                componentCount: identity.componentCount + 1
            ))
        ]
    }
}
