//
//  MainView.swift
//  DarkModeWallpaper
//
//  Created by 严天龙 on 2024/8/31.
//

import SwiftUI
import AppKit

struct MainView: View {
    @Environment(\.colorScheme) var colorScheme
    
    var body: some View {
        Text("DarkMode Wallpaper")
            .font(.largeTitle).padding(50)

        
        HStack{
            Text("在顶部菜单栏中点击")
            Image(systemName: "sun.horizon")
                .font(.system(size: 20))
            Text("图标进行设置")
        }.padding(10)
        
        HStack{
            Text("Click the")
            Image(systemName: "sun.horizon")
                .font(.system(size: 20))
            Text("icon in the top menu bar to access the settings")
        }.padding(10)
    }
}
