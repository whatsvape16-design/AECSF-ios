import Foundation

struct LaunchEndpoints {
    let configEndpoint: String
    let fallbackShopUrl: String

    static func bundledDefaults() -> LaunchEndpoints {
        LaunchEndpoints(
            configEndpoint: EncodedUrls.configPrepare(),
            fallbackShopUrl: EncodedUrls.fallbackShop()
        )
    }
}

enum StartupManager {
    private static let prefsKeyShopUrl = "shop_url"
    private static let prefsKeyCachedAt = "cached_at"
    private static let cacheTtl: TimeInterval = 6 * 60 * 60

    static func resolve() async -> String {
        let endpoints = LaunchEndpoints.bundledDefaults()

        if let workerUrl = await fetchPrepareLaunchUrl(endpoints.configEndpoint), !workerUrl.isEmpty {
            writeCachedShopUrl(workerUrl)
            return workerUrl
        }

        if let cached = readCachedShopUrl() {
            return cached
        }

        let fallback = endpoints.fallbackShopUrl.isEmpty ? EncodedUrls.fallbackShop() : endpoints.fallbackShopUrl
        return fallback
    }

    private static func fetchPrepareLaunchUrl(_ configEndpoint: String) async -> String? {
        let apiUrl = configEndpoint.trimmingCharacters(in: .whitespacesAndNewlines)
        if apiUrl.isEmpty { return nil }

        guard let url = URL(string: apiUrl) else { return nil }
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.timeoutInterval = 8
        request.setValue("application/json", forHTTPHeaderField: "Accept")
        request.setValue("DiyaVapeApp/1.0", forHTTPHeaderField: "User-Agent")

        do {
            let (data, response) = try await URLSession.shared.data(for: request)
            guard let http = response as? HTTPURLResponse, (200...299).contains(http.statusCode) else {
                return nil
            }
            guard
                let json = try JSONSerialization.jsonObject(with: data) as? [String: Any],
                let shopUrl = json["url"] as? String,
                !shopUrl.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
            else {
                return nil
            }
            let launchUrl = Utils.installUrlToLaunchUrl(shopUrl)
            return launchUrl.isEmpty ? nil : launchUrl
        } catch {
            return nil
        }
    }

    private static func readCachedShopUrl() -> String? {
        let defaults = UserDefaults.standard
        let cachedAt = defaults.double(forKey: prefsKeyCachedAt)
        if cachedAt <= 0 || Date().timeIntervalSince1970 - cachedAt > cacheTtl {
            return nil
        }
        return defaults.string(forKey: prefsKeyShopUrl)
    }

    private static func writeCachedShopUrl(_ shopUrl: String) {
        let defaults = UserDefaults.standard
        defaults.set(shopUrl, forKey: prefsKeyShopUrl)
        defaults.set(Date().timeIntervalSince1970, forKey: prefsKeyCachedAt)
    }
}
