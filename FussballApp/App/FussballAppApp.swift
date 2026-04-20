import SwiftUI

@main
struct FussballAppApp: App {
    @StateObject private var appStore = AppStore()

    var body: some Scene {
        WindowGroup {
            HomeView(appStore: appStore)
        }
    }
}
