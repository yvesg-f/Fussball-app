import SwiftUI

struct SettingsView: View {
    @EnvironmentObject private var settings: AppSettings
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            Form {
                Section(settings.t("language")) {
                    ForEach(AppSettings.availableLanguages, id: \.code) { lang in
                        Button {
                            settings.language = lang.code
                        } label: {
                            HStack {
                                Text(lang.name)
                                    .foregroundStyle(.primary)
                                Spacer()
                                if settings.language == lang.code {
                                    Image(systemName: "checkmark")
                                        .foregroundStyle(.green)
                                }
                            }
                        }
                    }
                }

                Section(settings.t("appearance")) {
                    ForEach(AppSettings.AppColorScheme.allCases, id: \.self) { scheme in
                        Button {
                            settings.colorScheme = scheme
                        } label: {
                            HStack {
                                Image(systemName: scheme.symbol)
                                    .foregroundStyle(.green)
                                    .frame(width: 24)
                                Text(settings.t(scheme.localizedKey))
                                    .foregroundStyle(.primary)
                                Spacer()
                                if settings.colorScheme == scheme {
                                    Image(systemName: "checkmark")
                                        .foregroundStyle(.green)
                                }
                            }
                        }
                    }
                }
            }
            .navigationTitle(settings.t("settings"))
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button(settings.t("close")) { dismiss() }
                }
            }
        }
    }
}
