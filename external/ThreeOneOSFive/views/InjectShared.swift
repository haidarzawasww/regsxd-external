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

// MARK: - Shared Console View

struct ConsoleView: View {
    let logs: [String]

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            HStack {
                Circle().fill(Color.red).frame(width: 8, height: 8)
                Circle().fill(Color.yellow).frame(width: 8, height: 8)
                Circle().fill(Color.green).frame(width: 8, height: 8)
                Text("console")
                    .font(.system(size: 10, weight: .medium, design: .monospaced))
                    .foregroundStyle(Color(white: 0.4))
                    .padding(.leading, 6)
                Spacer()
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 8)
            .background(Color(white: 0.08))

            ScrollViewReader { proxy in
                ScrollView {
                    VStack(alignment: .leading, spacing: 3) {
                        if logs.isEmpty {
                            Text("> waiting for action...")
                                .font(.system(size: 11, design: .monospaced))
                                .foregroundStyle(Color(white: 0.3))
                        } else {
                            ForEach(Array(logs.enumerated()), id: \.offset) { i, line in
                                Text(line)
                                    .font(.system(size: 11, design: .monospaced))
                                    .foregroundStyle(Color(white: 0.6))
                                    .id(i)
                            }
                        }
                    }
                    .padding(10)
                    .frame(maxWidth: .infinity, alignment: .leading)
                }
                .onChange(of: logs.count) { _ in
                    if let last = logs.indices.last {
                        proxy.scrollTo(last, anchor: .bottom)
                    }
                }
            }
            .frame(height: 110)
            .background(Color(white: 0.04))
        }
        .overlay(
            Rectangle()
                .fill(Color.red.opacity(0.2))
                .frame(height: 1),
            alignment: .top
        )
    }
}

// MARK: - Shared Inject Button Card

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

    var body: some View {
        Button(action: onTap) {
            ZStack {
                RoundedRectangle(cornerRadius: 16, style: .continuous)
                    .fill(
                        LinearGradient(
                            colors: isSuccess
                                ? [Color(white: 0.08), Color.green.opacity(0.08)]
                                : [Color(white: 0.10), Color(white: 0.06)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )

                if isWorking {
                    RoundedRectangle(cornerRadius: 16, style: .continuous)
                        .fill(Color.red.opacity(0.04))
                }

                VStack(spacing: 0) {
                    HStack(spacing: 14) {
                        Text(button.name)
                            .font(.system(size: 16, weight: .bold))
                            .foregroundStyle(.white)

                        Spacer()

                        if isWorking {
                            Text("\(Int(progress * 100))%")
                                .font(.system(size: 12, weight: .bold, design: .monospaced))
                                .foregroundStyle(.red)
                        } else if isSuccess {
                            Image(systemName: "checkmark.circle.fill")
                                .foregroundStyle(.green)
                                .font(.system(size: 16))
                        }
                    }
                    .padding(.horizontal, 16)
                    .padding(.vertical, 14)

                    if isWorking {
                        GeometryReader { geo in
                            ZStack(alignment: .leading) {
                                Rectangle()
                                    .fill(Color(white: 0.08))
                                    .frame(height: 3)
                                Rectangle()
                                    .fill(
                                        LinearGradient(
                                            colors: [Color.red.opacity(0.6), Color.red],
                                            startPoint: .leading,
                                            endPoint: .trailing
                                        )
                                    )
                                    .frame(width: geo.size.width * progress, height: 3)
                                    .animation(.linear(duration: 0.05), value: progress)
                            }
                        }
                        .frame(height: 3)
                    }
                }
            }
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
        .overlay(
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .stroke(
                    isSuccess ? Color.green.opacity(0.3)
                    : isWorking ? Color.red.opacity(0.4)
                    : Color(white: 0.13),
                    lineWidth: 1
                )
        )
        .shadow(
            color: isWorking ? Color.red.opacity(0.15) : Color.clear,
            radius: 12, x: 0, y: 4
        )
    }
}

// MARK: - Shared Open Game Button Card

struct OpenGameButtonCard: View {
    let button: OpenGameButton
    let isWorking: Bool
    let onTap: () -> Void

    @State private var pressed = false

    var body: some View {
        Button(action: onTap) {
            ZStack {
                RoundedRectangle(cornerRadius: 10, style: .continuous)
                    .fill(
                        LinearGradient(
                            colors: isWorking
                                ? [Color.red.opacity(0.18), Color(white: 0.08)]
                                : [Color(white: 0.12), Color(white: 0.07)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )

                HStack(spacing: 6) {
                    Image(systemName: "gamecontroller.fill")
                        .font(.system(size: 11))
                        .foregroundStyle(isWorking ? Color.red : Color.white.opacity(0.6))

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
                        Image(systemName: "play.fill")
                            .font(.system(size: 9))
                            .foregroundStyle(.red.opacity(0.8))
                    }
                }
                .padding(.horizontal, 10)
                .padding(.vertical, 8)
            }
        }
        .buttonStyle(.plain)
        .disabled(isWorking)
        .frame(maxWidth: .infinity, minHeight: 36, maxHeight: 36)
        .scaleEffect(pressed ? 0.96 : 1.0)
        .animation(.spring(response: 0.2, dampingFraction: 0.7), value: pressed)
        .simultaneousGesture(
            DragGesture(minimumDistance: 0)
                .onChanged { _ in pressed = true }
                .onEnded { _ in pressed = false }
        )
        .overlay(
            RoundedRectangle(cornerRadius: 10, style: .continuous)
                .stroke(
                    isWorking ? Color.red.opacity(0.5) : Color(white: 0.15),
                    lineWidth: 1
                )
        )
    }
}
