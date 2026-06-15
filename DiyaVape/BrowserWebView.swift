import SwiftUI
import WebKit

final class WebViewModel: ObservableObject {
    @Published var isLoading = true
    @Published var canGoBack = false
    weak var webView: WKWebView?

    func handleBack() -> Bool {
        guard let webView else { return false }
        return WebNavigationHelper.handleBack(in: webView)
    }
}

struct BrowserWebView: UIViewRepresentable {
    @ObservedObject var model: WebViewModel

    func makeCoordinator() -> Coordinator {
        Coordinator(model: model)
    }

    func makeUIView(context: Context) -> WKWebView {
        let config = WKWebViewConfiguration()
        config.websiteDataStore = .default()
        config.preferences.javaScriptEnabled = true

        let webView = WKWebView(frame: .zero, configuration: config)
        webView.navigationDelegate = context.coordinator
        webView.allowsBackForwardNavigationGestures = true
        webView.customUserAgent = (webView.value(forKey: "userAgent") as? String ?? "") + " DiyaVapeApp/1.0"
        model.webView = webView

        Task {
            let urlString = await StartupManager.resolve()
            await MainActor.run {
                if let url = URL(string: urlString) {
                    webView.load(URLRequest(url: url))
                }
            }
        }

        return webView
    }

    func updateUIView(_ uiView: WKWebView, context: Context) {}

    final class Coordinator: NSObject, WKNavigationDelegate {
        private let model: WebViewModel

        init(model: WebViewModel) {
            self.model = model
        }

        func webView(_ webView: WKWebView, didStartProvisionalNavigation navigation: WKNavigation!) {
            model.isLoading = true
        }

        func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
            model.isLoading = false
            model.canGoBack = webView.canGoBack
        }

        func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
            model.isLoading = false
            recoverIfNeeded(webView: webView, error: error)
        }

        func webView(_ webView: WKWebView, didFailProvisionalNavigation navigation: WKNavigation!, withError error: Error) {
            model.isLoading = false
            recoverIfNeeded(webView: webView, error: error)
        }

        private func recoverIfNeeded(webView: WKWebView, error: Error) {
            let nsError = error as NSError
            if nsError.domain == NSURLErrorDomain && nsError.code == NSURLErrorCannotFindHost {
                return
            }
            if "\(error)".localizedCaseInsensitiveContains("cache") {
                WebNavigationHelper.recoverFromCacheMiss(in: webView)
            }
        }
    }
}
