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
    @StateObject var userSettings = UserCustomisations()
    
    var body: some View {
        if UserDefaults.standard.bool(forKey: "KeyOnBoardingViewShown") == false {
            // show your onboarding view
            OnboardingView()
                .onAppear() {
                    // set the value for next call
                    UserDefaults.standard.setValue(true, forKey: "KeyOnBoardingViewShown")
                }
                .environmentObject(userSettings)
                .if(userSettings.isDarkMode) { view in
                    view
                        .preferredColorScheme(.dark)
                }
                .if(!userSettings.isDarkMode) { view in
                    view
                        .preferredColorScheme(.light)
                }
        } else {
            Home(showMenu: false)
                .preferredColorScheme(.light)
                .environmentObject(userSettings)
                .if(userSettings.isDarkMode) { view in
                    view
                        .preferredColorScheme(.dark)
                }
                .if(!userSettings.isDarkMode) { view in
                    view
                        .preferredColorScheme(.light)
                }
        }
        
//        OnboardingView()
//            .preferredColorScheme(.light)
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
//            .environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
    }
}
