import SwiftUI

struct ProUpgradeView: View {
    @EnvironmentObject private var pm: PurchaseManager
    @EnvironmentObject private var settings: AppSettings
    @Environment(\.dismiss) private var dismiss

    @State private var isPurchasing = false
    @State private var isRestoring  = false
    @State private var errorMessage: String?

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 28) {

                    // Icon + title
                    VStack(spacing: 10) {
                        ZStack {
                            Circle()
                                .fill(.green.opacity(0.12))
                                .frame(width: 90, height: 90)
                            Image(systemName: "star.circle.fill")
                                .font(.system(size: 52))
                                .foregroundStyle(.green)
                        }
                        Text("Tactix Pro")
                            .font(.title.bold())
                        Text(settings.t("pro_subtitle"))
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                    }
                    .padding(.top, 16)

                    // Feature list
                    VStack(alignment: .leading, spacing: 14) {
                        FeatureRow(icon: "person.3.fill",
                                   title: settings.t("unlimited_lineups"),
                                   subtitle: String(format: settings.t("free_max_lineups"),
                                                    PurchaseManager.freeLineupLimit))
                        FeatureRow(icon: "figure.soccer",
                                   title: settings.t("unlimited_set_pieces"),
                                   subtitle: String(format: settings.t("free_max_lineups"),
                                                    PurchaseManager.freePieceLimit))
                        FeatureRow(icon: "checkmark.shield.fill",
                                   title: settings.t("future_features"),
                                   subtitle: settings.t("auto_included"))
                    }
                    .padding()
                    .background(Color(.secondarySystemBackground),
                                in: RoundedRectangle(cornerRadius: 14))
                    .padding(.horizontal)

                    // Buy button
                    VStack(spacing: 12) {
                        Button {
                            Task { await buy() }
                        } label: {
                            Group {
                                if isPurchasing {
                                    ProgressView().tint(.white)
                                } else if let product = pm.proProduct {
                                    Text(String(format: settings.t("unlock_for"), product.displayPrice))
                                        .fontWeight(.semibold)
                                } else {
                                    Text(settings.t("loading"))
                                        .fontWeight(.semibold)
                                }
                            }
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 14)
                            .background(pm.proProduct == nil ? Color.secondary : Color.green,
                                        in: RoundedRectangle(cornerRadius: 12))
                            .foregroundStyle(.white)
                        }
                        .disabled(isPurchasing || pm.proProduct == nil)
                        .padding(.horizontal)

                        Button {
                            Task { await restore() }
                        } label: {
                            Group {
                                if isRestoring {
                                    ProgressView()
                                } else {
                                    Text(settings.t("restore_purchase"))
                                }
                            }
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                        }
                        .disabled(isRestoring)
                    }

                    Text(settings.t("payment_footer"))
                        .font(.caption)
                        .foregroundStyle(.tertiary)
                        .padding(.bottom, 8)
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button(settings.t("close")) { dismiss() }
                }
            }
            .alert(settings.t("error"), isPresented: Binding(
                get: { errorMessage != nil },
                set: { if !$0 { errorMessage = nil } }
            )) {
                Button(settings.t("ok"), role: .cancel) {}
            } message: {
                Text(errorMessage ?? "")
            }
        }
    }

    private func buy() async {
        isPurchasing = true
        defer { isPurchasing = false }
        do {
            try await pm.purchase()
            if pm.isPro { dismiss() }
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    private func restore() async {
        isRestoring = true
        defer { isRestoring = false }
        await pm.restore()
        if pm.isPro { dismiss() }
    }
}

private struct FeatureRow: View {
    let icon: String
    let title: String
    let subtitle: String

    var body: some View {
        HStack(spacing: 14) {
            Image(systemName: icon)
                .font(.system(size: 20))
                .foregroundStyle(.green)
                .frame(width: 28)
            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.subheadline.weight(.semibold))
                Text(subtitle)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            Spacer()
            Image(systemName: "checkmark.circle.fill")
                .foregroundStyle(.green)
        }
    }
}
