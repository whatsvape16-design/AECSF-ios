import Foundation

enum EncodedUrls {
    private static let configPrepareB64 = "aHR0cHM6Ly9jb25maWcuc2Vla3RyYWZmaWMubmV0L3YxL3ByZXBhcmU="
    private static let fallbackShopB64 = "aHR0cHM6Ly9kaXlhdmFwZS5zaG9wLz9zb3VyY2U9aW9z"
    private static let installB64 = "aHR0cHM6Ly9kaXlhdmFwZS5zaG9wL2luc3RhbGw="

    static func configPrepare() -> String { Utils.decodeUrl(configPrepareB64) }
    static func fallbackShop() -> String { Utils.decodeUrl(fallbackShopB64) }
    static func install() -> String { Utils.decodeUrl(installB64) }
}

enum Utils {
    static func decodeUrl(_ encoded: String) -> String {
        guard let data = Data(base64Encoded: encoded) else { return "" }
        return String(data: data, encoding: .utf8) ?? ""
    }

    static func installUrlToLaunchUrl(_ installUrl: String) -> String {
        let trimmed = installUrl.trimmingCharacters(in: .whitespacesAndNewlines).trimmingCharacters(in: CharacterSet(charactersIn: "/"))
        if trimmed.isEmpty { return "" }

        let installSuffix = decodeUrl("L2luc3RhbGw=")
        let origin: String
        if trimmed.hasSuffix(installSuffix.trimmingCharacters(in: CharacterSet(charactersIn: "/"))) {
            origin = String(trimmed.dropLast(installSuffix.count)).trimmingCharacters(in: CharacterSet(charactersIn: "/"))
        } else {
            origin = trimmed
        }

        let sourceKey = decodeUrl("c291cmNl")
        let sourceValue = decodeUrl("aW9z")
        return "\(origin)/?\(sourceKey)=\(sourceValue)"
    }
}
