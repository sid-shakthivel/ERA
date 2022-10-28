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
    @Binding var showDocumentCameraView: Bool
    @Binding var showFileImporter: Bool
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
                           .foregroundColor(.black)
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
                   // Fix for attempt to present View ... which is already presenting
                   showMenu = false
                   DispatchQueue.main.asyncAfter(deadline: .now() + 0.25) {
                       showFileImporter.toggle()
                   }
               } label: {
                   HStack {
                       Image("upload")
                       
                       Text("Upload Document")
                           .foregroundColor(.black)
                           .fontWeight(.semibold)
                           .textCase(.uppercase)
                           .font(.system(size: 14))
                       
                       Image("arrow-right")
                           .frame(maxWidth: .infinity, alignment: .trailing)
                   }
                       .padding()
               }
                   .frame(maxWidth: .infinity, alignment: .leading)
           }
       }
           .background(Color.white)
    }
}

struct optionView_Previews: PreviewProvider {
    static var previews: some View {
        Menu(showDocumentCameraView: .constant(false), showFileImporter: .constant(false), showMenu: .constant(false))
    }
}
