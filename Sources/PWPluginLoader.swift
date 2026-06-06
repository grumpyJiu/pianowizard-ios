import UIKit
import SwiftUI
import Combine

// ============================================================
// PianoWizard iOS Plugin Bridge
// Entry point for the .dylib — loaded by Tweak.xm constructor
// ============================================================

@available(iOS 14.0, *)
@objc(PWPluginBridge)
public class PWPluginBridge: NSObject {

    @objc public static let shared = PWPluginBridge()

    private var overlayManager: PWOverlayManager?
    private var isRunning = false

    @objc public func startPlugin() {
        guard !isRunning else { return }
        isRunning = true

        DispatchQueue.main.async {
            self.overlayManager = PWOverlayManager()
            self.overlayManager?.start()
        }
    }

    @objc public func stopPlugin() {
        isRunning = false
        DispatchQueue.main.async {
            self.overlayManager?.stop()
            self.overlayManager = nil
        }
    }

    @objc public func showMainPanel() {
        overlayManager?.showMainPanel()
    }

    @objc public func hideMainPanel() {
        overlayManager?.hideMainPanel()
    }
}
