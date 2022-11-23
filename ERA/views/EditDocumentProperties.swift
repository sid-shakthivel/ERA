//
//  EditDocumentProperties.swift
//  ERA
//
//  Created by Siddharth Shakthivel Muthu Pandian on 20/11/2022.
//

import SwiftUI

struct EditDocumentProperties: View {
    @Environment(\.managedObjectContext) var moc
    @EnvironmentObject var userSettings: UserPreferences
    @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>
    
    @State var document: Document
    @State var title: String
    
    var body: some View {
        VStack {
            VStack(alignment: .leading) {
                Text("Edit Document Properties")
                    .foregroundColor(.black)
                    .invertOnDarkTheme()
                    .fontWeight(.bold)
                    .font(.system(size: 24))
                    .padding()
                
                TextField("\(document.title ?? "")", text: $title)
                    .foregroundColor(.black)
                    .invertOnDarkTheme()
                    .padding(.horizontal)
            }
            
            Spacer()
            
            Button(action: {
                moc.performAndWait {
                    document.title = title
                    try? moc.save()
                }
                presentationMode.wrappedValue.dismiss()
            }, label: {
                Text("Save")
                    .textCase(.uppercase)
                    .foregroundColor(.white)
                    .font(.system(size: 14))
                    .fontWeight(.semibold)
                    .frame(maxWidth: .infinity)
                    .padding()
            })
                .if(userSettings.isDarkMode) { view in
                    view.tint(ColourConstants.darkModeDarker)
                }
                .if(!userSettings.isDarkMode) { view in
                    view.tint(Color(hex: 0x19242D, alpha: 1))
                }
                .frame(maxHeight: .infinity, alignment: .bottomLeading)
                .buttonStyle(.borderedProminent)
                .padding()
        }
            .invertBackgroundOnDarkTheme(isBase: true)
    }
}

//struct EditDocumentProperties_Previews: PreviewProvider {
//    static var previews: some View {
//        EditDocumentProperties()
//    }
//}
