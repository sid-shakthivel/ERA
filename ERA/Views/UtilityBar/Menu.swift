//
//  Menu.swift
//  ERA
//
//  Created by Siddharth Shakthivel Muthu Pandian on 23/10/2022.
//

import SwiftUI

struct Menu: View {
    @Environment(\.presentationMode) var presentationMode
    
    @EnvironmentObject var userSettings: UserPreferences
    
    @Binding var showDocumentCameraView: Bool
    @Binding var showFileImporter: Bool
    @Binding var showDictionary: Bool
    @Binding var showMenu: Bool
    
    @Binding var fileStatus: FileStatus
    
    var body: some View {
        Group {
           VStack {
               Button {
                   showMenu = false
                   DispatchQueue.main.asyncAfter(deadline: .now() + 0.25) {
                       showDocumentCameraView.toggle()
                   }
               } label: {
                   HStack {
                       Image("scan-document")
                           .invertOnDarkTheme()
                       
                       Text("Scan Document")
                           .foregroundColor(.black)
                           .invertOnDarkTheme()
                           .textCase(.uppercase)
                           .font(.system(size: 14, weight: .semibold))
                       
                       Image("arrow-right")
                           .invertOnDarkTheme()
                           .frame(maxWidth: .infinity, alignment: .trailing)
                   }
                   .padding()
               }
                    .frame(maxWidth: .infinity, alignment: .leading)
               
               Divider()
                   .padding(.horizontal, 30)
               
               Button {
                   fileStatus = .Loading
                   showMenu = false
                   DispatchQueue.main.asyncAfter(deadline: .now() + 0.25) {
                       showFileImporter.toggle()
                   }
               } label: {
                   HStack {
                       Image("upload-pdf")
                           .invertOnDarkTheme()
                       
                       Text("Upload Document")
                           .foregroundColor(.black)
                           .invertOnDarkTheme()
                           .textCase(.uppercase)
                           .font(.system(size: 14, weight: .semibold))
                       
                       Image("arrow-right")
                           .invertOnDarkTheme()
                           .frame(maxWidth: .infinity, alignment: .trailing)
                   }
                       .padding()
               }
                   .frame(maxWidth: .infinity, alignment: .leading)
               
               Divider()
                   .padding(.horizontal, 30)
               
               Button {
                   fileStatus = .Loading
                   showMenu = false
                   DispatchQueue.main.asyncAfter(deadline: .now() + 0.25) {
                       showDictionary.toggle()
                   }
               } label: {
                   HStack {
                       Image("dictionary")
                           .invertOnDarkTheme()
                       
                       Text("Dictionary")
                           .foregroundColor(.black)
                           .invertOnDarkTheme()
                           .textCase(.uppercase)
                           .font(.system(size: 14, weight: .semibold))
                       
                       Image("arrow-right")
                           .invertOnDarkTheme()
                           .frame(maxWidth: .infinity, alignment: .trailing)
                   }
                   .padding()
               }
               .frame(maxWidth: .infinity, alignment: .leading)
           }
       }
            .frame(maxHeight: .infinity)
            .invertBackgroundOnDarkTheme(isBase: true)
    }
}
