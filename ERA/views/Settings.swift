//
//  Settings.swift
//  ERA
//
//  Created by Siddharth Shakthivel Muthu Pandian on 09/10/2022.
//

import SwiftUI

class UserCustomisations: ObservableObject {
    @Published var paragraphFontSize: Int = 16
    
    @Published var fontColour: Color = .black
    @Published var isEnhancedReading: Bool = false
    
    @Published var paragraphFont: UIFont = UIFont.systemFont(ofSize: 16)
    @Published var headingFont: UIFont = UIFont.systemFont(ofSize: 24)
    @Published var subheadingFont: UIFont = UIFont.systemFont(ofSize: 20)
    @Published var subParagaphFont: UIFont = UIFont.systemFont(ofSize: 12)
    
    @Published var backgroundColour: Color = Color(hex: 0xFFF9F0, alpha: 1)
    
    @Published var voice: String = "en-GB"
    @Published var pitch: Float = 1.0
    @Published var rate: Float = 0.5
    @Published var volume: Float = 1.0
}

struct Settings: View {
    @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>
    
    var languages = ["en-GB", "en-US", "en-ZA", "fr-FR", "en-IN", "ko-KR", "en-AU", "es-ES", "it-IT"]
    
    @State private var isShowingFontPicker = false
    @EnvironmentObject var settings: UserCustomisations
    
    var body: some View {
        NavigationView {
            ScrollView {
                HStack {
                    Button {
                        presentationMode.wrappedValue.dismiss()
                    } label: {
                        Image("arrow-left")
                        
                        Text("Settings")
                            .foregroundColor(.black)
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
                            .foregroundColor(.black)
                            .fontWeight(.bold)
                            .font(.system(size: 24))
                            .frame(maxWidth: .infinity, alignment: .leading)

                        Group {
                            Toggle(isOn: $settings.isEnhancedReading, label: {
                                Text("Enhanced Reading")
                                    .foregroundColor(.black)
                                    .fontWeight(.bold)
                                    .font(.system(size: 14))
                            })
                            
                            Text("Enhanced reading boldens the first half of every word which improves concentration")
                                .fontWeight(.semibold)
                                .font(settings.subParagaphFont)
                        }

                        Group {
                            Text("Font Selection")
                                .foregroundColor(.black)
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
                                .foregroundColor(.black)
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
                                .foregroundColor(.black)
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
                            .foregroundColor(.black)
                            .fontWeight(.bold)
                            .font(.system(size: 24))
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding(.top)
                            .padding(.bottom)

                        Text("Background Colour")
                            .foregroundColor(.black)
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
                        Text("Text to Speech")
                            .foregroundColor(.black)
                            .fontWeight(.bold)
                            .font(.system(size: 24))
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding(.top)
                            .padding(.bottom)

                        Group {
                            Text("Pitch")
                                .foregroundColor(.black)
                                .fontWeight(.bold)
                                .font(.system(size: 14))
                                .frame(maxWidth: .infinity, alignment: .leading)

                            Slider(value: $settings.pitch, in: 0...1)

                            Text("Volume")
                                .foregroundColor(.black)
                                .fontWeight(.bold)
                                .font(.system(size: 14))
                                .frame(maxWidth: .infinity, alignment: .leading)

                            Slider(value: $settings.volume, in: 0...1)

                            Text("Rate")
                                .foregroundColor(.black)
                                .fontWeight(.bold)
                                .font(.system(size: 14))
                                .frame(maxWidth: .infinity, alignment: .leading)

                            Slider(value: $settings.rate, in: 0...1)
                        }

                        Group {
                            Text("Accent")
                                .foregroundColor(.black)
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
                        // Resets settings back to default
                        settings.paragraphFontSize = 16;
                        settings.fontColour = .black
                        settings.isEnhancedReading = false
                        settings.paragraphFont = UIFont.systemFont(ofSize: 16)
                        settings.headingFont = UIFont.systemFont(ofSize: 24)
                        settings.backgroundColour = Color(hex: 0xFFF9F0, alpha: 1)
                        settings.volume = 1
                        settings.pitch = 1
                        settings.rate = 0.5
                        settings.voice = "en-GB"
                        
                    }, label: {
                        Text("Reset")
                            .textCase(.uppercase)
                            .foregroundColor(.white)
                            .font(.system(size: 14))
                            .fontWeight(.semibold)
                            .frame(maxWidth: .infinity)
                            .padding()
                    })
                        .frame(maxHeight: .infinity, alignment: .bottomLeading)
                        .tint(Color(hex: 0x19242D, alpha: 1))
                        .buttonStyle(.borderedProminent)
                    
                }
                    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
                    .padding()
            }
                .background(Color(hex: 0xFFF9F0, alpha: 1))
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
