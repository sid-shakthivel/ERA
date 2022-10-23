//
//  optionView.swift
//  BionicReading
//
//  Created by Siddharth Shakthivel Muthu Pandian on 23/10/2022.
//

import SwiftUI

struct optionView: View {
    @EnvironmentObject var canvasSettings: CanvasSettings
    @Binding var showDocumentCameraView: Bool
    @Binding var showFileImporter: Bool
    
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
                   showFileImporter.toggle()
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
        optionView(showDocumentCameraView: .constant(false), showFileImporter: .constant(false))
    }
}
