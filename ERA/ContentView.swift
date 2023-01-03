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
    @Environment(\.colorScheme) var colorScheme
    
    @StateObject var userSettings = UserPreferences()
    
    @State var secondAppear: Bool = false
    
    var body: some View {
        if UserDefaults.standard.bool(forKey: "Test") == false {
            OnboardingView()
                .environmentObject(userSettings)
                .onAppear() {
                    // Check for dark mode on initialisation
                    
                    if (secondAppear) {
                        return;
                    }
                    
                    if (colorScheme == .dark) {
                        userSettings.isDarkMode = true
                        userSettings.saveSettings(userPreferences: userSettings)
                    } else {
                        userSettings.isDarkMode = false
                        userSettings.saveSettings(userPreferences: userSettings)
                    }
                    
                    secondAppear = true;
                }
                .if(userSettings.isDarkMode) { view in
                    view.preferredColorScheme(.dark)
                }
                .if(!userSettings.isDarkMode) { view in
                    view.preferredColorScheme(.light)
                }
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
