import SwiftUI

// MARK: - Shared Models

struct InjectButton: Identifiable {
    let id = UUID()
    let name: String
    let category: String
    let bundleID: String
    let targetPath: String
    let resourceFileName: String
    let resourceSubfolder: String
    var launchAfterInject: Bool = false
}

struct OpenGameButton: Identifiable {
    let id = UUID()
    let name: String
    let bundleID: String
    let urlSchemes: [String]
    let appStoreID: String
}

// MARK: - Shared Result & Error

enum InjectResult {
    case working
    case success
    case failed(String)
}

enum InjectError: LocalizedError {
    case containerNotFound(String)
    case renameFailed(String)
    var errorDescription: String? {
        switch self {
        case .containerNotFound(let id): return "App not found: \(id)"
        case .renameFailed(let reason): return "File replace failed: \(reason)"
        }
    }
}

// MARK: - Resolve container helper

func resolveContainer(bundleID: String) throws -> URL {
    guard let path = ContainerStore.resolveAppContainerPath(bundleID: bundleID) else {
        throw InjectError.containerNotFound(bundleID)
    }
    return URL(fileURLWithPath: path, isDirectory: true)
}

// MARK: - Console View

struct ConsoleView: View {
    let logs: [String]

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            // console topbar
            HStack(spacing: 6) {
                // traffic lights
                Circle().fill(Color(white: 0.22)).frame(width: 7, height: 7)
                Circle().fill(Color(white: 0.22)).frame(width: 7, height: 7)
                Circle().fill(Color.red.opacity(0.6)).frame(width: 7, height: 7)

                Rectangle()
                    .fill(Color(white: 0.1))
                    .frame(width: 1, height: 12)
                    .padding(.horizontal, 2)

                Image(systemName: "terminal.fill")
                    .font(.system(size: 9))
                    .foregroundStyle(Color.red.opacity(0.6))

                Text("console")
                    .font(.system(size: 10, weight: .semibold, design: .monospaced))
                    .foregroundStyle(Color(white: 0.35))

                Spacer()

                if !logs.isEmpty {
                    Text("\(logs.count) lines")
                        .font(.system(size: 9, design: .monospaced))
                        .foregroundStyle(Color(white: 0.25))
                }
            }
            .padding(.horizontal, 14)
            .padding(.vertical, 9)
            .background(Color(white: 0.05))
            .overlay(
                Rectangle()
                    .fill(Color.red.opacity(0.35))
                    .frame(height: 1),
                alignment: .top
            )

            // log lines
            ScrollViewReader { proxy in
                ScrollView {
                    VStack(alignment: .leading, spacing: 4) {
                        if logs.isEmpty {
                            HStack(spacing: 6) {
                                Text(">")
                                    .foregroundStyle(Color.red.opacity(0.4))
                                Text("waiting for action...")
                                    .foregroundStyle(Color(white: 0.25))
                            }
                            .font(.system(size: 11, design: .monospaced))
                        } else {
                            ForEach(Array(logs.enumerated()), id: \.offset) { i, line in
                                HStack(alignment: .top, spacing: 6) {
                                    Text(">")
                                        .foregroundStyle(Color.red.opacity(0.4))
                                    Text(line)
                                        .foregroundStyle(Color(white: 0.55))
                                }
                                .font(.system(size: 11, design: .monospaced))
                                .id(i)
                            }
                        }
                    }
                    .padding(.horizontal, 14)
                    .padding(.vertical, 10)
                    .frame(maxWidth: .infinity, alignment: .leading)
                }
                .onChange(of: logs.count) { _ in
                    if let last = logs.indices.last {
                        proxy.scrollTo(last, anchor: .bottom)
                    }
                }
            }
            .frame(height: 115)
            .background(Color(white: 0.03))
        }
    }
}

// MARK: - Inject Button Card

struct InjectButtonCard: View {
    let button: InjectButton
    let result: InjectResult?
    let isWorking: Bool
    let progress: Double
    let onTap: () -> Void

    @State private var pressed = false

    var isSuccess: Bool {
        if case .success = result { return true }
        return false
    }

    var isFailed: Bool {
        if case .failed = result { return true }
        return false
    }

    var failedMessage: String? {
        if case .failed(let msg) = result { return msg }
        return nil
    }

    var body: some View {
        Button(action: onTap) {
            VStack(spacing: 0) {
                // main row
                HStack(spacing: 12) {
                    // left icon
                    ZStack {
                        RoundedRectangle(cornerRadius: 8, style: .continuous)
                            .fill(iconBg)
                            .frame(width: 36, height: 36)
                        Image(systemName: iconName)
                            .font(.system(size: 14, weight: .semibold))
                            .foregroundStyle(iconColor)
                    }

                    // name + category
                    VStack(alignment: .leading, spacing: 3) {
                        Text(button.name)
                            .font(.system(size: 14, weight: .bold))
                            .foregroundStyle(.white)
                        Text(button.category)
                            .font(.system(size: 10, weight: .semibold))
                            .foregroundStyle(Color(white: 0.35))
                            .kerning(1)
                    }

                    Spacer()

                    // right status
                    statusBadge
                }
                .padding(.horizontal, 14)
                .padding(.vertical, 13)

                // progress bar
                if isWorking {
                    GeometryReader { geo in
                        ZStack(alignment: .leading) {
                            Rectangle()
                                .fill(Color(white: 0.07))
                            Rectangle()
                                .fill(
                                    LinearGradient(
                                        colors: [Color.red.opacity(0.5), Color.red],
                                        startPoint: .leading,
                                        endPoint: .trailing
                                    )
                                )
                                .frame(width: geo.size.width * progress)
                                .animation(.linear(duration: 0.05), value: progress)
                        }
                    }
                    .frame(height: 2)
                }

                // error message
                if let msg = failedMessage {
                    HStack(spacing: 6) {
                        Image(systemName: "exclamationmark.circle")
                            .font(.system(size: 10))
                            .foregroundStyle(.red)
                        Text(msg)
                            .font(.system(size: 10, design: .monospaced))
                            .foregroundStyle(Color.red.opacity(0.75))
                            .lineLimit(1)
                        Spacer()
                    }
                    .padding(.horizontal, 14)
                    .padding(.bottom, 10)
                }
            }
            .background(cardBg)
            .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: 14, style: .continuous)
                    .stroke(borderColor, lineWidth: 1)
            )
            .shadow(
                color: isWorking ? Color.red.opacity(0.12) : Color.clear,
                radius: 10, x: 0, y: 4
            )
        }
        .buttonStyle(.plain)
        .disabled(isWorking)
        .scaleEffect(pressed ? 0.97 : 1.0)
        .animation(.spring(response: 0.2, dampingFraction: 0.7), value: pressed)
        .simultaneousGesture(
            DragGesture(minimumDistance: 0)
                .onChanged { _ in pressed = true }
                .onEnded { _ in pressed = false }
        )
    }

    private var iconName: String {
        if isWorking { return "arrow.triangle.2.circlepath" }
        if isSuccess { return "checkmark" }
        if isFailed  { return "xmark" }
        return "bolt.fill"
    }

    private var iconColor: Color {
        if isSuccess { return .green }
        if isFailed  { return .red }
        return .red
    }

    private var iconBg: Color {
        if isSuccess { return Color.green.opacity(0.12) }
        if isFailed  { return Color.red.opacity(0.15) }
        if isWorking { return Color.red.opacity(0.12) }
        return Color(white: 0.08)
    }

    private var cardBg: some View {
        Group {
            if isSuccess {
                LinearGradient(
                    colors: [Color(white: 0.07), Color.green.opacity(0.06)],
                    startPoint: .topLeading, endPoint: .bottomTrailing
                )
            } else if isWorking {
                LinearGradient(
                    colors: [Color(white: 0.08), Color.red.opacity(0.05)],
                    startPoint: .topLeading, endPoint: .bottomTrailing
                )
            } else {
                LinearGradient(
                    colors: [Color(white: 0.08), Color(white: 0.05)],
                    startPoint: .topLeading, endPoint: .bottomTrailing
                )
            }
        }
    }

    private var borderColor: Color {
        if isSuccess { return Color.green.opacity(0.3) }
        if isFailed  { return Color.red.opacity(0.35) }
        if isWorking { return Color.red.opacity(0.45) }
        return Color(white: 0.12)
    }

    @ViewBuilder
    private var statusBadge: some View {
        if isWorking {
            HStack(spacing: 5) {
                Text("\(Int(progress * 100))%")
                    .font(.system(size: 11, weight: .bold, design: .monospaced))
                    .foregroundStyle(.red)
                ProgressView()
                    .progressViewStyle(.circular)
                    .scaleEffect(0.55)
                    .tint(.red)
            }
        } else if isSuccess {
            HStack(spacing: 4) {
                Image(systemName: "checkmark.circle.fill")
                    .foregroundStyle(.green)
                    .font(.system(size: 13))
                Text("DONE")
                    .font(.system(size: 10, weight: .bold))
                    .foregroundStyle(.green)
                    .kerning(0.5)
            }
        } else if isFailed {
            HStack(spacing: 4) {
                Image(systemName: "xmark.circle.fill")
                    .foregroundStyle(.red)
                    .font(.system(size: 13))
                Text("FAIL")
                    .font(.system(size: 10, weight: .bold))
                    .foregroundStyle(.red)
                    .kerning(0.5)
            }
        } else {
            HStack(spacing: 4) {
                Image(systemName: "play.fill")
                    .font(.system(size: 9))
                    .foregroundStyle(Color.red.opacity(0.6))
                Text("TAP")
                    .font(.system(size: 10, weight: .bold))
                    .foregroundStyle(Color(white: 0.35))
                    .kerning(0.5)
            }
        }
    }
}

// MARK: - Open Game Button Card

struct OpenGameButtonCard: View {
    let button: OpenGameButton
    let isWorking: Bool
    let onTap: () -> Void

    @State private var pressed = false

    var body: some View {
        Button(action: onTap) {
            HStack(spacing: 8) {
                Image(systemName: "gamecontroller.fill")
                    .font(.system(size: 11))
                    .foregroundStyle(isWorking ? Color.red : Color(white: 0.5))

                Text(button.name)
                    .font(.system(size: 12, weight: .bold))
                    .foregroundStyle(.white)
                    .lineLimit(1)

                Spacer()

                if isWorking {
                    ProgressView()
                        .progressViewStyle(.circular)
                        .scaleEffect(0.6)
                        .tint(.red)
                } else {
                    Image(systemName: "chevron.right")
                        .font(.system(size: 9, weight: .semibold))
                        .foregroundStyle(Color.red.opacity(0.6))
                }
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 9)
            .background(
                ZStack {
                    RoundedRectangle(cornerRadius: 10, style: .continuous)
                        .fill(isWorking
                              ? Color.red.opacity(0.10)
                              : Color(white: 0.07))
                    RoundedRectangle(cornerRadius: 10, style: .continuous)
                        .stroke(isWorking
                                ? Color.red.opacity(0.4)
                                : Color(white: 0.12),
                                lineWidth: 1)
                }
            )
        }
        .buttonStyle(.plain)
        .disabled(isWorking)
        .frame(maxWidth: .infinity, minHeight: 38, maxHeight: 38)
        .scaleEffect(pressed ? 0.96 : 1.0)
        .animation(.spring(response: 0.2, dampingFraction: 0.7), value: pressed)
        .simultaneousGesture(
            DragGesture(minimumDistance: 0)
                .onChanged { _ in pressed = true }
                .onEnded { _ in pressed = false }
        )
    }
}
