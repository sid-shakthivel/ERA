//
//  Menu.swift
//  ERA
//
//  Created by Siddharth Shakthivel Muthu Pandian on 23/10/2022.
//

import SwiftUI

struct Menu: View {
    @Environment(\.presentationMode) var presentationMode
    
    @EnvironmentObject var canvasSettings: CanvasSettings
    @EnvironmentObject var userSettings: UserPreferences
    
    @Binding var showDocumentCameraView: Bool
    @Binding var showFileImporter: Bool
    @Binding var showDictionary: Bool
    @Binding var showMenu: Bool
    
    var body: some View {
        Group {
           VStack {
               Button {
                   showDocumentCameraView.toggle()
               } label: {
                   HStack {
                       Image("scan")
                       
                       Text("Scan Document")
                           .if(userSettings.isDarkMode) { view in
                               view
                                   .foregroundColor(.white)
                           }
                           .if(!userSettings.isDarkMode) { view in
                               view
                                   .foregroundColor(.black)
                           }
                           .textCase(.uppercase)
                           .fontWeight(.semibold)
                           .font(.system(size: 14))
                       
                       Image("arrow-right")
                           .frame(maxWidth: .infinity, alignment: .trailing)
                   }
                   .padding()
               }
                .frame(maxWidth: .infinity, alignment: .leading)
               
               Divider()
                   .padding(.horizontal, 30)
               
               Button {
                   showMenu = false
                   DispatchQueue.main.asyncAfter(deadline: .now() + 0.25) {
                       showFileImporter.toggle()
                   }
               } label: {
                   HStack {
                       Image("upload")
                       
                       Text("Upload Document")
                           .if(userSettings.isDarkMode) { view in
                               view
                                   .foregroundColor(.white)
                           }
                           .if(!userSettings.isDarkMode) { view in
                               view
                                   .foregroundColor(.black)
                           }
                           .fontWeight(.semibold)
                           .textCase(.uppercase)
                           .font(.system(size: 14))
                       
                       Image("arrow-right")
                           .frame(maxWidth: .infinity, alignment: .trailing)
                   }
                       .padding()
               }
                   .frame(maxWidth: .infinity, alignment: .leading)
               
               Divider()
                   .padding(.horizontal, 30)
               
               Button {
                   showMenu = false
                   DispatchQueue.main.asyncAfter(deadline: .now() + 0.25) {
                       showDictionary.toggle()
                   }
               } label: {
                   HStack {
                       Image("book")
                       
                       Text("Dictionary")
                           .if(userSettings.isDarkMode) { view in
                               view
                                   .foregroundColor(.white)
                           }
                           .if(!userSettings.isDarkMode) { view in
                               view
                                   .foregroundColor(.black)
                           }
                           .textCase(.uppercase)
                           .fontWeight(.semibold)
                           .font(.system(size: 14))
                       
                       Image("arrow-right")
                           .frame(maxWidth: .infinity, alignment: .trailing)
                   }
                   .padding()
               }
               .frame(maxWidth: .infinity, alignment: .leading)
           }
       }
            .if(userSettings.isDarkMode) { view in
                view
                    .background(ColourConstants.darkModeBackground)
            }
            .if(!userSettings.isDarkMode) { view in
                view
                    .background(ColourConstants.lightModeLighter)
            }
    }
}

struct optionView_Previews: PreviewProvider {
    static var previews: some View {
        Menu(showDocumentCameraView: .constant(false), showFileImporter: .constant(false), showDictionary: .constant(false), showMenu: .constant(false))
    }
}
