//
//  ContentView.swift
//  DarkModeWallpaper
//
//  Created by 严天龙 on 2024/8/31.
//

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
    //@State private var timer: Timer?
    @State private var interval: TimeInterval = 1800 // 默认间隔时间为 30分钟
    @State private var timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()
    @State private var countNum: Int = 1800
    @Environment(\.colorScheme) var colorScheme
    
    
    
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
                            LightModefloderURL = url
                            LightModeimageURLs = getImagesFromFolder(url: url)
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
                            DarkModefloderURL = url
                            DarkModeimageURLs = getImagesFromFolder(url: url)
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
            
            Text("\(countNum) seconds left to change the wallpaper")
                .onReceive(timer) { input in
                    if countNum > 0{
                        countNum -= 1
                    } else if countNum == 0{
                        countNum = Int(interval)
                        if colorScheme == .dark{
                            setRandomDesktopImage(from: DarkModeimageURLs)
                        }else {
                            setRandomDesktopImage(from: LightModeimageURLs)
                        }
                        
                    }
                }
            
            Button(action: {
                countNum = 0 // 将 countNum 归零
            }) {
                Text("Reset Timer")
            }
        }.padding()
        
    }
    
    func getImagesFromFolder(url: URL) -> [URL] {
        let openPanel = NSOpenPanel()
        openPanel.canChooseFiles = false
        openPanel.canChooseDirectories = true
        openPanel.allowsMultipleSelection = false
        openPanel.directoryURL = url
        openPanel.message = "Please grant access to this folder to select a wallpaper."

        if openPanel.runModal() == .OK {
            if let selectedURL = openPanel.url {
                do {
                    let fileURLs = try FileManager.default.contentsOfDirectory(at: selectedURL, includingPropertiesForKeys: nil)
                    return fileURLs.filter { $0.pathExtension.lowercased() == "jpg" || $0.pathExtension.lowercased() == "jpeg" || $0.pathExtension.lowercased() == "png" || $0.pathExtension.lowercased() == "tiff" }
                } catch {
                    print(error)
                }
            }
        }
        return []
    }
    
    func setRandomDesktopImage(from imageURLs: [URL]) {
        if let randomImageURL = imageURLs.randomElement() {
            setDesktopImage(url: randomImageURL)
        }
    }
    
    func setDesktopImage(url: URL) {
        do {
            if let screen = NSScreen.main {
                try NSWorkspace.shared.setDesktopImageURL(url, for: screen, options: [:])
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
