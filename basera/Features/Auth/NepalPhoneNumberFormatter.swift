import Foundation

enum NepalPhoneNumberFormatter {
    static func normalizedPhoneNumber(from rawValue: String) -> String? {
        let trimmed = rawValue.trimmingCharacters(in: .whitespacesAndNewlines)
        let digits = trimmed.filter(\.isNumber)

        if trimmed.hasPrefix("+") {
            guard digits.count == 13, digits.hasPrefix("977") else { return nil }
            let localNumber = String(digits.dropFirst(3))
            guard isValidLocalNumber(localNumber) else { return nil }
            return "+\(digits)"
        }

        if digits.count == 13, digits.hasPrefix("977") {
            let localNumber = String(digits.dropFirst(3))
            guard isValidLocalNumber(localNumber) else { return nil }
            return "+\(digits)"
        }

        guard isValidLocalNumber(digits) else { return nil }
        return "+977\(digits)"
    }

    static func formattedDisplayString(from normalizedPhoneNumber: String) -> String {
        guard let localNumber = localNumber(from: normalizedPhoneNumber) else {
            return normalizedPhoneNumber
        }

        return localNumber
    }

    static func maskedPhoneNumber(from normalizedPhoneNumber: String) -> String {
        guard let localNumber = localNumber(from: normalizedPhoneNumber) else {
            return normalizedPhoneNumber
        }

        let prefix = localNumber.prefix(2)
        let suffix = localNumber.suffix(2)
        return "+977 \(prefix)******\(suffix)"
    }

    static func sanitizedOTPCode(from rawValue: String) -> String {
        String(rawValue.filter(\.isNumber).prefix(6))
    }

    private static func localNumber(from normalizedPhoneNumber: String) -> String? {
        let digits = normalizedPhoneNumber.filter(\.isNumber)
        guard digits.count == 13, digits.hasPrefix("977") else { return nil }
        return String(digits.dropFirst(3))
    }

    private static func isValidLocalNumber(_ digits: String) -> Bool {
        digits.count == 10 && digits.hasPrefix("9")
    }
}
