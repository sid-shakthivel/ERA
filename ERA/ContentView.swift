//
//  ContentView.swift
//  ERA
//
//  Created by Siddharth Shakthivel Muthu Pandian on 29/09/2022.
//

import SwiftUI
import CoreData

extension View {
    @ViewBuilder func `if`<Content: View>(_ condition: Bool, transform: (Self) -> Content) -> some View {
        if condition {
            transform(self)
        } else {
            self
        }
    }
}

struct ContentView: View {
    var body: some View {
        if UserDefaults.standard.bool(forKey: "KeyOnBoardingViewShown") == false {
            // show your onboarding view
            OnboardingView()
                .onAppear() {
                    // set the value for next call
                    UserDefaults.standard.setValue(true, forKey: "KeyOnBoardingViewShown")
                }
                .preferredColorScheme(.light)
        } else {
            Home()
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
