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
    @State private var DarkModefloderURL: URL? = nil
    @State private var LightModefloderURL: URL? = nil
    @State private var imageURLs: [URL] = []
    @State private var interval: TimeInterval = 1800 // 默认间隔时间为 30分钟
    @State private var timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()
    @State private var countNum: Int = 1800
    @Environment(\.colorScheme) var colorScheme
    @State private var syncDesktops: Bool = false

    
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
                                    LightModefloderURL = url
                                    print("Selected folder: \(url)")
                                }
                            }
                            //LightModefloderURL = url
                        }
                    })
                    if let url = LightModefloderURL {
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
                                    DarkModefloderURL = url
                                    print("Selected folder: \(url)")
                                }
                            }
                            //DarkModefloderURL = url
                        }
                    })
                    if let url = DarkModefloderURL {
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
                Text("Change Interval:")
                TextField("Interval", value: $interval, formatter: NumberFormatter())
                    .frame(width: 100)
                Text("seconds")
            }
            
            //Text("\(countNum) seconds left to change the wallpaper")
            Text("seconds left to change the wallpaper")
                .onReceive(timer) { _ in
                    if countNum > 0{
                        countNum -= 1
                    }else{
                        countNum = Int(interval)
                        if colorScheme == .dark{
                            if let url = DarkModefloderURL{
                                DarkModeimageURLs = getImagesFromFolder(url: url)
                                setRandomDesktopImage(from: DarkModeimageURLs)
                            }
                        }else {
                            if let url = LightModefloderURL{
                                LightModeimageURLs = getImagesFromFolder(url: url)
                                setRandomDesktopImage(from: LightModeimageURLs)
                            }
                        }
                        
                    }
                }
            
            Button(action: {
                countNum = 0 // 将 countNum 归零
            }) {
                Text("Reset Timer")
            }
        }.padding()
        
        Toggle("Show the same wallpaper on every display", isOn: $syncDesktops)
        .onChange(of: syncDesktops) { value in
            // 在这里处理开关状态改变
            print("Switch is now \(value ? "on" : "off")")
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
                    print(screen)
                    try NSWorkspace.shared.setDesktopImageURL(url, for: screen, options: [:])
                }
            }
        } catch {
            print("Error setting desktop image: \(error)")
        }
    }
    
}


//
//#Preview {
//    ContentView()
//}
