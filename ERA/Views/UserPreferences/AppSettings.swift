//
//  AppSettings.swift
//  ERA
//
//  Created by Siddharth Shakthivel Muthu Pandian on 25/03/2023.
//

import SwiftUI
import MLKitTranslate

struct AppSettings: View {
    @EnvironmentObject var settings: UserPreferences
    
    @State var localModels = ModelManager.modelManager().downloadedTranslateModels
    
    var body: some View {
        Group {
            Text("App Settings")
                .foregroundColor(.black)
                .invertOnDarkTheme()
                .font(.system(size: 24, weight: .bold))
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.top)
                .padding(.bottom)

            Group {
                // Put behind paywall
                
                Toggle(isOn: $settings.isDarkMode, label: {
                    Text("Dark Mode")
                        .foregroundColor(.black)
                        .invertOnDarkTheme()
                        .font(.system(size: 14, weight: .bold))
                })
                .onChange(of: settings.isDarkMode) { isDarkMode in
                   do {
                       if isDarkMode {
                           // Set other settings to dark mode
                           let test = try encodeColor(colour: ColourConstants.lightModeBackground)
                           let best = try decodeColor(from: test)

                           if best == settings.backgroundColour || ColourConstants.lightModeBackground == settings.backgroundColour {
                               settings.backgroundColour = ColourConstants.darkModeBackground
                               settings.fontColour = .white
                           }
                       } else {
                           // Set other settings to light mode
                           let test = try encodeColor(colour: ColourConstants.darkModeBackground)
                           let best = try decodeColor(from: test)

                           if best == settings.backgroundColour || ColourConstants.darkModeBackground == settings.backgroundColour {
                               settings.backgroundColour = ColourConstants.lightModeBackground
                               settings.fontColour = .black
                           }
                       }

                       settings.saveSettings(userPreferences: settings)
                   } catch {

                   }
               }
            }
            
            Group {
                Text("Downloaded Languages")
                    .foregroundColor(.black)
                    .invertOnDarkTheme()
                    .font(.system(size: 14, weight: .bold))
                    .frame(maxWidth: .infinity, alignment: .leading)
                
                ForEach(localModels.sorted{$0.language.rawValue < $1.language.rawValue}, id: \.self) { model in
                    HStack {
                        Text(Locale.current.localizedString(forLanguageCode: model.language.rawValue)!)
                            .font(.system(size: 14))
                            .fontWeight(.regular)
                            .foregroundColor(.black)
                            .invertOnDarkTheme()
                        
                        Spacer()
                        
                        Button(action: {
                            let modelToBeDeleted = TranslateRemoteModel.translateRemoteModel(language: model.language)
                            ModelManager.modelManager().deleteDownloadedModel(modelToBeDeleted) { error in
                                guard error == nil else { return }
                            }
                        }, label: {
                            Image("stop-editing")
                                .resizable()
                                .frame(width: 30, height: 30)
                                .invertOnDarkTheme()
                        })
                    }
                    
                }
            }
        }
    }
}


