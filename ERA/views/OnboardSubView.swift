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
    @State var isAnimating = true
    
    @EnvironmentObject var userSettings: UserPreferences
    
    var body: some View {
        VStack() {
            Spacer()
            
            Image(data.backgroundImage)
                .resizable()
                .scaledToFit()
                .padding()
            
            Spacer()

            Text(modifyText(state: .Normal, text: data.mainText))
                .foregroundColor(Color(hex: 0x000000))
                .font(.system(size: 24))
                .multilineTextAlignment(.center)
                .padding()

            Spacer()
            
            if (id == 2) {
                NavigationLink(destination: FileExplorer()) {
                    Text("Welcome to ERA")
                        .padding()
                        .frame(maxWidth: .infinity)
                        .foregroundColor(.white)
                        .background(Color(hex: 0xCB4E25, alpha: 1))
                        .font(.system(size: 24, weight: .semibold))
                        .clipShape(Capsule())
                }
                .padding()
            }
            
            Spacer()
        }
        .onAppear(perform: {
            isAnimating = false
            withAnimation(.easeOut(duration: 0.5)) {
                self.isAnimating = true
            }
        })
    }
}

//struct OnboardView_Previews: PreviewProvider {
//    static var previews: some View {
//        OnboardSubView()
//    }
//}
