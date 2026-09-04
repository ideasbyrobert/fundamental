import FundamentalLayout

struct ViewportResidentExtentWindow: Equatable, Sendable
{
    let request: ViewportRequest
    let documentSize: LayoutSize
    let sourceAnchor: ViewportSourceAnchor
    let first: ViewportResidentExtent
    let remaining: [ViewportResidentExtent]
    let selection: LayoutFragmentExtentSelection
    let query: ViewportQueryDiagnostics

    var all: [ViewportResidentExtent]
    {
        [first] + remaining
    }

    fileprivate init?(
        indexed: LayoutIndexedProjection,
        request: ViewportRequest
    )
    {
        guard indexed.lineage == request.expectedLayoutLineage,
              request.visibleBounds.minX == 0,
              request.visibleBounds.size.width
                == indexed.documentSize.width,
              let precedingBounds = Self.precedingBounds(request),
              let followingBounds = Self.followingBounds(request),
              let admitted = Self.admitResidents(
                  indexed: indexed,
                  request: request,
                  precedingBounds: precedingBounds,
                  followingBounds: followingBounds
              ),
              let first = admitted.residents.first,
              let anchor = Self.sourceAnchor(
                  visible: admitted.visible,
                  overscan: admitted.overscan,
                  bounds: request.visibleBounds
              ),
              let selection = indexed.selection(
                  extents: admitted.residents.map(\.extent)
              )
        else
        {
            return nil
        }
        self.request = request
        documentSize = indexed.documentSize
        sourceAnchor = anchor
        self.first = first
        remaining = Array(admitted.residents.dropFirst())
        self.selection = selection
        query = admitted.query
    }

    static func admit(
        indexed: LayoutIndexedProjection,
        request: ViewportRequest
    ) -> Self?
    {
        Self(indexed: indexed, request: request)
    }
}
