import Foundation
import Security

enum ProviderKeychain {
    static let account = "codex-provider-switcher"

    private static func query(for service: String) -> [String: Any] {
        [kSecClass as String: kSecClassGenericPassword,
         kSecAttrService as String: service,
         kSecAttrAccount as String: account]
    }

    static func contains(_ service: String) throws -> Bool {
        let status = SecItemCopyMatching(query(for: service) as CFDictionary, nil)
        if status == errSecItemNotFound { return false }
        try check(status)
        return true
    }

    static func save(_ key: String, for service: String) throws {
        let match = query(for: service)
        let data = [kSecValueData as String: Data(key.utf8)]
        let status = SecItemUpdate(match as CFDictionary, data as CFDictionary)
        if status == errSecItemNotFound {
            let item = match.merging(data) { _, value in value }
            try check(SecItemAdd(item as CFDictionary, nil))
        } else {
            try check(status)
        }
    }

    private static func check(_ status: OSStatus) throws {
        guard status == errSecSuccess else { throw KeychainError(status: status) }
    }
}

private struct KeychainError: LocalizedError {
    let status: OSStatus

    var errorDescription: String? {
        let reason = SecCopyErrorMessageString(status, nil) as String? ?? String(status)
        return L10n.text("keychainError", reason)
    }
}
