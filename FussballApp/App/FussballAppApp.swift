import SwiftUI

@main
struct FussballAppApp: App {
    @StateObject private var appStore        = AppStore()
    @StateObject private var purchaseManager = PurchaseManager()
    @StateObject private var appSettings     = AppSettings()

    var body: some Scene {
        WindowGroup {
            Group {
                if appStore.team != nil {
                    HomeView(appStore: appStore)
                } else {
                    OnboardingView(appStore: appStore)
                }
            }
            .environmentObject(purchaseManager)
            .environmentObject(appSettings)
            .preferredColorScheme(appSettings.colorScheme.swiftUIScheme)
            .animation(.easeInOut(duration: 0.35), value: appStore.team != nil)
            .task { await purchaseManager.load() }
        }
    }
}
