//
//  ContentView.swift
//  ERA
//
//  Created by Siddharth Shakthivel Muthu Pandian on 29/09/2022.
//

import SwiftUI
import CoreData

struct ContentView: View { 
    var body: some View {
//        if UserDefaults.standard.bool(forKey: "KeyOnBoardingViewShown") == false {
//            // show your onboarding view
//            OnboardingView()
//                .onAppear() {
//                    // set the value for next call
//                    UserDefaults.standard.setValue(true, forKey: "KeyOnBoardingViewShown")
//                }
//                .preferredColorScheme(.light)
//        } else {
//           Home()
//                .preferredColorScheme(.light)
//        }
        
        OnboardingView()
            .preferredColorScheme(.light)
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView().environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
    }
}
