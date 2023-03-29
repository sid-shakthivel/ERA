//
//  DownloadBar.swift
//  ERA
//
//  Created by Siddharth Shakthivel Muthu Pandian on 29/03/2023.
//

import SwiftUI

enum DownloadStatus {
    case Downloading
    case Finished
    case Failure
    case Off
}

struct DownloadBar: View {
    @EnvironmentObject var userSettings: UserPreferences
    
    @Binding var downloadStatus: DownloadStatus
    
    var body: some View {
        switch downloadStatus {
        case .Downloading:
            HStack {
                Spacer()

                Text("Downloading..")
                    .foregroundColor(.black)
                    .invertOnDarkTheme()
                    .font(.system(size: 16, weight: .regular))

                Spacer()

                ProgressView()
                    .progressViewStyle(CircularProgressViewStyle(tint: Color(hex: userSettings.isDarkMode ? 0xf4e0d6 : 0x0B1F29, alpha: 1)))

                Spacer()
            }
        case .Failure:
            Text("Failed")
                .foregroundColor(.black)
                .invertOnDarkTheme()
                .font(.system(size: 16, weight: .regular))
        case .Finished:
            Text("Finished!")
                .foregroundColor(.black)
                .invertOnDarkTheme()
                .font(.system(size: 16, weight: .regular))
        case .Off:
            Text("")
        }
    }
}
