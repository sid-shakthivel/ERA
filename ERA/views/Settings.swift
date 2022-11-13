//
//  Settings.swift
//  ERA
//
//  Created by Siddharth Shakthivel Muthu Pandian on 09/10/2022.
//

import SwiftUI
import AVFoundation

struct ColourConstants {
    static let lightModeBackground = Color(hex: 0xFFF9F0, alpha: 1)
    static let darkModeBackground = Color(hex: 0x0B1F29, alpha: 1)
    static let lightModeLighter = Color(hex: 0xFFFFFF, alpha: 1)
    static let darkModeLighter = Color(hex: 0x061015, alpha: 1)
}

/*
 UserPreferences contains all settings which the user can modify/set
 */
class UserPreferences: ObservableObject, Codable {
    // For Codable to work, enum of properties need to be listed
    enum CodingKeys: CodingKey {
        case paragraphFontSize, fontColour, backgroundColour, isEnhancedReading, isDarkMode, paragraphFontName, voice, pitch, rate, volume
    }
    
    // All other font sizes and relative to this main font size
    @Published var paragraphFontSize: Int
    
    // Colours
    @Published var fontColour: Color = .black
    @Published var backgroundColour: Color = Color(hex: 0xFFF9F0, alpha: 1)
    
    // Toggles for specific settings
    @Published var isEnhancedReading: Bool = false
    @Published var isDarkMode: Bool = false
    
    // Sets indivudal fonts for each category
    @Published var paragraphFont: UIFont = UIFont.systemFont(ofSize: 16)
    @Published var headingFont: UIFont = UIFont.systemFont(ofSize: 24)
    @Published var subheadingFont: UIFont = UIFont.systemFont(ofSize: 20)
    @Published var subParagaphFont: UIFont = UIFont.systemFont(ofSize: 12)
    
    // TTS Settings
    @Published var voice: String = "en-GB"
    @Published var pitch: Float = 1.0
    @Published var rate: Float = 0.5
    @Published var volume: Float = 1.0

    // Save settings from the observable object to user settings
    func saveSettings(userPreferences: UserPreferences) {
        let encoder = JSONEncoder()
        if let encoded = try? encoder.encode(userPreferences) {
            let defaults = UserDefaults.standard
            defaults.set(encoded, forKey: "userPreferences")
        }
    }
    
    // Conform to encode
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)

        try container.encode(paragraphFontSize, forKey: .paragraphFontSize)
        
        try container.encode(encodeColor(colour: fontColour), forKey: .fontColour)
        try container.encode(encodeColor(colour: backgroundColour), forKey: .fontColour)
        
        try container.encode(isEnhancedReading, forKey: .isEnhancedReading)
        try container.encode(isDarkMode, forKey: .isDarkMode)

        try container.encode(paragraphFont.fontName, forKey: .paragraphFontName)
        
        try container.encode(voice, forKey: .voice)
        try container.encode(pitch, forKey: .pitch)
        try container.encode(rate, forKey: .rate)
        try container.encode(volume, forKey: .volume)
    }
    
    // Conform to decode
    required init (from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        paragraphFontSize = try container.decode(Int.self, forKey: .paragraphFontSize)
        
        print("worked a bit")
        
//        let _fontColour = try container.decode(Data.self, forKey: .fontColour)
//        let _backgroundColour = try container.decode(Data.self, forKey: .backgroundColour)
        
        print("worked a bit")

        fontColour = .black
        backgroundColour = .white
        
        print("worked a bit")
        
        isEnhancedReading = try container.decode(Bool.self, forKey: .isEnhancedReading)
        isDarkMode = try container.decode(Bool.self, forKey: .isDarkMode)
        
        print("worked a bit")
        
        // Retrieve font name
        let fontName = try container.decode(String.self, forKey: .paragraphFontName)
        
        paragraphFont = UIFont(name: fontName, size: CGFloat(paragraphFontSize))!
        headingFont = UIFont(name: fontName, size: CGFloat(Double(paragraphFontSize) * 1.5))!
        subheadingFont = UIFont(name: fontName, size: CGFloat(Double(paragraphFontSize) * 1.25))!
        subParagaphFont = UIFont(name: fontName, size: CGFloat(Double(paragraphFontSize) * 0.75))!
        
        print("worked a bit")
        
        voice = try container.decode(String.self, forKey: .voice)
        pitch = try container.decode(Float.self, forKey: .pitch)
        rate = try container.decode(Float.self, forKey: .rate)
        volume = try container.decode(Float.self, forKey: .volume)
        
        print("worked a bit")
    }
    
    init() {
        if let testing = UserDefaults.standard.object(forKey: "userPreferences") as? Data {
            print(testing)
            let decoder = JSONDecoder()
            if let loadedUserPreferences = try? decoder.decode(UserPreferences.self, from: testing) {
                backgroundColour = loadedUserPreferences.backgroundColour
                paragraphFontSize = loadedUserPreferences.paragraphFontSize
                
                print("Shouldn't be 16")
                
                return
            }
        }
        
        print("else'd value")
        paragraphFontSize = 16
    }
}

// Load settings from user defaults into the struct on initialisation
func loadSettings() -> UserPreferences {
    if let userPreferences = UserDefaults.standard.object(forKey: "userPreferences") as? Data {
        let decoder = JSONDecoder()
        if let loadedUserPreferences = try? decoder.decode(UserPreferences.self, from: userPreferences) {
            print("hello")
            return loadedUserPreferences
        }
    }
    
    print("oh oh no")
    
    return UserPreferences()
}

struct Settings: View {
    @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>
    
    var languages = ["en-GB", "en-US", "en-ZA", "fr-FR", "en-IN", "ko-KR", "en-AU", "es-ES", "it-IT"]
    
    @State private var isShowingFontPicker = false
    @EnvironmentObject var settings: UserPreferences
    @EnvironmentObject var canvasSettings: CanvasSettings
    
    // If enhanced reading is enabled, apply to each word within the string or return it
    func modifyText(text: String) -> LocalizedStringKey {
        var markdownStringArray: [String] = []
        
        for substring in text.split(separator: " ") {
            markdownStringArray.append(enhanceText(text: String(substring)))
        }

        return LocalizedStringKey(markdownStringArray.joined(separator: " "))
    }
    
    var body: some View {
        NavigationView {
            ScrollView {
                HStack {
                    Button {
                        presentationMode.wrappedValue.dismiss()
                    } label: {
                        Image("arrow-left")
                            .resizable()
                            .frame(width: 30, height: 30)
                            .invertOnDarkTheme()

                        Text("Settings")
                            .if(settings.isDarkMode) { view in
                                view
                                    .foregroundColor(.white)
                            }
                            .if(!settings.isDarkMode) { view in
                                view
                                    .foregroundColor(.black)
                            }
                            .font(.system(size: 14))
                            .fontWeight(.bold)
                            .textCase(.uppercase)
                    }
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding()

                Divider()
                
                VStack {
                    Group {
                        Text("Font Settings")
                            .if(settings.isDarkMode) { view in
                                view
                                    .foregroundColor(.white)
                            }
                            .if(!settings.isDarkMode) { view in
                                view
                                    .foregroundColor(.black)
                            }
                            .fontWeight(.bold)
                            .font(.system(size: 24))
                            .frame(maxWidth: .infinity, alignment: .leading)

                        Group {
                            Toggle(isOn: $settings.isEnhancedReading, label: {
                                Text("Enhanced Reading")
                                    .if(settings.isDarkMode) { view in
                                        view
                                            .foregroundColor(.white)
                                    }
                                    .if(!settings.isDarkMode) { view in
                                        view
                                            .foregroundColor(.black)
                                    }
                                    .fontWeight(.bold)
                                    .font(.system(size: 14))
                            })

                            Text(modifyText(text: "Enhanced reading boldens the first half of every word which improves concentration"))
                                .if(settings.isDarkMode) { view in
                                    view
                                        .foregroundColor(.white)
                                }
                                .if(!settings.isDarkMode) { view in
                                    view
                                        .foregroundColor(.black)
                                }
                                .font(Font(settings.paragraphFont))
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .padding(.bottom)
                        }

                        Group {
                            Text("Font Selection")
                                .if(settings.isDarkMode) { view in
                                    view
                                        .foregroundColor(.white)
                                }
                                .if(!settings.isDarkMode) { view in
                                    view
                                        .foregroundColor(.black)
                                }
                                .fontWeight(.bold)
                                .font(.system(size: 14))
                                .frame(maxWidth: .infinity, alignment: .leading)

                            Button(action: {
                                isShowingFontPicker.toggle()
                            }, label: {
                                HStack {
                                    Text("\(settings.paragraphFont.fontName)")
                                        .font(.system(size: 14))
                                        .fontWeight(.regular)
                                        .foregroundColor(.black)

                                    Spacer()

                                    Image("custom-arrow-down")
                                }
                                .padding()
                            })
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .background(Color(hex: 0xFFFFFF, alpha: 1))
                            .border(Color(hex: 0xF2EDE4, alpha: 1), width: 1)
                        }

                        Group {
                            Text("Font Size")
                                .if(settings.isDarkMode) { view in
                                    view
                                        .foregroundColor(.white)
                                }
                                .if(!settings.isDarkMode) { view in
                                    view
                                        .foregroundColor(.black)
                                }
                                .fontWeight(.bold)
                                .font(.system(size: 14))
                                .frame(maxWidth: .infinity, alignment: .leading)

                            Picker(selection: $settings.paragraphFontSize, content: {
                                ForEach(10...50, id: \.self) { number in
                                    HStack {
                                        Text("\(number)")
                                            .font(.system(size: 14))
                                            .fontWeight(.regular)
                                            .foregroundColor(.black)
                                            .padding()
                                    }
                                }
                            }, label: {

                            })
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .accentColor(.black)
                                .background(Color(hex: 0xFFFFFF, alpha: 1))
                                .border(Color(hex: 0xF2EDE4, alpha: 1), width: 1)
                                .onChange(of: settings.paragraphFontSize, perform: { newFontSize in
                                    settings.paragraphFont = UIFont(descriptor: settings.paragraphFont.fontDescriptor, size: CGFloat(settings.paragraphFontSize))
                                    settings.headingFont = UIFont(descriptor: settings.paragraphFont.fontDescriptor, size: CGFloat(Double(settings.paragraphFontSize) * 1.5))
                                    settings.subheadingFont = UIFont(descriptor: settings.paragraphFont.fontDescriptor, size: CGFloat(Double(settings.paragraphFontSize) * 1.25))
                                    settings.subParagaphFont = UIFont(descriptor: settings.paragraphFont.fontDescriptor, size: CGFloat(Double(settings.paragraphFontSize) * 0.75))
                                })
                        }

                        Group {
                            Text("Font Colour")
                                .if(settings.isDarkMode) { view in
                                    view
                                        .foregroundColor(.white)
                                }
                                .if(!settings.isDarkMode) { view in
                                    view
                                        .foregroundColor(.black)
                                }
                                .fontWeight(.bold)
                                .font(.system(size: 14))
                                .frame(maxWidth: .infinity, alignment: .leading)

                            ColorPicker(selection: $settings.fontColour) {
                                RoundedRectangle(cornerRadius: 5, style: .circular)
                                    .fill(settings.fontColour)
                                    .frame(width: 20, height: 20)
                            }
                                .padding()
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .background(Color(hex: 0xFFFFFF, alpha: 1))
                                .border(Color(hex: 0xF2EDE4, alpha: 1), width: 1)
                        }
                    }

                    Group {
                        Text("Background Settings")
                            .if(settings.isDarkMode) { view in
                                view
                                    .foregroundColor(.white)
                            }
                            .if(!settings.isDarkMode) { view in
                                view
                                    .foregroundColor(.black)
                            }
                            .fontWeight(.bold)
                            .font(.system(size: 24))
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding(.top)
                            .padding(.bottom)

                        Text("Background Colour")
                            .if(settings.isDarkMode) { view in
                                view
                                    .foregroundColor(.white)
                            }
                            .if(!settings.isDarkMode) { view in
                                view
                                    .foregroundColor(.black)
                            }
                            .fontWeight(.bold)
                            .font(.system(size: 14))
                            .frame(maxWidth: .infinity, alignment: .leading)

                        ColorPicker(selection: $settings.backgroundColour) {
                            RoundedRectangle(cornerRadius: 5, style: .circular)
                                .fill(settings.backgroundColour)
                                .frame(width: 20, height: 20)
                        }
                            .padding()
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .background(Color(hex: 0xFFFFFF, alpha: 1))
                            .border(Color(hex: 0xF2EDE4, alpha: 1), width: 1)
                    }
                    
                    Group {
                        Text("App Settings")
                            .if(settings.isDarkMode) { view in
                                view
                                    .foregroundColor(.white)
                            }
                            .if(!settings.isDarkMode) { view in
                                view
                                    .foregroundColor(.black)
                            }
                            .fontWeight(.bold)
                            .font(.system(size: 24))
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding(.top)
                            .padding(.bottom)
                        
                        Group {
//                            Toggle(isOn: $settings.isDarkMode, label: {
//                                Text("Dark Mode")
//                                    .if(settings.isDarkMode) { view in
//                                        view
//                                            .foregroundColor(.white)
//                                    }
//                                    .if(!settings.isDarkMode) { view in
//                                        view
//                                            .foregroundColor(.black)
//                                    }
//                                    .fontWeight(.bold)
//                                    .font(.system(size: 14))
//                            })
//                            .onTapGesture {
//                                DispatchQueue.main.async{
//                                    if settings.backgroundColour == ColourConstants.lightModeBackground {
//                                        settings.backgroundColour = ColourConstants.darkModeBackground
//                                        settings.fontColour = .white
//                                        canvasSettings.selectedColour = .black
//                                        canvasSettings.selectedHighlighterColour = .black
//                                    } else if settings.backgroundColour == ColourConstants.darkModeBackground {
//                                        settings.backgroundColour = ColourConstants.lightModeBackground
//                                        settings.fontColour = .black
//                                        canvasSettings.selectedColour = .white
//                                        canvasSettings.selectedHighlighterColour = .white
//                                    }
//                                }
//                            }
                        }
                    }
                    
                    Group {
                        Text("Text to Speech")
                            .if(settings.isDarkMode) { view in
                                view
                                    .foregroundColor(.white)
                            }
                            .if(!settings.isDarkMode) { view in
                                view
                                    .foregroundColor(.black)
                            }
                            .fontWeight(.bold)
                            .font(.system(size: 24))
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding(.top)
                            .padding(.bottom)

                        Group {
                            Text("Pitch")
                                .if(settings.isDarkMode) { view in
                                    view
                                        .foregroundColor(.white)
                                }
                                .if(!settings.isDarkMode) { view in
                                    view
                                        .foregroundColor(.black)
                                }
                                .fontWeight(.bold)
                                .font(.system(size: 14))
                                .frame(maxWidth: .infinity, alignment: .leading)

                            Slider(value: $settings.pitch, in: 0.5...2)

                            Text("Volume")
                                .if(settings.isDarkMode) { view in
                                    view
                                        .foregroundColor(.white)
                                }
                                .if(!settings.isDarkMode) { view in
                                    view
                                        .foregroundColor(.black)
                                }
                                .fontWeight(.bold)
                                .font(.system(size: 14))
                                .frame(maxWidth: .infinity, alignment: .leading)

                            Slider(value: $settings.volume, in: 0...1)

                            Text("Rate")
                                .if(settings.isDarkMode) { view in
                                    view
                                        .foregroundColor(.white)
                                }
                                .if(!settings.isDarkMode) { view in
                                    view
                                        .foregroundColor(.black)
                                }
                                .fontWeight(.bold)
                                .font(.system(size: 14))
                                .frame(maxWidth: .infinity, alignment: .leading)

                            Slider(value: $settings.rate, in: AVSpeechUtteranceMinimumSpeechRate...AVSpeechUtteranceMaximumSpeechRate)
                        }

                        Group {
                            Text("Accent")
                                .if(settings.isDarkMode) { view in
                                    view
                                        .foregroundColor(.white)
                                }
                                .if(!settings.isDarkMode) { view in
                                    view
                                        .foregroundColor(.black)
                                }
                                .fontWeight(.bold)
                                .font(.system(size: 14))
                                .frame(maxWidth: .infinity, alignment: .leading)

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
                                .accentColor(.black)
                                .background(Color(hex: 0xFFFFFF, alpha: 1))
                                .border(Color(hex: 0xF2EDE4, alpha: 1), width: 1)
                                .padding(.bottom)
                        }
                    }
                    
                    Button(action: {
                        settings.saveSettings(userPreferences: settings)
                    }, label: {
                        Text("Save")
                            .textCase(.uppercase)
                            .foregroundColor(.white)
                            .font(.system(size: 14))
                            .fontWeight(.semibold)
                            .frame(maxWidth: .infinity)
                            .padding()
                    })
                        .frame(maxHeight: .infinity, alignment: .bottomLeading)
                        .buttonStyle(.borderedProminent)
                    
//                    Button(action: {
//                        // Resets settings back to default
//                        settings.paragraphFontSize = 16;
//                        settings.fontColour = .black
//                        settings.isEnhancedReading = false
//                        settings.paragraphFont = UIFont.systemFont(ofSize: 16)
//                        settings.headingFont = UIFont.systemFont(ofSize: 24)
//                        settings.backgroundColour = Color(hex: 0xFFF9F0, alpha: 1)
//                        settings.volume = 1
//                        settings.pitch = 1
//                        settings.rate = 0.5
//                        settings.voice = "en-GB"
//
//                    }, label: {
//                        Text("Reset")
//                            .textCase(.uppercase)
//                            .foregroundColor(.white)
//                            .font(.system(size: 14))
//                            .fontWeight(.semibold)
//                            .frame(maxWidth: .infinity)
//                            .padding()
//                    })
//                        .frame(maxHeight: .infinity, alignment: .bottomLeading)
//                        .if(settings.isDarkMode) { view in
//                            view
//                                .tint(Color(hex: 0x9da5a9, alpha: 1))
//                        }
//                        .if(!settings.isDarkMode) { view in
//                            view
//                                .tint(Color(hex: 0x19242D, alpha: 1))
//                        }
//                        .buttonStyle(.borderedProminent)
                    
                }
                    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
                    .padding()
            }
                .if(settings.isDarkMode) { view in
                    view
                        .background(ColourConstants.darkModeBackground)
                }
                .if(!settings.isDarkMode) { view in
                    view
                        .background(ColourConstants.lightModeBackground)
                }
                .sheet(isPresented: $isShowingFontPicker) {                    
                    FontPickerWrapper(isShowingFontPicker: $isShowingFontPicker)
                }
        }
            .navigationBarTitle("")
            .navigationBarBackButtonHidden(true)
            .navigationBarHidden(true)
    }
}

struct Settings_Previews: PreviewProvider {
    static var previews: some View {
        Settings()
    }
}
