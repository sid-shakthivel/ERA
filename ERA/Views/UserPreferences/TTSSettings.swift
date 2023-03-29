//
//  TTSSettings.swift
//  ERA
//
//  Created by Siddharth Shakthivel Muthu Pandian on 25/03/2023.
//

import SwiftUI
import AVFoundation

struct TTSSettings: View {
    @EnvironmentObject var settings: UserPreferences
    
    var languages: [String] = AVSpeechSynthesisVoice.speechVoices().map { $0.language }.removingDuplicates()
    
    var body: some View {
        Group {
            Text("Text to Speech")
                .foregroundColor(.black)
                .invertOnDarkTheme()
                .font(.system(size: 24, weight: .bold))
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.top)
                .padding(.bottom)

            Group {
                Text("Pitch")
                    .foregroundColor(.black)
                    .invertOnDarkTheme()
                    .font(.system(size: 14, weight: .bold))
                    .frame(maxWidth: .infinity, alignment: .leading)

                Slider(value: $settings.pitch, in: 0.5...2)
                    .onChange(of: settings.pitch) { _ in
                        settings.saveSettings(userPreferences: settings)
                    }

                Text("Volume")
                    .foregroundColor(.black)
                    .invertOnDarkTheme()
                    .font(.system(size: 14, weight: .bold))
                    .frame(maxWidth: .infinity, alignment: .leading)

                Slider(value: $settings.volume, in: 0...1)
                    .onChange(of: settings.volume) { _ in
                        settings.saveSettings(userPreferences: settings)
                    }

                Text("Rate")
                    .foregroundColor(.black)
                    .invertOnDarkTheme()
                    .font(.system(size: 14, weight: .bold))
                    .frame(maxWidth: .infinity, alignment: .leading)

                Slider(value: $settings.rate, in: AVSpeechUtteranceMinimumSpeechRate...AVSpeechUtteranceMaximumSpeechRate)
                    .onChange(of: settings.rate) { _ in
                        settings.saveSettings(userPreferences: settings)
                    }
            }

            Group {
                Text("Accent")
                    .foregroundColor(.black)
                    .fontWeight(.bold)
                    .font(.system(size: 14))
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .invertOnDarkTheme()

                Picker(selection: $settings.voice, content: {
                    ForEach(languages, id: \.self) {
                        Text($0)
                            .frame(maxWidth: .infinity, alignment: .trailing)
                    }
               }, label: {

               })
                    .pickerStyle(.menu)
                    .labelsHidden()
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .if(settings.isDarkMode) { view in
                        view
                            .accentColor(.white)
                            .background(ColourConstants.darkModeDarker)
                    }
                    .if(!settings.isDarkMode) { view in
                        view
                            .accentColor(.black)
                            .background(ColourConstants.lightModeLighter)
                    }
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
                    .padding(.bottom)
                    .onChange(of: settings.voice) { _ in
                        settings.saveSettings(userPreferences: settings)
                    }
            }
        }
    }
}
