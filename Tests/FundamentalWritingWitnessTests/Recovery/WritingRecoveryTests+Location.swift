import Foundation
import Testing

@testable import FundamentalWritingWitness

extension WritingRecoveryTests
{
    @Test("UI fixtures isolate recovery without changing normal app locations")
    func location() throws
    {
        let environment = ["FUNDAMENTAL_UI_RECOVERY_DIRECTORY": "/tmp/fixture"]
        let development = "com.ideasbyrobert.Fundamental.Development"
        let normal = WritingRecoveryLocation.directory(identifier: development,
                                                         environment: [:])
        #expect(WritingRecoveryLocation.directory(identifier: development,
            environment: environment) == normal)
        let test = "com.ideasbyrobert.Fundamental.UITesting." +
            UUID().uuidString
        #expect(WritingRecoveryLocation.directory(identifier: test,
            environment: environment).path == "/tmp/fixture")
        #expect(WritingRecoveryLocation.directory(identifier: test,
            environment: ["FUNDAMENTAL_UI_RECOVERY_DIRECTORY": "relative"])
            .lastPathComponent == "Recovery")
    }
}
