import SwiftUI

@main
struct FussballAppApp: App {
    @StateObject private var appStore        = AppStore()
    @StateObject private var purchaseManager = PurchaseManager()
    @StateObject private var appSettings     = AppSettings()

    var body: some Scene {
        WindowGroup {
            HomeView(appStore: appStore)
                .environmentObject(purchaseManager)
                .environmentObject(appSettings)
                .preferredColorScheme(appSettings.colorScheme.swiftUIScheme)
                .task { await purchaseManager.load() }
        }
    }
}
