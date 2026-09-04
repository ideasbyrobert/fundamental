import Testing

extension SummitResidentLayoutWindowTests
{
    @Test("all prose code and Unicode forms match at both measures")
    func proseCodeAndUnicode() throws
    {
        let blocks = try ViewportWindowFixture.textBlocks()
        #expect(blocks.count == 10)
        let projection = try ViewportWindowFixture.projection(blocks)
        for width in [150.0, 720]
        {
            let value = try ViewportWindowFixture.product(
                projection: projection,
                width: width,
                originY: 0,
                height: 100_000,
                overscan: 0,
                limit: 100_000
            )
            ViewportWindowFixture.expectExact(value)
            #expect(!value.expected.residents.remaining.isEmpty)
        }
    }

    @Test("all admitted table forms preserve exact rich paint order")
    func tableForms() throws
    {
        let blocks = try ViewportWindowFixture.tableBlocks()
        #expect(blocks.count == 5)
        let value = try ViewportWindowFixture.product(
            blocks: blocks,
            width: 420,
            originY: 0,
            height: 100_000,
            overscan: 0,
            limit: 100_000
        )
        ViewportWindowFixture.expectExact(value)
        let anchors = value.expected.residents.all.map
        {
            $0.fragment.anchor
        }
        #expect(zip(anchors, anchors.dropFirst()).allSatisfy
        {
            $0.0.blockOrdinal < $0.1.blockOrdinal
                || ($0.0.blockOrdinal == $0.1.blockOrdinal
                    && $0.0.fragmentOrdinal < $0.1.fragmentOrdinal)
        })
    }
}
