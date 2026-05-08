import SwiftUI

@main
struct FussballAppApp: App {
    @StateObject private var appStore       = AppStore()
    @StateObject private var purchaseManager = PurchaseManager()

    var body: some Scene {
        WindowGroup {
            HomeView(appStore: appStore)
                .environmentObject(purchaseManager)
                .task { await purchaseManager.load() }
        }
    }
}
