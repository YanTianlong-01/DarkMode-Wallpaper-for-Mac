//
//  DarkModeWallpaperApp.swift
//  DarkModeWallpaper
//
//  Created by 严天龙 on 2024/8/31.
//



import SwiftUI

@main
struct DarkModeWallpaperApp: App {
    @NSApplicationDelegateAdaptor(AppDelegate.self) var appDelegate

    var body: some Scene {
        WindowGroup {
            MainView()
        }
    }
}

class AppDelegate: NSObject, NSApplicationDelegate {
    var statusItem: NSStatusItem?
    var preferencesWindow: NSWindowController?

    func applicationDidFinishLaunching(_ notification: Notification) {
        statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)
            
        if let button = statusItem?.button {
            button.image = NSImage(systemSymbolName: "sun.horizon", accessibilityDescription: "DarkMode Wallpaper")
            button.action = #selector(statusItemButtonTapped)
            button.target = self
        }

        // 创建菜单
        let menu = NSMenu()
        menu.addItem(NSMenuItem(title: "About DarkMode Wallpaper", action: #selector(openWebsite), keyEquivalent: ""))
        menu.addItem(NSMenuItem(title: "Preference", action: #selector(openPreferences), keyEquivalent: ""))
        menu.addItem(NSMenuItem.separator())
        menu.addItem(NSMenuItem(title: "Quit", action: #selector(quitApp), keyEquivalent: "q"))

        statusItem?.menu = menu
    }

    @objc private func statusItemButtonTapped() {
        // 点击菜单栏图标后触发的动作
    }

    @objc private func openWebsite() {
        if let url = URL(string: "https://github.com/YanTianlong-01/DarkMode-Wallpaper-for-Mac") {
            NSWorkspace.shared.open(url)
        }
    }

    @objc private func openPreferences() {
        if preferencesWindow == nil {
            let contentView = ContentView()
            let hostingController = NSHostingController(rootView: contentView)
            let window = NSWindow(contentViewController: hostingController)
            window.title = "DarkMode Wallpaper"
            window.setContentSize(NSSize(width: 400, height: 400))
            window.styleMask = [.titled, .closable, .resizable, .miniaturizable]
            window.isReleasedWhenClosed = false // 窗口关闭后不会释放，可以重新打开
            
            preferencesWindow = NSWindowController(window: window)
        }

        preferencesWindow?.showWindow(nil)
        NSApp.activate(ignoringOtherApps: true) // 激活应用，使窗口可见
    }

    @objc private func quitApp() {
        NSApplication.shared.terminate(nil)
    }
}









