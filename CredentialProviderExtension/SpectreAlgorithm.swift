import Foundation
import CryptoExtras

public struct SpectreConfiguration: Sendable {
    public var userName: String
    public var userSecret: String
    public var siteName: String
    public var counter: UInt32
    public var purpose: SpectreKeyPurpose
    public var context: String?
    public var resultType: SpectreResultType

    public init(
        userName: String,
        userSecret: String,
        siteName: String,
        counter: UInt32 = 1,
        purpose: SpectreKeyPurpose = .authentication,
        context: String? = nil,
        resultType: SpectreResultType = .long
    ) {
        self.userName = userName
        self.userSecret = userSecret
        self.siteName = siteName
        self.counter = counter
        self.purpose = purpose
        self.context = context
        self.resultType = resultType
    }
}

public enum SpectreError: Error, LocalizedError {
    case scryptFailed(Int32)
    case hmacFailed(Int32)
    case invalidCharacterClass(Character)
    case insufficientSeed

    public var errorDescription: String? {
        switch self {
        case let .scryptFailed(status):
            return "scrypt derivation failed with status \(status)"
        case let .hmacFailed(status):
            return "HMAC-SHA256 failed with status \(status)"
        case let .invalidCharacterClass(character):
            return "Unknown Spectre character class: \(character)"
        case .insufficientSeed:
            return "Site key does not contain enough bytes for the selected template"
        }
    }
}

public enum SpectreAlgorithm {
    public static let scryptParameters = (N: UInt64(32_768), r: UInt32(8), p: UInt32(2), keyLength: 64)

    public static func password(for configuration: SpectreConfiguration) throws -> String {
        let userKey = try deriveUserKey(userName: configuration.userName, userSecret: configuration.userSecret)
        let siteKey = try deriveSiteKey(
            userKey: userKey,
            siteName: configuration.siteName,
            counter: configuration.counter,
            purpose: configuration.purpose,
            context: configuration.context
        )
        return try renderPassword(siteKey: siteKey, resultType: configuration.resultType)
    }

    static func deriveUserKey(userName: String, userSecret: String) throws -> [UInt8] {
        try deriveScrypt(
            password: Array(userSecret.utf8),
            salt: userKeySalt(userName: userName),
            parameters: scryptParameters
        )
    }

    static func deriveSiteKey(
        userKey: [UInt8],
        siteName: String,
        counter: UInt32,
        purpose: SpectreKeyPurpose,
        context: String?
    ) throws -> [UInt8] {
        try hmacSHA256(key: userKey, message: siteKeySalt(siteName: siteName, counter: counter, purpose: purpose, context: context))
    }

    static func renderPassword(siteKey: [UInt8], resultType: SpectreResultType) throws -> String {
        let templates = resultType.templates
        let template = templates[Int(siteKey[0]) % templates.count]
        guard siteKey.count > template.count else {
            throw SpectreError.insufficientSeed
        }

        var password = String()
        password.reserveCapacity(template.count)

        for (offset, characterClass) in template.enumerated() {
            guard let characters = SpectreCharacterClass.characters(for: characterClass) else {
                throw SpectreError.invalidCharacterClass(characterClass)
            }
            let seed = siteKey[offset + 1]
            let scalar = UnicodeScalar(characters[Int(seed) % characters.count])
            password.unicodeScalars.append(scalar)
        }

        return password
    }

    static func userKeySalt(userName: String) -> [UInt8] {
        makeScopedSalt(scope: SpectreKeyPurpose.authentication.scope, payload: Array(userName.utf8))
    }

    static func siteKeySalt(siteName: String, counter: UInt32, purpose: SpectreKeyPurpose, context: String?) -> [UInt8] {
        var salt = makeScopedSalt(scope: purpose.scope, payload: Array(siteName.utf8))
        salt.append(bigEndianBytes(counter), count: 4)

        if let context {
            let contextBytes = Array(context.utf8)
            salt.append(bigEndianBytes(UInt32(contextBytes.count)), count: 4)
            salt.append(contentsOf: contextBytes)
        }

        return salt
    }

    private static func makeScopedSalt(scope: String, payload: [UInt8]) -> [UInt8] {
        var salt = Array(scope.utf8)
        salt.append(bigEndianBytes(UInt32(payload.count)), count: 4)
        salt.append(contentsOf: payload)
        return salt
    }

    private static func bigEndianBytes(_ value: UInt32) -> [UInt8] {
        withUnsafeBytes(of: value.bigEndian, Array.init)
    }

    private static func deriveScrypt(
        password: [UInt8],
        salt: [UInt8],
        parameters: (N: UInt64, r: UInt32, p: UInt32, keyLength: Int)
    ) throws -> [UInt8] {
        let rounds = Int(exactly: parameters.N)
        let blockSize = Int(parameters.r)
        let parallelism = Int(parameters.p)

        guard let rounds else {
            throw SpectreError.scryptFailed(-1)
        }

        let derivedKey = try KDF.Scrypt.deriveKey(
            from: password,
            salt: salt,
            outputByteCount: parameters.keyLength,
            rounds: rounds,
            blockSize: blockSize,
            parallelism: parallelism
        )

        return derivedKey.withUnsafeBytes { Array($0) }
    }

    private static func hmacSHA256(key: [UInt8], message: [UInt8]) throws -> [UInt8] {
        let authenticationCode = HMAC<SHA256>.authenticationCode(for: message, using: SymmetricKey(data: key))
        return Array(authenticationCode)
    }
}

private extension [UInt8] {
    mutating func append(_ bytes: [UInt8], count: Int) {
        append(contentsOf: bytes.prefix(count))
    }
}
