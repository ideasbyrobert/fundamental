import FundamentalLayout

struct ViewportWindowAdmissionDiagnostics: Equatable, Sendable
{
    let snapshot: ViewportSnapshot
    let query: ViewportQueryDiagnostics
    let materializationUsage: LayoutMaterializationUsage
}

extension ViewportSnapshot
{
    @MainActor
    static func windowAdmissionDiagnostics(
        _ indexed: LayoutIndexedProjection,
        request: ViewportRequest,
        capacity: LayoutMaterializationCapacity
    ) throws -> ViewportWindowAdmissionDiagnostics?
    {
        guard let window = ViewportResidentExtentWindow.admit(
                  indexed: indexed,
                  request: request
              ),
              let diagnostics = try indexed.materializationDiagnostics(
                  selection: window.selection,
                  capacity: capacity
              ),
              let snapshot = Self(
                  window: window,
                  materialization: diagnostics.materialization
              )
        else
        {
            return nil
        }
        return ViewportWindowAdmissionDiagnostics(
            snapshot: snapshot,
            query: window.query,
            materializationUsage: diagnostics.usage
        )
    }

    private init?(
        window: ViewportResidentExtentWindow,
        materialization: LayoutFragmentMaterialization
    )
    {
        let extents = window.all
        let fragments = materialization.fragments
        guard window.request.expectedLayoutLineage
                == materialization.lineage,
              window.documentSize == materialization.documentSize,
              extents.count == fragments.count,
              zip(extents, fragments).allSatisfy(
                  { $0.extent == $1.extent }
              )
        else
        {
            return nil
        }
        let residents = zip(extents, fragments).map
        {
            ResidentLayoutFragment(
                residence: $0.residence,
                fragment: $1.fragment
            )
        }
        guard let first = residents.first,
              let anchorResident = residents.first(where:
              {
                  $0.canAnchor
                    && $0.fragment.anchor
                        == window.sourceAnchor.fragment
              }),
              window.sourceAnchor.relativeX
                == anchorResident.fragment.frame.minX
                    - window.request.visibleBounds.minX,
              window.sourceAnchor.relativeY
                == anchorResident.fragment.frame.minY
                    - window.request.visibleBounds.minY
        else
        {
            return nil
        }
        lineage = ViewportLineage(
            layout: materialization.lineage,
            generation: window.request.generation,
            specification: window.request.specification
        )
        visibleBounds = window.request.visibleBounds
        documentSize = materialization.documentSize
        sourceAnchor = window.sourceAnchor
        self.residents = ViewportResidents(
            first: first,
            remaining: Array(residents.dropFirst())
        )
    }
}
