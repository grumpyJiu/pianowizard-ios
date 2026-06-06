import UIKit
import SwiftUI

// ============================================================
// PianoWizard Overlay Manager
// Manages all floating windows injected into SpringBoard
// Uses UIWindow + UIHostingController for each panel
// ============================================================

@available(iOS 14.0, *)
public class PWOverlayManager: NSObject {

    // ── Windows ──────────────────────────────────────────
    private var floatingBallWindow: UIWindow?
    private var mainPanelWindow: UIWindow?
    private var settingsPanelWindow: UIWindow?
    private var playerWindow: UIWindow?
    private var cardInfoWindow: UIWindow?
    private var backupPanelWindow: UIWindow?

    // ── State ────────────────────────────────────────────
    private let state = PWAppState.shared
    private var cancellables = Set<AnyCancellable>()

    // ── Start / Stop ─────────────────────────────────────
    public func start() {
        showFloatingBall()
        setupNetworkLoading()
    }

    public func stop() {
        removeAllWindows()
    }

    // ============================================================
    // MARK: - Floating Ball
    // ============================================================
    private func showFloatingBall() {
        let w = createOverlayWindow(
            size: CGSize(width: 56, height: 56),
            position: .topRight(offset: CGPoint(x: -30, y: 120))
        )
        let ball = PWFloatingBallView(
            onTap: { [weak self] in self?.toggleMainPanel() },
            onDrag: { [weak self] dx, dy in self?.moveWindow(w, dx: dx, dy: dy) }
        )
        w.rootViewController = UIHostingController(rootView: ball)
        w.isHidden = false
        floatingBallWindow = w
    }

    // ============================================================
    // MARK: - Main Panel
    // ============================================================
    public func showMainPanel() {
        removeWindow(&mainPanelWindow)

        let screenSize = UIScreen.main.bounds.size
        let panelSize = CGSize(
            width: screenSize.width * 0.92,
            height: screenSize.height * 0.58
        )
        let w = createOverlayWindow(size: panelSize, position: .center)
        let panel = PWMainPanelView(
            onClose: { [weak self] in self?.hideMainPanel() },
            onDrag: { [weak self] dx, dy in self?.moveWindow(w, dx: dx, dy: dy) }
        )
        w.rootViewController = UIHostingController(rootView: panel)
        w.isHidden = false
        mainPanelWindow = w
    }

    public func hideMainPanel() {
        removeWindow(&mainPanelWindow)
        removeWindow(&settingsPanelWindow)
    }

    private func toggleMainPanel() {
        if mainPanelWindow != nil {
            hideMainPanel()
        } else {
            showMainPanel()
        }
    }

    // ============================================================
    // MARK: - Settings Panel
    // ============================================================
    public func showSettings() {
        removeWindow(&settingsPanelWindow)
        let screenSize = UIScreen.main.bounds.size
        let size = CGSize(
            width: screenSize.width * 0.86,
            height: screenSize.height * 0.68
        )
        let w = createOverlayWindow(size: size, position: .center)
        let panel = PWSettingsView(
            onClose: { [weak self] in
                self?.removeWindow(&self?.settingsPanelWindow)
            },
            onDrag: { [weak self] dx, dy in self?.moveWindow(w, dx: dx, dy: dy) }
        )
        w.rootViewController = UIHostingController(rootView: panel)
        w.isHidden = false
        settingsPanelWindow = w
    }

    // ============================================================
    // MARK: - Player
    // ============================================================
    public func showPlayer(songName: String) {
        removeWindow(&playerWindow)
        let screenSize = UIScreen.main.bounds.size
        let size = CGSize(
            width: screenSize.width * 0.88,
            height: 130
        )
        let w = createOverlayWindow(size: size, position: .bottomCenter)
        let player = PWPlayerView(
            onClose: { [weak self] in
                self?.removeWindow(&self?.playerWindow)
            },
            onDrag: { [weak self] dx, dy in self?.moveWindow(w, dx: dx, dy: dy) }
        )
        w.rootViewController = UIHostingController(rootView: player)
        w.isHidden = false
        playerWindow = w
    }

    // ============================================================
    // MARK: - Card Info Panel
    // ============================================================
    public func showCardInfo() {
        removeWindow(&cardInfoWindow)
        let w = createOverlayWindow(
            size: CGSize(width: 320, height: 260),
            position: .center
        )
        let panel = PWCardInfoView(
            onClose: { [weak self] in self?.removeWindow(&self?.cardInfoWindow) },
            onDrag: { [weak self] dx, dy in self?.moveWindow(w, dx: dx, dy: dy) }
        )
        w.rootViewController = UIHostingController(rootView: panel)
        w.isHidden = false
        cardInfoWindow = w
    }

    // ============================================================
    // MARK: - Window Management
    // ============================================================
    private enum WindowPosition {
        case center
        case topRight(offset: CGPoint)
        case bottomCenter
    }

    private func createOverlayWindow(size: CGSize, position: WindowPosition) -> UIWindow {
        // Use highest window level to float above everything
        let windowLevel = UIWindow.Level.statusBar + 100

        let w: UIWindow
        if #available(iOS 13.0, *) {
            let scene = UIApplication.shared.connectedScenes.first as? UIWindowScene
            w = UIWindow(windowScene: scene!)
        } else {
            w = UIWindow(frame: UIScreen.main.bounds)
        }

        w.windowLevel = windowLevel
        w.backgroundColor = .clear
        w.isOpaque = false
        w.clipsToBounds = false

        // Position
        let screenBounds = UIScreen.main.bounds
        switch position {
        case .center:
            w.frame = CGRect(
                x: (screenBounds.width - size.width) / 2,
                y: (screenBounds.height - size.height) / 2,
                width: size.width,
                height: size.height
            )
        case .topRight(let offset):
            w.frame = CGRect(
                x: screenBounds.width - size.width + offset.x,
                y: offset.y,
                width: size.width,
                height: size.height
            )
        case .bottomCenter:
            w.frame = CGRect(
                x: (screenBounds.width - size.width) / 2,
                y: screenBounds.height - size.height - 100,
                width: size.width,
                height: size.height
            )
        }

        // Add pan gesture for dragging
        let pan = UIPanGestureRecognizer(target: self, action: #selector(handlePan(_:)))
        w.addGestureRecognizer(pan)

        return w
    }

    @objc private func handlePan(_ gesture: UIPanGestureRecognizer) {
        guard let window = gesture.view as? UIWindow else { return }
        let translation = gesture.translation(in: window)
        window.frame.origin.x += translation.x
        window.frame.origin.y += translation.y
        gesture.setTranslation(.zero, in: window)
    }

    private func moveWindow(_ window: UIWindow?, dx: CGFloat, dy: CGFloat) {
        guard let w = window else { return }
        w.frame.origin.x += dx
        w.frame.origin.y += dy
    }

    private func removeWindow(_ window: inout UIWindow?) {
        window?.isHidden = true
        window?.resignKey()
        window = nil
    }

    private func removeAllWindows() {
        removeWindow(&floatingBallWindow)
        removeWindow(&mainPanelWindow)
        removeWindow(&settingsPanelWindow)
        removeWindow(&playerWindow)
        removeWindow(&cardInfoWindow)
        removeWindow(&backupPanelWindow)
        cancellables.removeAll()
    }

    // ============================================================
    // MARK: - Network Loading
    // ============================================================
    private func setupNetworkLoading() {
        Task {
            let songs = await PWNetworkClient.shared.fetchSongList()
            await MainActor.run {
                PWAppState.shared.serverSongs = songs
            }
        }
    }
}
