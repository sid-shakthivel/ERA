//
//  Info.swift
//  ERA
//
//  Created by Siddharth Shakthivel Muthu Pandian on 25/03/2023.
//

import SwiftUI

struct Help: View {
    @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>
    @EnvironmentObject var userSettings: UserPreferences
    
    var body: some View {
        NavigationView {
            VStack {
                HStack {
                    Button {
                        presentationMode.wrappedValue.dismiss()
                    } label: {
                        Image("arrow-left")
                            .resizable()
                            .frame(width: 30, height: 30)
                            .invertOnDarkTheme()

                        Text("Help")
                            .foregroundColor(.black)
                            .invertOnDarkTheme()
                            .font(.system(size: 16, weight: .bold))
                            .textCase(.uppercase)
                    }
                    
                    Spacer()
                }
                .padding(.leading)
                .padding(.trailing)
                
                Divider()
                
                HelpWidgets()
            }
                .navigationBarHidden(true)
                .invertBackgroundOnDarkTheme(isBase: true)
        }
            .navigationBarHidden(true)
            .invertBackgroundOnDarkTheme(isBase: true)
    }
}

struct Help_Previews: PreviewProvider {
    static var previews: some View {
        Help()
    }
}
