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
    let objectImage: String
    let mainText: String
    let subText: String
}

struct OnboardSubView: View {
    var data: OnboardingData
    @State var isAnimating = true
    
    var body: some View {
        VStack() {
            ZStack {
                Image(data.backgroundImage)
                    .resizable()
                    .scaledToFit()
                
                Image(data.objectImage)
                    .resizable()
                    .scaledToFit()
                    .offset(x: 0, y: 150)
                    .scaleEffect(isAnimating ? 1 : 0.9)
            }
            .padding()
            
            Spacer()

            Text(data.mainText)
                .font(.largeTitle)
                .foregroundColor(Color(hex: 0x0B1F29))
                .bold()

            Text(data.subText)
                .font(.headline)
                .foregroundColor(Color(hex: 0xDF4D0F))
                .multilineTextAlignment(.center)

            Spacer()
            
            NavigationLink(destination: Home().preferredColorScheme(.light)) {
                Text("Welcome to ERA...")
                    .padding()
                    .clipShape(Capsule())
                    .textCase(.uppercase)
                    .foregroundColor(.white)
                    .background(Color(hex: 0x19242D, alpha: 1))
                    .font(.system(size: 14))
                    .fontWeight(.semibold)
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
//        OnboardSubView(imageString: "meditating")
//    }
//}
