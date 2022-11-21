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
    @Environment(\.managedObjectContext) var moc
    
    @StateObject var userSettings = UserPreferences()
    
    var body: some View {
        if UserDefaults.standard.bool(forKey: "KeyOnBoardingViewShown") == false {
            OnboardingView()
                .onAppear() {
                    // Set the value for next call
                    UserDefaults.standard.setValue(true, forKey: "KeyOnBoardingViewShown")
                }
                .preferredColorScheme(.light)
        } else {
            FileExplorer()
                .environmentObject(userSettings)
                .if(!userSettings.isDarkMode) { view in
                    view
                        .preferredColorScheme(.light)
                }
                .if(userSettings.isDarkMode) { view in
                    view
                        .preferredColorScheme(.dark)
                }
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
