package struct LayoutFragmentMaterializationDiagnostics: Equatable, Sendable
{
    package let materialization: LayoutFragmentMaterialization
    package let usage: LayoutMaterializationUsage

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
