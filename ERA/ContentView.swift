//
//  ContentView.swift
//  ERA
//
//  Created by Siddharth Shakthivel Muthu Pandian on 29/09/2022.
//

import SwiftUI
import CoreData
import MLKit
import MLKitTranslate

extension View {
    @ViewBuilder func `if`<Content: View>(_ condition: Bool, transform: (Self) -> Content) -> some View {
        if condition {
            transform(self)
        } else {
            self
        }
    }
}

class LanguageTranslator: ObservableObject {
    @Published var engine: Translator = Translator.translator(options: TranslatorOptions(sourceLanguage: .english, targetLanguage: .french))
}

struct ContentView: View {
    @Environment(\.managedObjectContext) var moc
    @Environment(\.colorScheme) var colorScheme
    
    @StateObject var userSettings = UserPreferences()
    @StateObject var currentTranslator: LanguageTranslator = LanguageTranslator()
    
    var body: some View {
        if UserDefaults.standard.bool(forKey: "HasInitallyPurchasedERA") == false {
            OnboardingView()
                .environmentObject(userSettings)
                .onAppear() {
                    // Check whether user is specifically in dark/light mode by default
                    userSettings.isDarkMode = colorScheme == .dark ? true : false;
                    userSettings.saveSettings(userPreferences: userSettings)
                    
                    // Download english to french conversion by default
                    let conditions = ModelDownloadConditions(
                        allowsCellularAccess: false,
                        allowsBackgroundDownloading: true
                    )
                    
                    currentTranslator.engine.downloadModelIfNeeded(with: conditions) { error in
                        guard error == nil else { return }
                    }
                }
                .preferredColorScheme(userSettings.isDarkMode ? .dark : .light)
        } else {
            FileExplorer()
                .environmentObject(userSettings)
                .environmentObject(currentTranslator)
                .preferredColorScheme(userSettings.isDarkMode ? .dark : .light)
        }        
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
