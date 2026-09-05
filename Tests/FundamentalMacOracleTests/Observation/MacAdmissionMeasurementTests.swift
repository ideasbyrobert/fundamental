import Testing

@Suite("Native admission measurement order")
@MainActor
struct MacAdmissionMeasurementTests
{
    @Test("warmups and samples preserve setup action consumption order")
    func orderedConsumption() throws
    {
        var events: [Int] = []
        let samples = try MacAdmissionMeasurement.measure(
            "guardian",
            prepare:
            {
                index in
                events.append(index * 3)
                return index
            },
            action:
            {
                index in
                events.append(index * 3 + 1)
                return index + 100
            },
            consume:
            {
                index, output in
                #expect(output == index + 100)
                events.append(index * 3 + 2)
            }
        )
        #expect(events == Array(0 ..< 105))
        #expect(samples.count == 30)
        #expect(samples.allSatisfy { $0.isFinite && $0 >= 0 })
    }

    @Test("failed consumption refuses the experiment before further work")
    func failedConsumptionStops() throws
    {
        var prepared: [Int] = []
        #expect(throws: MacOracleTestFailure.self)
        {
            _ = try MacAdmissionMeasurement.measure(
                "refused",
                prepare:
                {
                    index in
                    prepared.append(index)
                    return index
                },
                action: { $0 },
                consume:
                {
                    index, _ in
                    if index == 7
                    {
                        throw MacOracleTestFailure.admission
                    }
                }
            )
        }
        #expect(prepared == Array(0 ... 7))
    }
}
