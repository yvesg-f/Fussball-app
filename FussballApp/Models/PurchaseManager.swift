import StoreKit
import Foundation

@MainActor
final class PurchaseManager: ObservableObject {

    static let proProductID    = "com.tactixapp.ios.pro"
    static let freeLineupLimit = 2
    static let freePieceLimit  = 5

    @Published private(set) var isPro       = false
    @Published private(set) var proProduct: Product?
    @Published private(set) var isLoading   = false

    nonisolated(unsafe) private var updatesTask: Task<Void, Never>?

    init() {
        updatesTask = Task { [weak self] in
            for await result in Transaction.updates {
                if case .verified(let tx) = result { await tx.finish() }
                await self?.refreshStatus()
            }
        }
    }

    deinit { updatesTask?.cancel() }

    func load() async {
        isLoading = true
        defer { isLoading = false }
        do {
            let products = try await Product.products(for: [Self.proProductID])
            proProduct = products.first
        } catch {
            print("StoreKit load: \(error)")
        }
        await refreshStatus()
    }

    func purchase() async throws {
        guard let product = proProduct else { return }
        let result = try await product.purchase()
        switch result {
        case .success(let verification):
            let tx = try verification.payloadValue
            await tx.finish()
            await refreshStatus()
        case .pending, .userCancelled: break
        @unknown default: break
        }
    }

    func restore() async {
        isLoading = true
        defer { isLoading = false }
        await refreshStatus()
    }

    private func refreshStatus() async {
        var hasPro = false
        for await result in Transaction.currentEntitlements {
            if case .verified(let tx) = result,
               tx.productID == Self.proProductID,
               tx.revocationDate == nil {
                hasPro = true
            }
        }
        isPro = hasPro
    }
}
