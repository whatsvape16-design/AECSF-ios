import Foundation
import WebKit

enum WebNavigationHelper {
    private static let checkoutMarkers = ["/checkout", "order-pay", "order-received"]

    static func handleBack(in webView: WKWebView) -> Bool {
        guard let current = webView.url?.absoluteString.trimmingCharacters(in: .whitespacesAndNewlines),
              !current.isEmpty else {
            return false
        }

        if isCheckoutLike(current) {
            if goBackToPreferred(in: webView) {
                return true
            }
            let cartUrl = shopOrigin(current) + "/cart/"
            webView.load(URLRequest(url: URL(string: cartUrl)!))
            return true
        }

        if webView.canGoBack {
            webView.goBack()
            return true
        }
        return false
    }

    static func recoverFromCacheMiss(in webView: WKWebView) {
        if goBackToPreferred(in: webView) {
            return
        }

        let current = webView.url?.absoluteString ?? ""
        let fallback = current.isEmpty ? EncodedUrls.fallbackShop() : shopOrigin(current) + "/"
        if let url = URL(string: fallback) {
            webView.load(URLRequest(url: url))
        }
    }

    private static func goBackToPreferred(in webView: WKWebView) -> Bool {
        for item in webView.backForwardList.backList.reversed() {
            let historyUrl = item.url.absoluteString
            if isPreferredBackTarget(historyUrl) {
                webView.go(to: item)
                return true
            }
        }
        return false
    }

    private static func isCheckoutLike(_ url: String) -> Bool {
        let lower = url.lowercased()
        return checkoutMarkers.contains { lower.contains($0) }
    }

    private static func isPreferredBackTarget(_ url: String) -> Bool {
        guard isSafeBackUrl(url) else { return false }
        let lower = url.lowercased()
        return lower.contains("/product/") ||
            lower.contains("/cart") ||
            lower.contains("/shop") ||
            lower.contains("/product-category") ||
            lower.contains("/?") ||
            isShopHome(lower)
    }

    private static func isSafeBackUrl(_ url: String) -> Bool {
        if url.isEmpty || url == "about:blank" { return false }
        let lower = url.lowercased()
        return !lower.contains("add-to-cart") &&
            !lower.contains("add_to_cart") &&
            !lower.contains("wc-ajax")
    }

    private static func isShopHome(_ url: String) -> Bool {
        guard let components = URLComponents(string: url) else { return false }
        let path = components.path.trimmingCharacters(in: CharacterSet(charactersIn: "/"))
        return path.isEmpty
    }

    private static func shopOrigin(_ url: String) -> String {
        guard let components = URLComponents(string: url),
              let scheme = components.scheme,
              let host = components.host else {
            return "https://diyavape.shop"
        }
        return "\(scheme)://\(host)"
    }
}
