import Testing
@testable import FundamentalDocument

@Suite("Semantic run attributes")
struct SemanticRunAttributesTests
{
    @Test("direct attributes preserve exact traits without scope")
    func directAttributesPreserveTraits() throws
    {
        let attributes = SemanticRunAttributes.direct(traits: Self.traits)
        guard case let .direct(traits) = attributes
        else
        {
            Issue.record("Expected direct attributes")
            return
        }
        #expect(traits == Self.traits)
    }

    @Test("scoped attributes preserve every exact scope form")
    func scopedAttributesPreserveEveryScopeForm() throws
    {
        for scope in try Self.scopes()
        {
            let attributes = SemanticRunAttributes.scoped(
                traits: Self.traits,
                scopes: scope
            )
            guard case let .scoped(traits, admitted) = attributes
            else
            {
                Issue.record("Expected scoped attributes")
                return
            }
            #expect(traits == Self.traits)
            #expect(admitted == scope)
        }
    }

    @Test("a direct run projects exact attributes")
    func directRunProjectsExactAttributes()
    {
        #expect(Self.directRun().attributes == .direct(traits: Self.traits))
    }

    @Test("every scoped run projects exact attributes")
    func everyScopedRunProjectsExactAttributes() throws
    {
        for scope in try Self.scopes()
        {
            #expect(Self.scopedRun(scope).attributes == .scoped(
                traits: Self.traits,
                scopes: scope
            ))
        }
    }

    @Test("direct attributes reconstruct exact spelling")
    func directAttributesReconstructExactSpelling()
    {
        let attributes = SemanticRunAttributes.direct(traits: Self.traits)
        let run = SemanticRun(text: "Rebuilt", attributes: attributes)

        #expect(run == Self.directRun("Rebuilt"))
    }

    @Test("scoped attributes reconstruct every scope form")
    func scopedAttributesReconstructEveryScopeForm() throws
    {
        for scope in try Self.scopes()
        {
            let attributes = SemanticRunAttributes.scoped(
                traits: Self.traits,
                scopes: scope
            )
            #expect(SemanticRun(
                text: "Rebuilt",
                attributes: attributes
            ) == Self.scopedRun(scope, text: "Rebuilt"))
        }
    }

    @Test("empty canonical runs project and reconstruct exactly")
    func emptyCanonicalRunsRoundTrip() throws
    {
        let scopedRuns = try Self.scopes().map
        {
            Self.scopedRun($0, text: "")
        }
        let runs = [Self.directRun("")] + scopedRuns
        for run in runs
        {
            #expect(SemanticRun(
                text: run.text,
                attributes: run.attributes
            ) == run)
        }
    }
}
