import XCTest
@testable import SpectreCore

final class SpectreAlgorithmTests: XCTestCase {
    func testLongPasswordMatchesReferenceVector() throws {
        XCTAssertEqual(try SpectreAlgorithm.password(
            for: SpectreConfiguration(
                userName: "Robert Lee Mitchell",
                userSecret: "banana colored duckling",
                siteName: "twitter.com",
                resultType: .long
            )
        ), "PozoLalv0_Yelo")

        XCTAssertEqual(try SpectreAlgorithm.password(
            for: SpectreConfiguration(
                userName: "Test",
                userSecret: "LoremIpsum",
                siteName: "site.com",
                counter: 3,
                resultType: .long
            )
        ), "Mupp5?YenpQeyu")

        XCTAssertEqual(try SpectreAlgorithm.password(
            for: SpectreConfiguration(
                userName: "Täst",
                userSecret: "ümläute",
                siteName: "site.com",
                resultType: .long
            )
        ), "Diga3!PabbFezu")
    }

    func testTemplateRenderingMatchesCharacterClasses() throws {
        let siteKey = [UInt8](repeating: 0, count: 32)
        XCTAssertEqual(try SpectreAlgorithm.renderPassword(siteKey: siteKey, resultType: .long), "Baba0@BabaBaba")
    }

    func testTemplateRenderingMatchesMaximumForEachResultType() throws {
        let userKey = try SpectreAlgorithm.deriveUserKey(userName: "user", userSecret: "LoremIpsum")
        let siteKey = try SpectreAlgorithm.deriveSiteKey(
            userKey: userKey,
            siteName: "site.com",
            counter: 1,
            purpose: .authentication,
            context: nil
        )

        XCTAssertEqual(try SpectreAlgorithm.renderPassword(siteKey: siteKey, resultType: .maximum), "R6)Z7h0q2@yeeWnBQsDi")
        XCTAssertEqual(try SpectreAlgorithm.renderPassword(siteKey: siteKey, resultType: .long), "Ceju9*KomxWijq")
        XCTAssertEqual(try SpectreAlgorithm.renderPassword(siteKey: siteKey, resultType: .medium), "Cej4+Qec")
        XCTAssertEqual(try SpectreAlgorithm.renderPassword(siteKey: siteKey, resultType: .basic), "RQK4iSm3")
        XCTAssertEqual(try SpectreAlgorithm.renderPassword(siteKey: siteKey, resultType: .short), "Cej4")
        XCTAssertEqual(try SpectreAlgorithm.renderPassword(siteKey: siteKey, resultType: .pin), "7694")
        XCTAssertEqual(try SpectreAlgorithm.renderPassword(siteKey: siteKey, resultType: .name), "cejjuqeco")
        XCTAssertEqual(try SpectreAlgorithm.renderPassword(siteKey: siteKey, resultType: .phrase), "cejj qec xiqjoli qor")
    }
}
