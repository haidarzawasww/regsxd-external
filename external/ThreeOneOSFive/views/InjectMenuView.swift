import SwiftUI

// MARK: - Target Game Enum

enum TargetGame: String, CaseIterable, Identifiable {
    case freefireTH = "com.dts.freefireth"
    case freefireMax = "com.dts.freefiremax"

    var id: String { rawValue }

    var displayName: String {
        switch self {
        case .freefireTH:  return "Free Fire"
        case .freefireMax: return "Free Fire MAX"
        }
    }

    var shortTag: String {
        switch self {
        case .freefireTH:  return "FF"
        case .freefireMax: return "FFM"
        }
    }

    var accentColor: Color {
        switch self {
        case .freefireTH:  return .red
        case .freefireMax: return Color(red: 1.0, green: 0.45, blue: 0.0)
        }
    }
}

// MARK: - Inject Menu View (AIMBOT)

struct InjectMenuView: View {
    @State private var selectedTarget: TargetGame = .freefireTH
    @State private var results: [UUID: InjectResult] = [:]
    @State private var working: UUID? = nil
    @State private var progress: [UUID: Double] = [:]
    @State private var consoleLogs: [String] = []

    private func buttons(for target: TargetGame) -> [InjectButton] {
        switch target {
        case .freefireTH:
            return [
                InjectButton(
                    name: "AIMNECK",
                    category: "AIMBOT",
                    bundleID: target.rawValue,
                    targetPath: "Documents/contentcache/Compulsory/ios/gameassetbundles/cache_res.CfnFf59sr1SbsqQ6JqTKsEusjKs~3D",
                    resourceFileName: "cache_res.CfnFf59sr1SbsqQ6JqTKsEusjKs~3D",
                    resourceSubfolder: "patches/aimneck risk free fire ori"
                ),
                InjectButton(
                    name: "AIMBODY",
                    category: "AIMBOT",
                    bundleID: target.rawValue,
                    targetPath: "Documents/contentcache/Compulsory/ios/gameassetbundles/cache_res.CfnFf59sr1SbsqQ6JqTKsEusjKs~3D",
                    resourceFileName: "cache_res.CfnFf59sr1SbsqQ6JqTKsEusjKs~3D",
                    resourceSubfolder: "patches/aimbody risk free fire ori"
                ),
                InjectButton(
                    name: "AIMDRAG PRO SAFE",
                    category: "AIMBOT",
                    bundleID: target.rawValue,
                    targetPath: "Documents/contentcache/Compulsory/ios/gameassetbundles/avatar/assetindexer.H5ak1JM1Eck~2FxRcJrEp~2FMzeuqmY~3D",
                    resourceFileName: "assetindexer.H5ak1JM1Eck~2FxRcJrEp~2FMzeuqmY~3D",
                    resourceSubfolder: "patches/aimdrag pro safe free fire ori"
                ),
            ]
        case .freefireMax:
            return [
                InjectButton(
                    name: "AIMNECK",
                    category: "AIMBOT",
                    bundleID: target.rawValue,
                    targetPath: "Documents/contentcache/Compulsory/ios/gameassetbundles/cache_res.CfnFf59sr1SbsqQ6JqTKsEusjKs~3D",
                    resourceFileName: "cache_res.CfnFf59sr1SbsqQ6JqTKsEusjKs~3D",
                    resourceSubfolder: "patches/aimneck risk free fire max"
                ),
                InjectButton(
                    name: "AIMBODY",
                    category: "AIMBOT",
                    bundleID: target.rawValue,
                    targetPath: "Documents/contentcache/Compulsory/ios/gameassetbundles/cache_res.CfnFf59sr1SbsqQ6JqTKsEusjKs~3D",
                    resourceFileName: "cache_res.CfnFf59sr1SbsqQ6JqTKsEusjKs~3D",
                    resourceSubfolder: "patches/aimbody risk free fire max"
                ),
                InjectButton(
                    name: "AIMDRAG PRO SAFE",
                    category: "AIMBOT",
                    bundleID: target.rawValue,
                    targetPath: "Documents/contentcache/Compulsory/ios/gameassetbundles/avatar/assetindexer.PENojQAQf9a1l6Dzjs0n1Z3rtVU~3D",
                    resourceFileName: "assetindexer.PENojQAQf9a1l6Dzjs0n1Z3rtVU~3D",
                    resourceSubfolder: "patches/aimdrag pro safe free fire max"
                ),
            ]
        }
    }

    private func log(_ msg: String) {
        let ts = DateFormatter.localizedString(from: Date(), dateStyle: .none, timeStyle: .medium)
        DispatchQueue.main.async {
            consoleLogs.append("[\(ts)] \(msg)")
            if consoleLogs.count > 40 { consoleLogs.removeFirst() }
        }
    }

    var body: some View {
        NavigationStack {
            ZStack {
                Color.black.ignoresSafeArea()

                // subtle top glow
                VStack {
                    RadialGradient(
                        colors: [Color.red.opacity(0.12), Color.clear],
                        center: .center,
                        startRadius: 0,
                        endRadius: 220
                    )
                    .frame(height: 220)
                    .offset(y: -40)
                    Spacer()
                }
                .ignoresSafeArea()

                VStack(spacing: 0) {
                    ScrollView {
                        VStack(spacing: 24) {
                            targetSelector
                            aimbotSection
                        }
                        .padding(.top, 20)
                        .padding(.bottom, 16)
                    }

                    ConsoleView(logs: consoleLogs)
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbarBackground(Color.black, for: .navigationBar)
            .toolbarBackground(.visible, for: .navigationBar)
            .toolbar {
                ToolbarItem(placement: .principal) {
                    HStack(spacing: 6) {
                        Image(systemName: "scope")
                            .font(.system(size: 12, weight: .bold))
                            .foregroundStyle(.red)
                        Text("AIMBOT")
                            .font(.system(size: 15, weight: .black))
                            .foregroundStyle(.white)
                            .kerning(1.5)
                    }
                }
            }
            .onChange(of: selectedTarget) { _ in
                results = [:]
                working = nil
                progress = [:]
            }
        }
    }

    // MARK: - Target Selector

    private var targetSelector: some View {
        VStack(spacing: 10) {
            // section label
            HStack {
                Rectangle()
                    .fill(Color.red.opacity(0.5))
                    .frame(width: 3, height: 12)
                    .clipShape(Capsule())
                Text("TARGET")
                    .font(.system(size: 10, weight: .black))
                    .foregroundStyle(Color(white: 0.45))
                    .kerning(2)
                Spacer()
            }
            .padding(.horizontal, 16)

            // selector pills
            HStack(spacing: 8) {
                ForEach(TargetGame.allCases) { target in
                    Button {
                        withAnimation(.spring(response: 0.3, dampingFraction: 0.75)) {
                            selectedTarget = target
                        }
                    } label: {
                        VStack(spacing: 4) {
                            Text(target.shortTag)
                                .font(.system(size: 11, weight: .black))
                                .foregroundStyle(selectedTarget == target ? target.accentColor : Color(white: 0.3))
                                .kerning(1)
                            Text(target.displayName)
                                .font(.system(size: 13, weight: .semibold))
                                .foregroundStyle(selectedTarget == target ? .white : Color(white: 0.4))
                                .lineLimit(1)
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 12)
                        .background(
                            ZStack {
                                RoundedRectangle(cornerRadius: 12, style: .continuous)
                                    .fill(selectedTarget == target
                                          ? target.accentColor.opacity(0.10)
                                          : Color(white: 0.06))
                                if selectedTarget == target {
                                    RoundedRectangle(cornerRadius: 12, style: .continuous)
                                        .stroke(target.accentColor.opacity(0.55), lineWidth: 1)
                                } else {
                                    RoundedRectangle(cornerRadius: 12, style: .continuous)
                                        .stroke(Color(white: 0.10), lineWidth: 1)
                                }
                            }
                        )
                    }
                    .buttonStyle(.plain)
                }
            }
            .padding(.horizontal, 16)

            // bundle id badge
            HStack(spacing: 5) {
                Image(systemName: "app.badge")
                    .font(.system(size: 9))
                    .foregroundStyle(selectedTarget.accentColor.opacity(0.7))
                Text(selectedTarget.rawValue)
                    .font(.system(size: 9, weight: .medium, design: .monospaced))
                    .foregroundStyle(Color(white: 0.3))
            }
            .padding(.horizontal, 16)
        }
    }

    // MARK: - Aimbot Section

    private var aimbotSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            // section header
            HStack(spacing: 8) {
                Rectangle()
                    .fill(Color.red.opacity(0.5))
                    .frame(width: 3, height: 12)
                    .clipShape(Capsule())
                Text("AIMBOT")
                    .font(.system(size: 10, weight: .black))
                    .foregroundStyle(Color.red.opacity(0.85))
                    .kerning(2)
                Rectangle()
                    .fill(Color.red.opacity(0.15))
                    .frame(height: 1)
            }
            .padding(.horizontal, 16)

            VStack(spacing: 10) {
                ForEach(buttons(for: selectedTarget)) { button in
                    InjectButtonCard(
                        button: button,
                        result: results[button.id],
                        isWorking: working == button.id,
                        progress: progress[button.id] ?? 0
                    ) {
                        inject(button)
                    }
                }
            }
            .padding(.horizontal, 16)
        }
    }

    // MARK: - Inject Logic

    private func inject(_ button: InjectButton) {
        guard working != button.id else { return }

        let resourceURL: URL? = {
            let bundleBase = URL(fileURLWithPath: Bundle.main.bundlePath)
            let subfolderPath = bundleBase
                .appendingPathComponent(button.resourceSubfolder)
                .appendingPathComponent(button.resourceFileName)
            if FileManager.default.fileExists(atPath: subfolderPath.path) {
                return subfolderPath
            }
            let rootPath = bundleBase.appendingPathComponent(button.resourceFileName)
            return FileManager.default.fileExists(atPath: rootPath.path) ? rootPath : nil
        }()

        guard let resourceURL else {
            results[button.id] = .failed("File not found in bundle")
            log("\(button.name) [\(selectedTarget.shortTag)] — inject error: file not found")
            return
        }

        working = button.id
        results[button.id] = .working
        progress[button.id] = 0

        let id = button.id
        let tag = selectedTarget.shortTag
        let startTime = Date()
        let duration: Double = 5.0

        Timer.scheduledTimer(withTimeInterval: 0.05, repeats: true) { timer in
            let elapsed = Date().timeIntervalSince(startTime)
            let pct = min(elapsed / duration, 1.0)
            DispatchQueue.main.async { progress[id] = pct }
            if pct >= 1.0 { timer.invalidate() }
        }

        Task.detached(priority: .userInitiated) {
            try? await Task.sleep(nanoseconds: 5_000_000_000)
            do {
                let containerURL = try resolveContainer(bundleID: button.bundleID)
                let targetURL = containerURL.appendingPathComponent(button.targetPath)
                let dir = targetURL.deletingLastPathComponent()
                try FileManager.default.createDirectory(at: dir, withIntermediateDirectories: true)
                let data = try Data(contentsOf: resourceURL)
                let staging = dir.appendingPathComponent(".regsxd-inject-\(UUID().uuidString)")
                try data.write(to: staging, options: .atomic)
                let renameResult = rename(staging.path, targetURL.path)
                if renameResult != 0 {
                    let errMsg = String(cString: strerror(errno))
                    try? FileManager.default.removeItem(at: staging)
                    throw InjectError.renameFailed(errMsg)
                }
                await MainActor.run {
                    results[button.id] = .success
                    progress[button.id] = 1.0
                    working = nil
                    log("\(button.name) [\(tag)] — apply success")
                }
            } catch {
                await MainActor.run {
                    results[button.id] = .failed(error.localizedDescription)
                    working = nil
                    log("\(button.name) [\(tag)] — inject error: \(error.localizedDescription)")
                }
            }
        }
    }
}
