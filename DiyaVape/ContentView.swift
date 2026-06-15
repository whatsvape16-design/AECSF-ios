import SwiftUI

struct ContentView: View {
    @StateObject private var model = WebViewModel()

    var body: some View {
        ZStack {
            BrowserWebView(model: model)
                .ignoresSafeArea()

            if model.isLoading {
                splashOverlay
            }
        }
    }

    private var splashOverlay: some View {
        ZStack {
            Color(red: 26 / 255, green: 18 / 255, blue: 48 / 255)
                .ignoresSafeArea()

            VStack(spacing: 20) {
                Image("SplashLogo")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 120, height: 120)
                    .clipShape(RoundedRectangle(cornerRadius: 24, style: .continuous))

                ProgressView()
                    .progressViewStyle(CircularProgressViewStyle(tint: Color(red: 167 / 255, green: 66 / 255, blue: 255 / 255)))
                    .scaleEffect(1.2)

                Text("Loading, please wait…")
                    .font(.subheadline)
                    .foregroundStyle(.white)
            }
            .padding(32)
        }
    }
}

#Preview {
    ContentView()
}
