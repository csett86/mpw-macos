import Foundation

public enum SpectreResultType: CaseIterable, Sendable {
    case maximum
    case long
    case medium
    case basic
    case short
    case pin
    case name
    case phrase

    var templates: [String] {
        switch self {
        case .maximum:
            return [
                "anoxxxxxxxxxxxxxxxxx",
                "axxxxxxxxxxxxxxxxxno"
            ]
        case .long:
            return [
                "CvcvnoCvcvCvcv", "CvcvCvcvnoCvcv", "CvcvCvcvCvcvno",
                "CvccnoCvcvCvcv", "CvccCvcvnoCvcv", "CvccCvcvCvcvno",
                "CvcvnoCvccCvcv", "CvcvCvccnoCvcv", "CvcvCvccCvcvno",
                "CvcvnoCvcvCvcc", "CvcvCvcvnoCvcc", "CvcvCvcvCvccno",
                "CvccnoCvccCvcv", "CvccCvccnoCvcv", "CvccCvccCvcvno",
                "CvcvnoCvccCvcc", "CvcvCvccnoCvcc", "CvcvCvccCvccno",
                "CvccnoCvcvCvcc", "CvccCvcvnoCvcc", "CvccCvcvCvccno"
            ]
        case .medium:
            return ["CvcnoCvc", "CvcCvcno"]
        case .basic:
            return ["aaanaaan", "aannaaan", "aaannaaa"]
        case .short:
            return ["Cvcn"]
        case .pin:
            return ["nnnn"]
        case .name:
            return ["cvccvcvcv"]
        case .phrase:
            return ["cvcc cvc cvccvcv cvc", "cvc cvccvcvcv cvcv", "cv cvccv cvc cvcvccv"]
        }
    }
}

public enum SpectreKeyPurpose: Sendable {
    case authentication
    case identification
    case recovery

    var scope: String {
        switch self {
        case .authentication:
            return "com.lyndir.masterpassword"
        case .identification:
            return "com.lyndir.masterpassword.login"
        case .recovery:
            return "com.lyndir.masterpassword.answer"
        }
    }
}

enum SpectreCharacterClass {
    static func characters(for characterClass: Character) -> [UInt8]? {
        switch characterClass {
        case "V":
            return Array("AEIOU".utf8)
        case "C":
            return Array("BCDFGHJKLMNPQRSTVWXYZ".utf8)
        case "v":
            return Array("aeiou".utf8)
        case "c":
            return Array("bcdfghjklmnpqrstvwxyz".utf8)
        case "A":
            return Array("AEIOUBCDFGHJKLMNPQRSTVWXYZ".utf8)
        case "a":
            return Array("AEIOUaeiouBCDFGHJKLMNPQRSTVWXYZbcdfghjklmnpqrstvwxyz".utf8)
        case "n":
            return Array("0123456789".utf8)
        case "o":
            return Array("@&%?,=[]_:-+*$#!'^~;()/.".utf8)
        case "x":
            return Array("AEIOUaeiouBCDFGHJKLMNPQRSTVWXYZbcdfghjklmnpqrstvwxyz0123456789!@#$%^&*()".utf8)
        case " ":
            return [UInt8(ascii: " ")]
        default:
            return nil
        }
    }
}
