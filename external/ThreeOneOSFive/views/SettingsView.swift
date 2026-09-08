import SwiftUI

struct SettingsView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.appLanguage) private var language
    @EnvironmentObject private var appState: AppState
    @AppStorage(AppLanguage.storageKey) private var languageCode = AppLanguage.english.rawValue

    var body: some View {
        NavigationStack {
            ZStack {
                Color.black.ignoresSafeArea()
                List {
                    // App brand row
                    Section {
                        HStack(spacing: 14) {
                            AppLogo()
                            VStack(alignment: .leading, spacing: 3) {
                                Text("REGSXD EXTERNAL")
                                    .font(.system(size: 15, weight: .bold))
                                    .foregroundStyle(.white)
                                Text(language.text("common.version", appVersion))
                                    .font(.subheadline)
                                    .foregroundStyle(Color(white: 0.45))
                            }
                        }
                        .padding(.vertical, 4)
                        .listRowBackground(Color(white: 0.07))
                    }

                    // Language
                    Section(header: sectionHeader(language.text("settings.language"))) {
                        Picker(language.text("settings.language"), selection: $languageCode) {
                            ForEach(AppLanguage.allCases) { option in
                                Text(option.displayName).tag(option.rawValue)
                            }
                        }
                        .pickerStyle(.segmented)
                        .labelsHidden()
                        .listRowBackground(Color(white: 0.07))
                    }

                    // Device info
                    Section(header: sectionHeader(language.text("common.device"))) {
                        labeledRow(language.text("dashboard.hardware_model"), value: AppInfo.displayMachineName)
                        labeledRow(language.text("settings.ios_version"), value: "\(AppInfo.osVersion) (\(AppInfo.osBuild))")
                    }

                    // Supported versions
                    Section {
                        HStack {
                            Text(language.text("settings.current_version"))
                                .foregroundStyle(Color(white: 0.8))
                            Spacer()
                            Text(language.text(appState.isSupported ? "settings.supported" : "settings.unsupported"))
                                .foregroundStyle(appState.isSupported ? Color.green : Color.red)
                        }
                        .listRowBackground(Color(white: 0.07))
                        labeledRow("iOS 17", value: ExploitSupportPolicy.verifiedIOS17Range)
                        labeledRow("iOS 18", value: ExploitSupportPolicy.verifiedIOS18Range)
                        labeledRow("iOS 26", value: ExploitSupportPolicy.verifiedIOS26Range)
                        VStack(alignment: .leading, spacing: 8) {
                            Text("iOS 27.0")
                                .font(.body)
                                .foregroundStyle(Color(white: 0.8))
                            ForEach(ExploitSupportPolicy.verifiedIOS27Builds, id: \.build) { version in
                                Text(versionLabel(version))
                                    .font(.caption.monospaced())
                                    .foregroundStyle(Color(white: 0.45))
                            }
                        }
                        .padding(.vertical, 2)
                        .listRowBackground(Color(white: 0.07))
                    } header: {
                        sectionHeader(language.text("settings.verified_versions"))
                    } footer: {
                        Text(language.text("settings.supported_versions_footer"))
                            .foregroundStyle(Color(white: 0.35))
                    }

                    // Social
                    Section(header: sectionHeader(language.text("settings.social_media"))) {
                        creditsRow(
                            name: "GitHub",
                            role: language.text("social.github_role"),
                            url: "https://github.com/YangJiiii/3105"
                        )
                        creditsRow(
                            name: "Cộng Đồng IOSVN",
                            role: language.text("social.iosvn_role"),
                            url: "https://t.me/ioscrackvn"
                        )
                    }

                    // Credits
                    Section(header: sectionHeader(language.text("settings.credits"))) {
                        creditsRow(name: "</> REGS XD", role: language.text("credit.yangjiii"), url: "https://github.com/YangJiiii/3105")
                        creditsRow(name: "0xjohnnydev", role: language.text("credit.filzaslop"), url: "https://github.com/0xjohnnydev/FilzaSlop")
                        creditsRow(name: "LeminLimez", role: language.text("credit.pocket_poster"), url: "https://github.com/leminlimez/Pocket-Poster")
                        creditsRow(name: "CrazyMind90", role: language.text("credit.sandbox_escape"), url: "https://github.com/CrazyMind90")
                        creditsRow(name: "forcequitOS", role: language.text("credit.forcequit"), url: "https://github.com/forcequitOS")
                    }
                }
                .scrollContentBackground(.hidden)
                .background(Color.black)
            }
            .tint(AppTheme.accent)
            .navigationTitle(language.text("settings.title"))
            .navigationBarTitleDisplayMode(.inline)
            .toolbarBackground(Color.black, for: .navigationBar)
            .toolbarBackground(.visible, for: .navigationBar)
            .toolbar {
                ToolbarItem(placement: .principal) {
                    Text(language.text("settings.title").uppercased())
                        .font(.system(size: 14, weight: .bold))
                        .foregroundStyle(.white)
                        .kerning(1)
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(language.text("common.done")) { dismiss() }
                        .fontWeight(.semibold)
                        .foregroundStyle(.red)
                }
            }
        }
    }

    // MARK: - Helpers

    private func sectionHeader(_ title: String) -> some View {
        Text(title.uppercased())
            .font(.system(size: 10, weight: .bold))
            .foregroundStyle(.red.opacity(0.8))
            .kerning(1.2)
    }

    private func labeledRow(_ label: String, value: String) -> some View {
        HStack {
            Text(label)
                .foregroundStyle(Color(white: 0.8))
            Spacer()
            Text(value)
                .font(.body.monospaced())
                .foregroundStyle(Color(white: 0.5))
        }
        .listRowBackground(Color(white: 0.07))
    }

    private var appVersion: String {
        Bundle.main.object(forInfoDictionaryKey: "AppReleaseDisplayVersion") as? String
            ?? Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as? String
            ?? "1.0"
    }

    private func versionLabel(
        _ version: (beta: Int, publicBeta: Int?, build: String)
    ) -> String {
        if let publicBeta = version.publicBeta {
            return language.text(
                "settings.developer_public_beta_build",
                Int64(version.beta),
                Int64(publicBeta),
                version.build
            )
        }
        return language.text(
            "settings.developer_beta_build",
            Int64(version.beta),
            version.build
        )
    }

    @ViewBuilder
    private func creditsRow(name: String, role: String, url: String) -> some View {
        if let destination = URL(string: url) {
            Link(destination: destination) {
                HStack(spacing: 12) {
                    VStack(alignment: .leading, spacing: 3) {
                        Text(name)
                            .font(.system(size: 14, weight: .semibold))
                            .foregroundStyle(.white)
                        Text(role)
                            .font(.caption)
                            .foregroundStyle(Color(white: 0.45))
                    }
                    Spacer()
                    Image(systemName: "arrow.up.right")
                        .font(.system(size: 12, weight: .medium))
                        .foregroundStyle(.red.opacity(0.7))
                }
                .contentShape(Rectangle())
            }
            .listRowBackground(Color(white: 0.07))
            .accessibilityLabel(language.text("accessibility.open_profile", name))
        }
    }
}
