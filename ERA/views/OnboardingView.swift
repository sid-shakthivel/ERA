//
//  OnboardingView.swift
//  ERA
//
//  Created by Siddharth Shakthivel Muthu Pandian on 27/10/2022.
//

import SwiftUI

struct OnboardingView: View {
    var onboardingScreenData: [OnboardingData] = [
        OnboardingData(id: 0, backgroundImage: "onboarding-bg-1", mainText: "Page and text customisation to its full capacity, allows you to read how you want, the way you want"),
        OnboardingData(id: 1, backgroundImage: "onboarding-bg-2", mainText:  "Through annotation and markup, customise text to your liking"),
        OnboardingData(id: 2, backgroundImage: "onboarding-bg-3",mainText: "Digest knowledge thoroughly through text to speech and the inbuilt dictionary"),
    ]
    
    @State var currentTab: Int = 0
    
    var body: some View {
        NavigationView {
            TabView(selection: $currentTab) {
                ForEach(onboardingScreenData) { data in
                    OnboardSubView(data: data)
                        .tag(data.id)
                }
            }
                .tabViewStyle(PageTabViewStyle())
                .indexViewStyle(PageIndexViewStyle(backgroundDisplayMode: .always))
                .background(Color(.white))
        }
    }
}

struct OnboardingView_Previews: PreviewProvider {
    static var previews: some View {
        OnboardingView()
    }
}
