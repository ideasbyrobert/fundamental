struct LayoutFragmentMaterializationDiagnostics: Equatable, Sendable
{
    let materialization: LayoutFragmentMaterialization
    let usage: LayoutMaterializationUsage

    init(
        _ admission: LayoutMaterializationAdmissionToken,
        materialization: LayoutFragmentMaterialization,
        usage: LayoutMaterializationUsage
    )
    {
        self.materialization = materialization
        self.usage = usage
    }
}
