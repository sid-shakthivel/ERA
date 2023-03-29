//
//  Settings.swift
//  ERA
//
//  Created by Siddharth Shakthivel Muthu Pandian on 09/10/2022.
//

import SwiftUI
import AVFoundation

enum EnhancedReadingStatus: Int, Codable, CaseIterable {
    case Skim, Normal, Off
}

enum GradientReaderStatus: Int, Codable, CaseIterable {
    case Classic, Gray, Dark, Off
}

/*
 UserPreferences contains all settings which the user can modify/set
 */
class UserPreferences: ObservableObject, Codable {
    // For Codable to work, enum of properties need to be listed
    enum CodingKeys: CodingKey {
        case paragraphFontSize, fontColour, backgroundColour, enhancedReadingStatus, gradientReaderStatus, isDarkMode, paragraphFontName, voice, pitch, rate, volume, lineSpacing, letterTracking, isDyslexicFontOn
    }
    
    // All other font sizes and relative to this main font size
    @Published var paragraphFontSize: Int = 16
    
    // Colours
    @Published var fontColour: Color = .black
    @Published var backgroundColour: Color = Color(hex: 0xFFF9F0, alpha: 1)
    
    // Toggles for specific settings
    @Published var enhancedReadingStatus: EnhancedReadingStatus = .Off
    @Published var isDarkMode: Bool = false
    @Published var gradientReaderStatus: GradientReaderStatus = .Off
    
    // Sets indivudal fonts for each category
    @Published var paragraphFont: UIFont = UIFont.systemFont(ofSize: 16)
    @Published var headingFont: UIFont = UIFont.systemFont(ofSize: 24, weight: .bold)
    @Published var subheadingFont: UIFont = UIFont.systemFont(ofSize: 20)
    @Published var subParagaphFont: UIFont = UIFont.systemFont(ofSize: 12)
    
    // TTS settings
    @Published var voice: String = "en-GB"
    @Published var pitch: Float = 1.0
    @Published var rate: Float = 0.5
    @Published var volume: Float = 1.0
    
    // Text based settings
    @Published var lineSpacing: Int = 0
    @Published var letterTracking: Int = 0
    
    @Published var isDyslexicFontOn: Bool = false

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
        
        try container.encode(enhancedReadingStatus, forKey: .enhancedReadingStatus)
        try container.encode(isDarkMode, forKey: .isDarkMode)
        try container.encode(gradientReaderStatus, forKey: .gradientReaderStatus)

        try container.encode(paragraphFont.fontName, forKey: .paragraphFontName)
        
        try container.encode(voice, forKey: .voice)
        try container.encode(pitch, forKey: .pitch)
        try container.encode(rate, forKey: .rate)
        try container.encode(volume, forKey: .volume)
        
        try container.encode(letterTracking, forKey: .letterTracking)
        try container.encode(lineSpacing, forKey: .lineSpacing)
        
        try container.encode(isDyslexicFontOn, forKey: .isDyslexicFontOn)
    }
    
    // Conform to decode
    required init (from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        paragraphFontSize = try container.decode(Int.self, forKey: .paragraphFontSize)
        
        let fontColourEncoded = try container.decode(Data.self, forKey: .fontColour)
        let backgroundColourEncoded = try container.decode(Data.self, forKey: .backgroundColour)

        fontColour = try decodeColor(from: fontColourEncoded)
        backgroundColour = try decodeColor(from: backgroundColourEncoded)
        
        enhancedReadingStatus = try container.decode(EnhancedReadingStatus.self, forKey: .enhancedReadingStatus)
        isDarkMode = try container.decode(Bool.self, forKey: .isDarkMode)
        gradientReaderStatus = try container.decode(GradientReaderStatus.self, forKey: .gradientReaderStatus)
        
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
        letterTracking = try container.decode(Int.self, forKey: .letterTracking)
        
        isDyslexicFontOn = try container.decode(Bool.self, forKey: .isDyslexicFontOn)
    }
    
    // Setup a new userPreferences class using JSON within UserDefaults
    init() {
        if let decodedUserPreferences = UserDefaults.standard.object(forKey: "userPreferences") as? Data {
            let decoder = JSONDecoder()
            if let loadedUserPreferences = try? decoder.decode(UserPreferences.self, from: decodedUserPreferences) {
                paragraphFontSize = loadedUserPreferences.paragraphFontSize
                fontColour = loadedUserPreferences.fontColour
                backgroundColour = loadedUserPreferences.backgroundColour
                enhancedReadingStatus = loadedUserPreferences.enhancedReadingStatus
                gradientReaderStatus = loadedUserPreferences.gradientReaderStatus
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
                lineSpacing = loadedUserPreferences.lineSpacing
                letterTracking = loadedUserPreferences.letterTracking
                isDyslexicFontOn = loadedUserPreferences.isDyslexicFontOn
                return
            }
        }
    }
}

struct Settings: View {
    @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>
    
    @State var isShowingFontPicker = false
    @EnvironmentObject var settings: UserPreferences
    @EnvironmentObject var canvasSettings: TempCanvas
    
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
                            .font(.system(size: 16, weight: .bold))
                            .textCase(.uppercase)
                    }
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.trailing)
                .padding(.leading)

                Divider()
                
                VStack {
                    FontSettings(isShowingFontPicker: $isShowingFontPicker)
                    BackgroundSettings()
                    AppSettings()
                    TTSSettings()
                    
                    Button(action: {
                        // Resets settings back to default
                        settings.paragraphFontSize = 16;
                        settings.fontColour = .black
                        settings.enhancedReadingStatus = .Off
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
                            .font(.system(size: 14, weight: .semibold))
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
