//
//  BackgroundSettings.swift
//  ERA
//
//  Created by Siddharth Shakthivel Muthu Pandian on 25/03/2023.
//

import SwiftUI

struct BackgroundSettings: View {
    @EnvironmentObject var settings: UserPreferences
    
    var body: some View {
        Group {
            Text("Background Settings")
                .foregroundColor(.black)
                .invertOnDarkTheme()
                .font(.system(size: 24, weight: .bold))
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.top)
                .padding(.bottom)

            Text("Background Colour")
                .foregroundColor(.black)
                .invertOnDarkTheme()
                .font(.system(size: 14, weight: .bold))
                .frame(maxWidth: .infinity, alignment: .leading)

            ColorPicker(selection: $settings.backgroundColour) {
                RoundedRectangle(cornerRadius: 5, style: .circular)
                    .fill(settings.backgroundColour)
                    .frame(width: 20, height: 20)
                    .if(!settings.isDarkMode) { view in
                        view.overlay(
                            RoundedRectangle(cornerRadius: 5)
                                .stroke(Color(hex: 0xF2EDE4, alpha: 1), lineWidth: 1)
                        )
                    }
                    .if(settings.isDarkMode) { view in
                        view.overlay(
                            RoundedRectangle(cornerRadius: 5)
                                .stroke(Color(hex: 0xAB9D96, alpha: 1), lineWidth: 1)
                        )
                    }
            }
                .padding()
                .frame(maxWidth: .infinity, alignment: .leading)
                .invertBackgroundOnDarkTheme(isBase: false)
                .cornerRadius(10)
                .if(!settings.isDarkMode) { view in
                    view.overlay(
                        RoundedRectangle(cornerRadius: 10)
                            .stroke(Color(hex: 0xF2EDE4, alpha: 1), lineWidth: 1)
                    )
                }
                .if(settings.isDarkMode) { view in
                    view.overlay(
                        RoundedRectangle(cornerRadius: 10)
                            .stroke(Color(hex: 0xAB9D96, alpha: 1), lineWidth: 1)
                    )
                }
                .onChange(of: settings.backgroundColour) { _ in
                    settings.saveSettings(userPreferences: settings)
                }
        }
    }
}


