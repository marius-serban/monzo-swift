import XCTest
@testable import MonzoTests

XCTMain([
     testCase(AuthorizationTests.allTests),
     testCase(AuthenticationTests.allTests),
     testCase(PingTests.allTests),
     testCase(WhoamiTests.allTests),
     testCase(AccountsTests.allTests),
     testCase(BalanceTests.allTests),
     testCase(TransactionsTests.allTests),
])
