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

    enum PurchaseOutcome { case success, pending, cancelled }

    func purchase() async throws -> PurchaseOutcome {
        guard let product = proProduct else { return .cancelled }
        let result = try await product.purchase()
        switch result {
        case .success(let verification):
            let tx = try verification.payloadValue
            await tx.finish()
            await refreshStatus()
            return .success
        case .pending:  return .pending
        case .userCancelled: return .cancelled
        @unknown default: return .cancelled
        }
    }

    func restore() async {
        isLoading = true
        defer { isLoading = false }
        try? await StoreKit.AppStore.sync()
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
