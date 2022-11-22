//
//  Settings.swift
//  ERA
//
//  Created by Siddharth Shakthivel Muthu Pandian on 09/10/2022.
//

import SwiftUI
import AVFoundation

/*
 UserPreferences contains all settings which the user can modify/set
 */
class UserPreferences: ObservableObject, Codable {
    // For Codable to work, enum of properties need to be listed
    enum CodingKeys: CodingKey {
        case paragraphFontSize, fontColour, backgroundColour, isEnhancedReading, isDarkMode, paragraphFontName, voice, pitch, rate, volume, lineSpacing
    }
    
    // All other font sizes and relative to this main font size
    @Published var paragraphFontSize: Int = 16
    
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
    
    // TTS settings
    @Published var voice: String = "en-GB"
    @Published var pitch: Float = 1.0
    @Published var rate: Float = 0.5
    @Published var volume: Float = 1.0
    
    // Line spacing
    @Published var lineSpacing: Int = 0

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
        try container.encode(encodeColor(colour: backgroundColour), forKey: .backgroundColour)
        
        try container.encode(isEnhancedReading, forKey: .isEnhancedReading)
        try container.encode(isDarkMode, forKey: .isDarkMode)

        try container.encode(paragraphFont.fontName, forKey: .paragraphFontName)
        
        try container.encode(voice, forKey: .voice)
        try container.encode(pitch, forKey: .pitch)
        try container.encode(rate, forKey: .rate)
        try container.encode(volume, forKey: .volume)
        
        try container.encode(lineSpacing, forKey: .lineSpacing)
    }
    
    // Conform to decode
    required init (from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        paragraphFontSize = try container.decode(Int.self, forKey: .paragraphFontSize)
        
        let fontColourEncoded = try container.decode(Data.self, forKey: .fontColour)
        let backgroundColourEncoded = try container.decode(Data.self, forKey: .backgroundColour)

        fontColour = try decodeColor(from: fontColourEncoded)
        backgroundColour = try decodeColor(from: backgroundColourEncoded)
        
        isEnhancedReading = try container.decode(Bool.self, forKey: .isEnhancedReading)
        isDarkMode = try container.decode(Bool.self, forKey: .isDarkMode)
        
        // Retrieve font name
        let fontName = try container.decode(String.self, forKey: .paragraphFontName)
        
        // If font is standard font of .SFUI-Regular, system font API must be used
        if fontName == ".SFUI-Regular" {
            paragraphFont = UIFont.systemFont(ofSize: CGFloat(paragraphFontSize))
            headingFont = UIFont.systemFont(ofSize: CGFloat(Double(paragraphFontSize) * 1.5))
            subheadingFont = UIFont.systemFont(ofSize: CGFloat(Double(paragraphFontSize) * 1.25))
            subParagaphFont = UIFont.systemFont(ofSize: CGFloat(Double(paragraphFontSize) * 0.75))
        } else {
            paragraphFont = UIFont(name: fontName, size: CGFloat(paragraphFontSize))!
            headingFont = UIFont(name: fontName, size: CGFloat(Double(paragraphFontSize) * 1.5))!
            subheadingFont = UIFont(name: fontName, size: CGFloat(Double(paragraphFontSize) * 1.25))!
            subParagaphFont = UIFont(name: fontName, size: CGFloat(Double(paragraphFontSize) * 0.75))!
        }
        
        voice = try container.decode(String.self, forKey: .voice)
        pitch = try container.decode(Float.self, forKey: .pitch)
        rate = try container.decode(Float.self, forKey: .rate)
        volume = try container.decode(Float.self, forKey: .volume)
        
        lineSpacing = try container.decode(Int.self, forKey: .lineSpacing)
    }
    
    // Setup a new userPreferences class using JSON within UserDefaults
    init() {
        if let decodedUserPreferences = UserDefaults.standard.object(forKey: "userPreferences") as? Data {
            let decoder = JSONDecoder()
            if let loadedUserPreferences = try? decoder.decode(UserPreferences.self, from: decodedUserPreferences) {
                paragraphFontSize = loadedUserPreferences.paragraphFontSize
                fontColour = loadedUserPreferences.fontColour
                backgroundColour = loadedUserPreferences.backgroundColour
                isEnhancedReading = loadedUserPreferences.isEnhancedReading
                paragraphFont = loadedUserPreferences.paragraphFont
                headingFont = loadedUserPreferences.headingFont
                subheadingFont = loadedUserPreferences.subheadingFont
                subParagaphFont = loadedUserPreferences.subParagaphFont
                voice = loadedUserPreferences.voice
                pitch = loadedUserPreferences.pitch
                rate = loadedUserPreferences.rate
                volume = loadedUserPreferences.volume
                lineSpacing = loadedUserPreferences.lineSpacing
                isDarkMode = loadedUserPreferences.isDarkMode                
                return
            }
        }
    }
}

struct Settings: View {
    @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>
    
//    var languages: [String] = AVSpeechSynthesisVoice.speechVoices().map { $0.language }.removingDuplicates()
    var languages: [String] = ["en0-GB"]
    
    @State private var isShowingFontPicker = false
    @EnvironmentObject var settings: UserPreferences
    @EnvironmentObject var canvasSettings: CanvasSettings
    
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
                            .foregroundColor(.black)
                            .invertOnDarkTheme()
                            .font(.system(size: 14))
                            .fontWeight(.bold)
                            .textCase(.uppercase)
                    }
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.trailing)
                .padding(.leading)

                Divider()
                
                VStack {
                    Group {
                        Text("Font Settings")
                            .fontWeight(.bold)
                            .font(.system(size: 24))
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .foregroundColor(.black)
                            .invertOnDarkTheme()

                        Group {
                            Toggle(isOn: $settings.isEnhancedReading, label: {
                                Text("Enhanced Reading")
                                    .foregroundColor(.black)
                                    .fontWeight(.bold)
                                    .font(.system(size: 14))
                                    .invertOnDarkTheme()
                            })

                            Text(modifyText(condition: true, text: "Enhanced reading boldens the first half of every word which improves concentration"))
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .padding(.bottom)
                                .foregroundColor(.black)
                                .invertOnDarkTheme()
                        }

                        Group {
                            Text("Font Selection")
                                .foregroundColor(.black)
                                .fontWeight(.bold)
                                .font(.system(size: 14))
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .invertOnDarkTheme()

                            Button(action: {
                                isShowingFontPicker.toggle()
                            }, label: {
                                HStack {
                                    Text("\(settings.paragraphFont.fontName)")
                                        .font(.system(size: 14))
                                        .fontWeight(.regular)
                                        .foregroundColor(.black)
                                        .invertOnDarkTheme()

                                    Spacer()

                                    Image("custom-arrow-down")
                                }
                                .padding()
                            })
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
                        }

                        Group {
                            Text("Font Size")
                                .foregroundColor(.black)
                                .invertOnDarkTheme()
                                .fontWeight(.bold)
                                .font(.system(size: 14))
                                .frame(maxWidth: .infinity, alignment: .leading)

                            Picker(selection: $settings.paragraphFontSize, content: {
                                ForEach(10...50, id: \.self) { number in
                                    HStack {
                                        Text("\(number)")
                                            .font(.system(size: 14))
                                            .fontWeight(.regular)
                                            .foregroundColor(.white)
                                            .invertOnDarkTheme()
                                            .padding()
                                    }
                                }
                            }, label: {

                            })
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
                                .onChange(of: settings.paragraphFontSize, perform: { newFontSize in
                                    settings.paragraphFont = UIFont(descriptor: settings.paragraphFont.fontDescriptor, size: CGFloat(settings.paragraphFontSize))
                                    settings.headingFont = UIFont(descriptor: settings.paragraphFont.fontDescriptor, size: CGFloat(Double(settings.paragraphFontSize) * 1.5))
                                    settings.subheadingFont = UIFont(descriptor: settings.paragraphFont.fontDescriptor, size: CGFloat(Double(settings.paragraphFontSize) * 1.25))
                                    settings.subParagaphFont = UIFont(descriptor: settings.paragraphFont.fontDescriptor, size: CGFloat(Double(settings.paragraphFontSize) * 0.75))
                                })
                        }

                        Group {
                            Text("Font Colour")
                                .foregroundColor(.black)
                                .invertOnDarkTheme()
                                .fontWeight(.bold)
                                .font(.system(size: 14))
                                .frame(maxWidth: .infinity, alignment: .leading)

                            ColorPicker(selection: $settings.fontColour) {
                                RoundedRectangle(cornerRadius: 5, style: .circular)
                                    .fill(settings.fontColour)
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
                        }
                        
                        Group {
                            Text("Line Spacing")
                                .foregroundColor(.black)
                                .invertOnDarkTheme()
                                .fontWeight(.bold)
                                .font(.system(size: 14))
                                .frame(maxWidth: .infinity, alignment: .leading)
                            
                            Picker(selection: $settings.lineSpacing, content: {
                                ForEach(0...20, id: \.self) { number in
                                    HStack {
                                        Text("\(number)")
                                            .font(.system(size: 14))
                                            .fontWeight(.regular)
                                            .foregroundColor(.black)
                                            .invertOnDarkTheme()
                                            .padding()
                                    }
                                }
                            }, label: {

                            })
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
                        }
                                                
                        Text("This is some example text")
                            .foregroundColor(settings.fontColour)
                            .font(Font(settings.paragraphFont))
                            .lineSpacing(CGFloat(settings.lineSpacing))
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding(.top)
                    }

                    Group {
                        Text("Background Settings")
                            .foregroundColor(.black)
                            .invertOnDarkTheme()
                            .fontWeight(.bold)
                            .font(.system(size: 24))
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding(.top)
                            .padding(.bottom)

                        Text("Background Colour")
                            .foregroundColor(.black)
                            .invertOnDarkTheme()
                            .fontWeight(.bold)
                            .font(.system(size: 14))
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
                    }
                    
                    Group {
                        Text("App Settings")
                            .foregroundColor(.black)
                            .invertOnDarkTheme()
                            .fontWeight(.bold)
                            .font(.system(size: 24))
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding(.top)
                            .padding(.bottom)
                        
                        Group {
                            Toggle(isOn: $settings.isDarkMode, label: {
                                Text("Dark Mode")
                                    .foregroundColor(.black)
                                    .invertOnDarkTheme()
                                    .fontWeight(.bold)
                                    .font(.system(size: 14))
                            })
                        }
                        .onChange(of: settings.isDarkMode) { isDarkMode in
                            if isDarkMode {
                                // Set other settings to reflect dark mode
//                                canvasSettings.selectedColour = .white
//                                canvasSettings.selectedHighlighterColour = .white
                            } else {
                                // Set other setting to reflect light mode
//                                canvasSettings.selectedColour = .white
//                                canvasSettings.selectedHighlighterColour = .white
                            }
                            
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
                            } catch {
                                
                            }
                        }
                    }
                    
                    Group {
                        Text("Text to Speech")
                            .foregroundColor(.black)
                            .invertOnDarkTheme()
                            .fontWeight(.bold)
                            .font(.system(size: 24))
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding(.top)
                            .padding(.bottom)

                        Group {
                            Text("Pitch")
                                .foregroundColor(.black)
                                .invertOnDarkTheme()
                                .fontWeight(.bold)
                                .font(.system(size: 14))
                                .frame(maxWidth: .infinity, alignment: .leading)

                            Slider(value: $settings.pitch, in: 0.5...2)

                            Text("Volume")
                                .foregroundColor(.black)
                                .invertOnDarkTheme()
                                .fontWeight(.bold)
                                .font(.system(size: 14))
                                .frame(maxWidth: .infinity, alignment: .leading)

                            Slider(value: $settings.volume, in: 0...1)

                            Text("Rate")
                                .foregroundColor(.black)
                                .invertOnDarkTheme()
                                .fontWeight(.bold)
                                .font(.system(size: 14))
                                .frame(maxWidth: .infinity, alignment: .leading)

                            Slider(value: $settings.rate, in: AVSpeechUtteranceMinimumSpeechRate...AVSpeechUtteranceMaximumSpeechRate)
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
                        .if(settings.isDarkMode) { view in
                            view.tint(ColourConstants.darkModeDarker)
                        }
                        .if(!settings.isDarkMode) { view in
                            view.tint(Color(hex: 0x19242D, alpha: 1))
                        }
                        .frame(maxHeight: .infinity, alignment: .bottomLeading)
                        .buttonStyle(.borderedProminent)
                    
                    Button(action: {
                        // Resets settings back to default
                        settings.paragraphFontSize = 16;
                        settings.fontColour = .black
                        settings.isEnhancedReading = false
                        settings.paragraphFont = UIFont.systemFont(ofSize: 16)
                        settings.headingFont = UIFont.systemFont(ofSize: 24)
                        settings.backgroundColour = ColourConstants.lightModeBackground
                        settings.volume = 1
                        settings.pitch = 1
                        settings.rate = 0.5
                        settings.voice = "en-GB"
                        settings.lineSpacing = 0
                        settings.isDarkMode = false
                        settings.saveSettings(userPreferences: settings)
                    }, label: {
                        Text("Reset")
                            .textCase(.uppercase)
                            .foregroundColor(.white)
                            .font(.system(size: 14))
                            .fontWeight(.semibold)
                            .frame(maxWidth: .infinity)
                            .padding()
                    })
                        .if(settings.isDarkMode) { view in
                            view.tint(ColourConstants.darkModeDarker)
                        }
                        .if(!settings.isDarkMode) { view in
                            view.tint(Color(hex: 0x19242D, alpha: 1))
                        }
                        .frame(maxHeight: .infinity, alignment: .bottomLeading)
                        .buttonStyle(.borderedProminent)
                }
                    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
                    .padding()
            }
                .invertBackgroundOnDarkTheme(isBase: true)
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
