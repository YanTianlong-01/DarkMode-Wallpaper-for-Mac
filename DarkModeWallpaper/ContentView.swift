//
//  ContentView.swift
//  DarkModeWallpaper
//
//  Created by 严天龙 on 2024/8/31.
//  v1.0.1 与 v1.0.0 一样

import SwiftUI
import AppKit

struct ContentView: View {
    
    @State private var LightshowFolderPicker = false
    @State private var DarkshowFolderPicker = false
    @State private var DarkModeimageURLs: [URL] = []
    @State private var LightModeimageURLs: [URL] = []
    //@State private var DarkModefloderURL: URL? = nil
    //@State private var LightModefloderURL: URL? = nil
    @State private var imageURLs: [URL] = []
    //@State private var interval: TimeInterval = 1800 // 默认间隔时间为 30分钟
    @State private var timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()
    @State private var countNum: Int = 1800
    @Environment(\.colorScheme) var colorScheme
    //@State private var syncDesktops: Bool = false
    @State private var resetShortcutKey: Character = "r"
    @State private var selectedModifier: ShortcutModifier = .command {
        didSet {
            saveShortcutPreferences()
        }
    }

    // Add custom enum for modifier keys
    enum ShortcutModifier: Int, Hashable {
        case command
        case option
        case shift
        case control
        case commandOption
        case commandShift
        case commandControl
        
        var eventModifiers: EventModifiers {
            switch self {
            case .command:
                return .command
            case .option:
                return .option
            case .shift:
                return .shift
            case .control:
                return .control
            case .commandOption:
                return .command.union(.option)
            case .commandShift:
                return .command.union(.shift)
            case .commandControl:
                return .command.union(.control)
            }
        }
        
        var symbol: String {
            switch self {
            case .command:
                return "⌘"
            case .option:
                return "⌥"
            case .shift:
                return "⇧"
            case .control:
                return "⌃"
            case .commandOption:
                return "⌘⌥"
            case .commandShift:
                return "⌘⇧"
            case .commandControl:
                return "⌘⌃"
            }
        }
    }

    func saveBookmark(for url: URL, key: String) {
        do {
            let bookmarkData = try url.bookmarkData(options: .withSecurityScope, includingResourceValuesForKeys: nil, relativeTo: nil)
            UserDefaults.standard.set(bookmarkData, forKey: key)
        } catch {
            print("Failed to save bookmark: \(error)")
        }
    }


    func restoreBookmark(key: String) -> URL? {
        guard let bookmarkData = UserDefaults.standard.data(forKey: key) else { return nil }
        do {
            var isStale = false
            let url = try URL(resolvingBookmarkData: bookmarkData, options: .withSecurityScope, relativeTo: nil, bookmarkDataIsStale: &isStale)
            if isStale {
                // Bookmark data is stale, you might want to ask the user to choose the folder again
                print("Bookmark is stale")
                return nil
            }
            _ = url.startAccessingSecurityScopedResource()
            return url
        } catch {
            print("Failed to restore bookmark: \(error)")
            return nil
        }
    }

    @State private var LightModeFolderURL: URL? {
        didSet {
            if let url = LightModeFolderURL {
                // UserDefaults.standard.set(url.absoluteString, forKey: "LightModeFolderURL")
                saveBookmark(for: url, key: "LightModeFolderBookmark")
            }
        }
    }
    @State private var DarkModeFolderURL: URL? {
        didSet {
            if let url = DarkModeFolderURL {
                // UserDefaults.standard.set(url.absoluteString, forKey: "DarkModeFolderURL")
                saveBookmark(for: url, key: "DarkModeFolderBookmark")
            }
        }
    }
    @State private var interval: Int = 1800 {
        didSet {
            UserDefaults.standard.set(interval, forKey: "Interval")
        }
    }
    @State private var syncDesktops: Bool  = false {
        didSet {
            UserDefaults.standard.set(syncDesktops, forKey: "SyncDesktops")
        }
    }

    init() {
        if let lightModeURL = restoreBookmark(key: "LightModeFolderBookmark") {
            self._LightModeFolderURL = State(initialValue: lightModeURL)
        }
        if let darkModeURL = restoreBookmark(key: "DarkModeFolderBookmark") {
            self._DarkModeFolderURL = State(initialValue: darkModeURL)
        }
    }
    
    var body: some View {
        HStack{
            Text(colorScheme == .dark ? "Dark Mode" : "Light Mode")
            Image(systemName: colorScheme == .dark ? "sun.horizon.circle.fill" : "sun.horizon.circle")
                .font(.system(size: 24))
        }
        
        // 选择浅色模式文件夹
        VStack{
            HStack{
                VStack{
                    Button("Select Light Mode Folder") {
                        LightshowFolderPicker = true
                    }
                    .fileImporter(isPresented: $LightshowFolderPicker, allowedContentTypes: [.folder], onCompletion: { result in
                        switch result {
                        case .failure(let error):
                            print("Error selecting folder \(error.localizedDescription)")
                        case .success(let url):
                            print("selected light mode folder url = \(url)")
                            
                            let panel = NSOpenPanel()
                            panel.canChooseDirectories = true
                            panel.canChooseFiles = false
                            panel.allowsMultipleSelection = false
                            panel.message = "Please grant access to this folder for Light Mode."
                            if panel.runModal() == .OK {
                                if let url = panel.url {
                                    // 这里可以处理选择的文件夹
                                    LightModeFolderURL = url
                                    print("Selected folder: \(url)")
                                }
                            }
                            //LightModefloderURL = url
                        }
                    })
                    if let url = LightModeFolderURL {
                        Text("\(url.lastPathComponent)")
                    } else {
                        Text("Light Mode Folder Not Selected")
                    }
                }
                Image(systemName: "sun.horizon.circle")
                    .font(.system(size: 24))
            }
        }.padding()
        
        
        // 选择深色模式文件夹
        VStack{
            HStack{
                VStack{
                    Button("Select Dark Mode Folder") {
                        DarkshowFolderPicker = true
                    }
                    .fileImporter(isPresented: $DarkshowFolderPicker, allowedContentTypes: [.folder], onCompletion: { result in
                        switch result {
                        case .failure(let error):
                            print("Error selecting folder \(error.localizedDescription)")
                        case .success(let url):
                            print("selected dark mode folder url = \(url)")
                            let panel = NSOpenPanel()
                            panel.canChooseDirectories = true
                            panel.canChooseFiles = false
                            panel.allowsMultipleSelection = false
                            panel.message = "Please grant access to this folder for Dark Mode."
                            if panel.runModal() == .OK {
                                if let url = panel.url {
                                    // 这里可以处理选择的文件夹
                                    DarkModeFolderURL = url
                                    print("Selected folder: \(url)")
                                }
                            }
                            //DarkModefloderURL = url
                        }
                    })
                    if let url = DarkModeFolderURL {
                        Text("\(url.lastPathComponent)")
                    } else {
                        Text("Dark Mode Folder Not Selected")
                    }
                }
                Image(systemName: "sun.horizon.circle.fill")
                    .font(.system(size: 24))
            }
        }.padding()
        
        

        VStack{
            // 添加一个 TextField 用于设置时间间隔
            HStack {
                Text("Switch Interval:")
                TextField("Interval", value: $interval, formatter: NumberFormatter())
                    .frame(width: 100)
                // 保存和加载时间间隔
                    .onAppear {
                        if let savedInterval = UserDefaults.standard.value(forKey: "interval") as? Int {
                            interval = savedInterval
                        }
                    }
                    .onChange(of: interval) { newValue in
                        UserDefaults.standard.setValue(newValue, forKey: "interval")
                    }
                Text("seconds")
                    .onReceive(timer) { _ in
                        if countNum > 0{
                            countNum -= 1
                        }else{
                            countNum = interval
                            if colorScheme == .dark{
                                if let url = DarkModeFolderURL{
                                    DarkModeimageURLs = getImagesFromFolder(url: url)
                                    setRandomDesktopImage(from: DarkModeimageURLs)
                                }
                            }else {
                                if let url = LightModeFolderURL{
                                    LightModeimageURLs = getImagesFromFolder(url: url)
                                    setRandomDesktopImage(from: LightModeimageURLs)
                                }
                            }
                            
                        }
                    }
            }
            
            //Text("\(countNum) seconds left to change the wallpaper")
            //Text("")
                
        }.padding()
        
        
            
        VStack {
            Button(action: {
                countNum = 0
            }) {
                Text("Switch Wallpaper")
            }
            .keyboardShortcut(KeyEquivalent(resetShortcutKey), modifiers: selectedModifier.eventModifiers)
            
            HStack {
                Picker("Shortcut", selection: $selectedModifier) {
                    Text(ShortcutModifier.command.symbol).tag(ShortcutModifier.command)
                    Text(ShortcutModifier.option.symbol).tag(ShortcutModifier.option)
                    Text(ShortcutModifier.shift.symbol).tag(ShortcutModifier.shift)
                    Text(ShortcutModifier.control.symbol).tag(ShortcutModifier.control)
                    Text(ShortcutModifier.commandOption.symbol).tag(ShortcutModifier.commandOption)
                    Text(ShortcutModifier.commandShift.symbol).tag(ShortcutModifier.commandShift)
                    Text(ShortcutModifier.commandControl.symbol).tag(ShortcutModifier.commandControl)
                }
                // .labelsHidden() // 隐藏 Picker 默认标签
                .frame(width: 80)

                Text("\(selectedModifier.symbol)")
                TextField("Key", text: Binding(
                    get: { String(resetShortcutKey) },
                    set: { newValue in
                        if let first = newValue.first {
                            resetShortcutKey = first
                            saveShortcutPreferences()
                        }
                    }
                ))
                .frame(width: 50)
                .textFieldStyle(RoundedBorderTextFieldStyle())
            }
        }
        .onAppear {
            if let savedKey = UserDefaults.standard.string(forKey: "ResetShortcutKey")?.first {
                resetShortcutKey = savedKey
            }
            if let savedModifierRaw = UserDefaults.standard.integer(forKey: "ResetShortcutModifier") as Int?,
               let savedModifier = ShortcutModifier(rawValue: savedModifierRaw) {
                selectedModifier = savedModifier
            }
        }
        .padding()
        
        Toggle("Show the same wallpaper on every display", isOn: $syncDesktops)
        .onAppear {
            if let savedsyncDesktops = UserDefaults.standard.value(forKey: "syncDesktops") as? Bool {
                syncDesktops = savedsyncDesktops
            }
        }
        .onChange(of: syncDesktops) { value in
            print("Switch is now \(value ? "on" : "off")")
            UserDefaults.standard.setValue(value, forKey: "syncDesktops")
        }.padding()
        
    
    }
    
    
    func getImagesFromFolder(url: URL) -> [URL] {
        do {
            let fileURLs = try FileManager.default.contentsOfDirectory(at: url, includingPropertiesForKeys: nil)
            return fileURLs.filter { $0.pathExtension.lowercased() == "jpg" || $0.pathExtension.lowercased() == "jpeg" || $0.pathExtension.lowercased() == "png" || $0.pathExtension.lowercased() == "tiff" }
        } catch {
            print(error)
            return [] // 出错时返回空数组
        }
    }
    
    func setRandomDesktopImage(from imageURLs: [URL]) {
        if let randomImageURL = imageURLs.randomElement() {
            setDesktopImage(url: randomImageURL)
        }
    }
    
    func setDesktopImage(url: URL) {
        do {
            if syncDesktops{
                let screens = NSScreen.screens // 获取所有屏幕
                for screen in screens {
                    // print(screen)
                    try NSWorkspace.shared.setDesktopImageURL(url, for: screen, options: [:])
                }
            }else{
                if let screen = NSScreen.main {
                    try NSWorkspace.shared.setDesktopImageURL(url, for: screen, options: [:])
                }
            }
        } catch {
            print("Error setting desktop image: \(error)")
        }
    }
    
    private func saveShortcutPreferences() {
        UserDefaults.standard.set(String(resetShortcutKey), forKey: "ResetShortcutKey")
        UserDefaults.standard.set(selectedModifier.rawValue, forKey: "ResetShortcutModifier")
    }
    
}


//
//#Preview {
//    ContentView()
//}
