//
//  OnboardView.swift
//  ERA
//
//  Created by Siddharth Shakthivel Muthu Pandian on 27/10/2022.
//

import SwiftUI

struct OnboardingData: Hashable, Identifiable {
    let id: Int
    let backgroundImage: String
    let mainText: String
}

struct OnboardSubView: View {
    var data: OnboardingData
    var id: Int
    
    @EnvironmentObject var userSettings: UserPreferences
    
    var body: some View {
        GeometryReader { geometry in
            VStack() {
                Group {
                    Image(data.backgroundImage)
                        .resizable()
                        .scaledToFit()
                        .padding()
                }
                .frame(height: geometry.size.height / 2)
                
                Spacer()
                
                Text(modifyText(state: .Normal, text: data.mainText))
                    .foregroundColor(Color(hex: 0x000000))
                    .invertOnDarkTheme()
                    .font(.system(size: 24))
                    .multilineTextAlignment(.center)
                    .padding()
                Spacer()
            }
        }
        .invertBackgroundOnDarkTheme(isBase: true)
    }
}

//struct OnboardView_Previews: PreviewProvider {
//    static var previews: some View {
//        OnboardSubView()
//    }
//}
