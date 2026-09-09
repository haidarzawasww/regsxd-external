import SwiftUI

// MARK: - LicenseGateView

struct LicenseGateView<Content: View>: View {
    @StateObject private var license = LicenseService.shared
    let content: () -> Content

    init(@ViewBuilder content: @escaping () -> Content) {
        self.content = content
    }

    var body: some View {
        if let state = license.licenseState, state.isValid {
            content()
        } else {
            KeyEntryView()
        }
    }
}

// MARK: - KeyEntryView

struct KeyEntryView: View {
    @StateObject private var license = LicenseService.shared
    @State private var keyInput = ""
    @State private var shaking = false
    @State private var keyVisible = false

    var body: some View {
        ZStack {
            // Background gradient
            LinearGradient(
                colors: [Color.black, Color(red: 0.08, green: 0.0, blue: 0.0)],
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()

            // Subtle top red glow
            VStack {
                RadialGradient(
                    colors: [Color.red.opacity(0.18), Color.clear],
                    center: .center,
                    startRadius: 0,
                    endRadius: 260
                )
                .frame(height: 260)
                .offset(y: -60)
                Spacer()
            }
            .ignoresSafeArea()

            VStack(spacing: 0) {
                Spacer()

                // ── HEADER BLOCK ──
                VStack(spacing: 0) {

                    // Top accent bar
                    Rectangle()
                        .fill(Color.red)
                        .frame(width: 48, height: 3)
                        .clipShape(Capsule())
                        .padding(.bottom, 24)

                    // App Icon
                    ZStack {
                        RoundedRectangle(cornerRadius: 24, style: .continuous)
                            .fill(Color(white: 0.07))
                            .frame(width: 96, height: 96)
                            .overlay(
                                RoundedRectangle(cornerRadius: 24, style: .continuous)
                                    .stroke(Color.red.opacity(0.4), lineWidth: 1)
                            )

                        if let icon = UIImage(named: "AppIcon60x60") ?? UIImage(named: "AppIcon") {
                            Image(uiImage: icon)
                                .resizable()
                                .scaledToFill()
                                .frame(width: 96, height: 96)
                                .clipShape(RoundedRectangle(cornerRadius: 24, style: .continuous))
                        } else {
                            Text("RX")
                                .font(.system(size: 38, weight: .black))
                                .foregroundStyle(.red)
                        }
                    }
                    .padding(.bottom, 20)

                    // Title
                    Text("REGSXD EXTERNAL")
                        .font(.system(size: 22, weight: .black))
                        .foregroundStyle(.white)
                        .kerning(1.2)

                    // Divider
                    HStack(spacing: 8) {
                        Rectangle()
                            .fill(Color.red.opacity(0.25))
                            .frame(height: 1)
                        Text("BY REGS XD")
                            .font(.system(size: 9, weight: .semibold))
                            .foregroundStyle(Color(white: 0.3))
                            .kerning(2)
                            .fixedSize()
                        Rectangle()
                            .fill(Color.red.opacity(0.25))
                            .frame(height: 1)
                    }
                    .padding(.horizontal, 40)
                    .padding(.top, 14)
                    .padding(.bottom, 6)

                    Text("Enter your license key to continue")
                        .font(.system(size: 13))
                        .foregroundStyle(Color(white: 0.38))
                        .padding(.top, 8)
                }

                Spacer().frame(height: 40)

                // ── INPUT BLOCK ──
                VStack(spacing: 14) {

                    // Key field
                    ZStack(alignment: .trailing) {
                        Group {
                            if keyVisible {
                                TextField("XXXX-XXXX-XXXX-XXXX", text: $keyInput)
                                    .textContentType(.none)
                            } else {
                                SecureField("XXXX-XXXX-XXXX-XXXX", text: $keyInput)
                                    .textContentType(.none)
                            }
                        }
                        .font(.system(size: 15, weight: .semibold, design: .monospaced))
                        .multilineTextAlignment(.center)
                        .textInputAutocapitalization(.characters)
                        .autocorrectionDisabled()
                        .foregroundStyle(.white)
                        .padding(.vertical, 16)
                        .padding(.horizontal, 48)
                        .background(
                            RoundedRectangle(cornerRadius: 14, style: .continuous)
                                .fill(Color.red.opacity(0.07))
                                .overlay(
                                    RoundedRectangle(cornerRadius: 14, style: .continuous)
                                        .stroke(Color.red.opacity(0.55), lineWidth: 1)
                                )
                        )
                        .offset(x: shaking ? -8 : 0)
                        .animation(
                            shaking
                                ? .default.repeatCount(4, autoreverses: true).speed(8)
                                : .default,
                            value: shaking
                        )

                        // Eye toggle
                        Button {
                            keyVisible.toggle()
                        } label: {
                            Image(systemName: keyVisible ? "eye.slash" : "eye")
                                .font(.system(size: 14))
                                .foregroundStyle(Color(white: 0.4))
                        }
                        .padding(.trailing, 14)
                    }

                    // Error message
                    if let error = license.lastError {
                        HStack(spacing: 5) {
                            Rectangle()
                                .fill(Color.red)
                                .frame(width: 3)
                                .clipShape(Capsule())
                            Text(error)
                                .font(.caption)
                                .foregroundStyle(Color.red.opacity(0.9))
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.leading, 4)
                        .transition(.opacity.combined(with: .move(edge: .top)))
                    }

                    // Activate button
                    Button(action: submitKey) {
                        ZStack {
                            if license.isChecking {
                                HStack(spacing: 8) {
                                    ProgressView()
                                        .tint(.white)
                                        .scaleEffect(0.85)
                                    Text("Checking...")
                                        .font(.system(size: 15, weight: .semibold))
                                        .foregroundStyle(.white.opacity(0.7))
                                }
                            } else {
                                HStack(spacing: 8) {
                                    Text("ACTIVATE")
                                        .font(.system(size: 15, weight: .black))
                                        .foregroundStyle(.white)
                                        .kerning(1.5)
                                }
                            }
                        }
                        .frame(maxWidth: .infinity)
                        .frame(height: 54)
                        .background(
                            Group {
                                if keyInput.isEmpty || license.isChecking {
                                    Color.red.opacity(0.25)
                                } else {
                                    LinearGradient(
                                        colors: [Color(red: 0.85, green: 0.05, blue: 0.05), Color.red],
                                        startPoint: .leading,
                                        endPoint: .trailing
                                    )
                                }
                            }
                        )
                        .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
                        .overlay(
                            RoundedRectangle(cornerRadius: 14, style: .continuous)
                                .stroke(Color.red.opacity(keyInput.isEmpty ? 0.15 : 0.0), lineWidth: 1)
                        )
                    }
                    .disabled(keyInput.isEmpty || license.isChecking)
                }
                .padding(.horizontal, 28)
                .animation(.easeInOut(duration: 0.2), value: license.lastError)

                Spacer()

                // ── FOOTER BUTTONS ──
                VStack(spacing: 10) {
                    // Thin separator
                    HStack(spacing: 8) {
                        Rectangle().fill(Color(white: 0.12)).frame(height: 1)
                        Text("CONTACT")
                            .font(.system(size: 9, weight: .bold))
                            .foregroundStyle(Color(white: 0.25))
                            .kerning(2)
                            .fixedSize()
                        Rectangle().fill(Color(white: 0.12)).frame(height: 1)
                    }
                    .padding(.horizontal, 28)

                    HStack(spacing: 10) {
                        // Buy Key
                        Button {
                            if let url = URL(string: "https://wa.me/6283899369257") {
                                UIApplication.shared.open(url)
                            }
                        } label: {
                            HStack(spacing: 6) {
                                Text("BUY KEY")
                                    .font(.system(size: 12, weight: .bold))
                                    .kerning(0.8)
                            }
                            .frame(maxWidth: .infinity)
                            .frame(height: 42)
                            .foregroundStyle(.white)
                            .background(Color(red: 0.06, green: 0.48, blue: 0.24))
                            .clipShape(RoundedRectangle(cornerRadius: 11, style: .continuous))
                            .overlay(
                                RoundedRectangle(cornerRadius: 11, style: .continuous)
                                    .stroke(Color.green.opacity(0.25), lineWidth: 1)
                            )
                        }

                        // Channel
                        Button {
                            if let url = URL(string: "https://whatsapp.com/channel/0029Vb800WiJkK74Ssu8Fx0i") {
                                UIApplication.shared.open(url)
                            }
                        } label: {
                            HStack(spacing: 6) {
                                Text("CHANNEL")
                                    .font(.system(size: 12, weight: .bold))
                                    .kerning(0.8)
                            }
                            .frame(maxWidth: .infinity)
                            .frame(height: 42)
                            .foregroundStyle(.white)
                            .background(Color(red: 0.06, green: 0.48, blue: 0.24).opacity(0.6))
                            .clipShape(RoundedRectangle(cornerRadius: 11, style: .continuous))
                            .overlay(
                                RoundedRectangle(cornerRadius: 11, style: .continuous)
                                    .stroke(Color.green.opacity(0.15), lineWidth: 1)
                            )
                        }
                    }
                    .padding(.horizontal, 28)

                    Text("Key is bound to this device on first activation")
                        .font(.system(size: 10))
                        .foregroundStyle(Color(white: 0.22))
                        .padding(.bottom, 28)
                        .padding(.top, 4)
                }
            }
        }
    }

    private func submitKey() {
        let trimmed = keyInput.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return }
        Task {
            let success = await license.validate(key: trimmed)
            if !success {
                await MainActor.run {
                    shaking = true
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) { shaking = false }
                }
            }
        }
    }
}
