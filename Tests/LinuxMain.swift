import XCTest
@testable import MonzoTests

XCTMain([
     testCase(ClientTests.allTests),
     testCase(ClientAuthenticationTests.allTests),
])
