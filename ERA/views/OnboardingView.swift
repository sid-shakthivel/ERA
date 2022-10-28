//
//  OnboardingView.swift
//  ERA
//
//  Created by Siddharth Shakthivel Muthu Pandian on 27/10/2022.
//

import SwiftUI

struct OnboardingView: View {
    var onboardingScreenData: [OnboardingData] = [
        OnboardingData(id: 0, backgroundImage: "onboarding-bg-3", objectImage: "onboarding-object-3", mainText: "Read", subText: "Read the way you want, how you want"),
        OnboardingData(id: 1, backgroundImage: "onboarding-bg-2", objectImage: "onboarding-object-2", mainText: "Edit", subText: "Modify any text"),
        OnboardingData(id: 2, backgroundImage: "onboarding-bg-1", objectImage: "onboarding-object-1", mainText: "Understand", subText: "Listen and uncover meanings"),
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
