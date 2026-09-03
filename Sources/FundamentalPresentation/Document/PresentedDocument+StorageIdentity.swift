package extension PresentedDocument
{
    func sharesStorage(
        with other: PresentedDocument
    ) -> Bool
    {
        storage === other.storage
    }
}
