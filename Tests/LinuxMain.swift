import XCTest
@testable import MonzoTests

XCTMain([
     testCase(ClientGlobalTests.allTests),
     testCase(ClientAuthenticationTests.allTests),
])
