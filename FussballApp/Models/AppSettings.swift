import SwiftUI

@MainActor
final class AppSettings: ObservableObject {

    static let availableLanguages: [(code: String, name: String)] = [
        ("de", "Deutsch"),
        ("en", "English"),
        ("es", "Español"),
        ("fr", "Français"),
        ("it", "Italiano"),
        ("pt", "Português"),
        ("nl", "Nederlands"),
        ("tr", "Türkçe"),
        ("pl", "Polski"),
        ("ar", "العربية")
    ]

    enum AppColorScheme: String, CaseIterable {
        case system, light, dark

        var swiftUIScheme: ColorScheme? {
            switch self {
            case .system: return nil
            case .light:  return .light
            case .dark:   return .dark
            }
        }

        var symbol: String {
            switch self {
            case .system: return "circle.lefthalf.filled"
            case .light:  return "sun.max"
            case .dark:   return "moon"
            }
        }

        var localizedKey: String {
            switch self {
            case .system: return "scheme_system"
            case .light:  return "scheme_light"
            case .dark:   return "scheme_dark"
            }
        }
    }

    @Published var language: String {
        didSet { UserDefaults.standard.set(language, forKey: "appLanguage") }
    }
    @Published var colorScheme: AppColorScheme {
        didSet { UserDefaults.standard.set(colorScheme.rawValue, forKey: "appColorScheme") }
    }

    init() {
        let saved = UserDefaults.standard.string(forKey: "appLanguage") ?? ""
        let codes = Self.availableLanguages.map(\.code)
        if codes.contains(saved) {
            language = saved
        } else {
            let sys = Locale.current.language.languageCode?.identifier ?? "de"
            language = codes.contains(sys) ? sys : "de"
        }
        colorScheme = AppColorScheme(
            rawValue: UserDefaults.standard.string(forKey: "appColorScheme") ?? "system"
        ) ?? .system
    }

    func t(_ key: String) -> String {
        Translations.strings[language]?[key]
            ?? Translations.strings["en"]?[key]
            ?? key
    }
}
