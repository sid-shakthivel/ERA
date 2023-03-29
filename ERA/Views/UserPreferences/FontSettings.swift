//
//  FontSettings.swift
//  ERA
//
//  Created by Siddharth Shakthivel Muthu Pandian on 25/03/2023.
//

import SwiftUI

struct FontSettings: View {
    @EnvironmentObject var settings: UserPreferences
    
    @Binding var isShowingFontPicker: Bool
    @State var oldFontDescriptor = UIFontDescriptor(name: "Helvetica Neue", size: 24.0)
    
    var body: some View {
        Text("Font Settings")
            .fontWeight(.bold)
            .font(.system(size: 24))
            .frame(maxWidth: .infinity, alignment: .leading)
            .foregroundColor(.black)
            .invertOnDarkTheme()

        Group {
            Text("Enhanced Reading")
                .foregroundColor(.black)
                .fontWeight(.bold)
                .frame(maxWidth: .infinity, alignment: .leading)
                .font(.system(size: 14))
                .padding(.top)
                .invertOnDarkTheme()

            Picker("", selection: $settings.enhancedReadingStatus) {
                Text("Skim Mode")
                    .tag(EnhancedReadingStatus.Skim)
                    .foregroundColor(.black)
                    .invertOnDarkTheme()

                Text("Normal mode")
                    .tag(EnhancedReadingStatus.Normal)
                    .foregroundColor(.black)
                    .invertOnDarkTheme()

                Text("Off")
                    .tag(EnhancedReadingStatus.Off)
                    .foregroundColor(.black)
                    .invertOnDarkTheme()
            }
                .pickerStyle(.segmented)

            switch (settings.enhancedReadingStatus) {
            case .Off:
                Text(modifyText(state: settings.enhancedReadingStatus, text: "This text is just normal"))
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .foregroundColor(.black)
                    .invertOnDarkTheme()
            case .Normal:
                Text(modifyText(state: settings.enhancedReadingStatus, text: "Normal enahnced reading boldens the first half of every word"))
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .foregroundColor(.black)
                    .invertOnDarkTheme()
            case .Skim:
                Text(modifyText(state: settings.enhancedReadingStatus, text: "Skim enhanced reading boldens the first half of each important"))
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .foregroundColor(.black)
                    .invertOnDarkTheme()
            }
        }
            .onChange(of: settings.enhancedReadingStatus) { _ in
                settings.saveSettings(userPreferences: settings)
            }

        Group {
            Text("Font Selection")
                .foregroundColor(.black)
                .fontWeight(.bold)
                .font(.system(size: 14))
                .frame(maxWidth: .infinity, alignment: .leading)
                .invertOnDarkTheme()
                .padding(.top)

            Button(action: {
                isShowingFontPicker.toggle()
                settings.saveSettings(userPreferences: settings)
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
                .overlay(
                    RoundedRectangle(cornerRadius: 10)
                        .stroke(Color(hex: settings.isDarkMode ? 0xAB9D96 : 0xF2EDE4, alpha: 1), lineWidth: 1)
                )
        }
        
        Group {
            Toggle(isOn: $settings.isDyslexicFontOn, label: {
               Text("Dyslexic Font")
                   .foregroundColor(.black)
                   .invertOnDarkTheme()
                   .font(.system(size: 14, weight: .bold))
           })
            .onChange(of: settings.isDyslexicFontOn) { turnOnDyslexicFont in
               if (turnOnDyslexicFont) {
                   oldFontDescriptor = settings.paragraphFont.fontDescriptor

                   settings.paragraphFont = UIFont(name: "OpenDyslexicThree-Regular", size: CGFloat(settings.paragraphFontSize))!
                   settings.headingFont = UIFont(name: "OpenDyslexicThree-Bold", size: CGFloat(Double(settings.paragraphFontSize) * 1.5))!
                   settings.subheadingFont = UIFont(name: "OpenDyslexicThree-Regular", size: CGFloat(Double(settings.paragraphFontSize) * 1.25))!
                   settings.subParagaphFont = UIFont(name: "OpenDyslexicThree-Regular", size: CGFloat(Double(settings.paragraphFontSize) * 0.75))!
               } else {
                   settings.paragraphFont = UIFont(descriptor: oldFontDescriptor, size: CGFloat(settings.paragraphFontSize))
                   settings.headingFont = UIFont(descriptor: oldFontDescriptor, size: CGFloat(Double(settings.paragraphFontSize) * 1.5)).bold()
                   settings.subheadingFont = UIFont(descriptor: oldFontDescriptor, size: CGFloat(Double(settings.paragraphFontSize) * 1.25))
                   settings.subParagaphFont = UIFont(descriptor: oldFontDescriptor, size: CGFloat(Double(settings.paragraphFontSize) * 0.75))
               }
                
                settings.saveSettings(userPreferences: settings)
           }
       }

        Group {
            Text("Font Size")
                .foregroundColor(.black)
                .invertOnDarkTheme()
                .font(.system(size: 14, weight: .bold))
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
                    settings.saveSettings(userPreferences: settings)
                })
        }
        
        Group {
            Text("Font Colour")
                .foregroundColor(.black)
                .invertOnDarkTheme()
                .font(.system(size: 14, weight: .bold))
                .frame(maxWidth: .infinity, alignment: .leading)

            ColorPicker(selection: $settings.fontColour) {
                RoundedRectangle(cornerRadius: 5, style: .circular)
                    .fill(settings.fontColour)
                    .frame(width: 20, height: 20)
                    .overlay(
                        RoundedRectangle(cornerRadius: 5)
                            .stroke(Color(hex: settings.isDarkMode ? 0xAB9D96 : 0xF2EDE4, alpha: 1), lineWidth: 1)
                    )
                
            }
                .padding()
                .frame(maxWidth: .infinity, alignment: .leading)
                .invertBackgroundOnDarkTheme(isBase: false)
                .cornerRadius(10)
                .overlay(
                    RoundedRectangle(cornerRadius: 10)
                        .stroke(Color(hex: settings.isDarkMode ? 0xAB9D96 : 0xF2EDE4, alpha: 1), lineWidth: 1)
                )
                .onChange(of: settings.fontColour) { _ in
                    settings.saveSettings(userPreferences: settings)
                }
        }

        Group {
            Text("Line Spacing")
                .foregroundColor(.black)
                .invertOnDarkTheme()
                .font(.system(size: 14, weight: .bold))
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
                .overlay(
                    RoundedRectangle(cornerRadius: 10)
                        .stroke(Color(hex: settings.isDarkMode ? 0xAB9D96 : 0xF2EDE4, alpha: 1), lineWidth: 1)
                )
                .onChange(of: settings.lineSpacing) { _ in
                    settings.saveSettings(userPreferences: settings)
                }
        }
        
        Group {
            Text("Letter Spacing")
                .foregroundColor(.black)
                .invertOnDarkTheme()
                .font(.system(size: 14, weight: .bold))
                .frame(maxWidth: .infinity, alignment: .leading)

            Picker(selection: $settings.letterTracking, content: {
                ForEach(0...5, id: \.self) { number in
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
                .overlay(
                    RoundedRectangle(cornerRadius: 10)
                        .stroke(Color(hex: settings.isDarkMode ? 0xAB9D96 : 0xF2EDE4, alpha: 1), lineWidth: 1)
                )
                .onChange(of: settings.letterTracking) { _ in
                    settings.saveSettings(userPreferences: settings)
                }
        }
            
        Group {
            Text("Gradient Reader")
                .foregroundColor(.black)
                .invertOnDarkTheme()
                .font(.system(size: 14, weight: .bold))
                .frame(maxWidth: .infinity, alignment: .leading)

            HStack {
                Spacer()

                VStack {
                    Button(action: {
                        settings.gradientReaderStatus = .Classic
                        settings.saveSettings(userPreferences: settings)
                    }, label: {
                        Circle()
                            .foregroundStyle(
                                LinearGradient(
                                    colors: [.blue, .black, .red],
                                    startPoint: .leading,
                                    endPoint: .trailing
                                )
                            )
                            .frame(width: 50, height: 50)
                    })

                    Text("Classic")
                        .tag(GradientReaderStatus.Classic)
                        .foregroundColor(.black)
                        .invertOnDarkTheme()
                }

                Spacer()

                VStack {
                    Button(action: {
                        settings.gradientReaderStatus = .Gray
                        settings.saveSettings(userPreferences: settings)
                    }, label: {
                        Circle()
                            .foregroundStyle(
                                LinearGradient(
                                    colors: [.black, .gray],
                                    startPoint: .leading,
                                    endPoint: .trailing
                                )
                            )
                            .frame(width: 50, height: 50)
                    })

                    Text("Gray")
                        .tag(GradientReaderStatus.Gray)
                        .foregroundColor(.black)
                        .invertOnDarkTheme()
                }

                Spacer()
                
                VStack {
                    Button(action: {
                        settings.gradientReaderStatus = .Dark
                        settings.saveSettings(userPreferences: settings)
                    }, label: {
                        Circle()
                            .foregroundStyle(
                                LinearGradient(
                                    colors: [.blue, .brown],
                                    startPoint: .leading,
                                    endPoint: .trailing
                                )
                            )
                            .frame(width: 50, height: 50)
                    })

                    Text("Dark")
                        .tag(GradientReaderStatus.Dark)
                        .foregroundColor(.black)
                        .invertOnDarkTheme()
                }

                Spacer()

                VStack {
                    Button(action: {
                        settings.gradientReaderStatus = .Off
                        settings.saveSettings(userPreferences: settings)
                    }, label: {
                        Circle()
                            .fill(settings.fontColour)
                            .frame(width: 50, height: 50)
                    })

                    Text("Off")
                        .tag(GradientReaderStatus.Off)
                        .foregroundColor(.black)
                        .invertOnDarkTheme()
                }

                Spacer()
            }
        }
                                    
            Text("This is a an example sentence.")
                .foregroundColor(settings.fontColour)
                .font(Font(settings.paragraphFont))
                .tracking(CGFloat(settings.letterTracking))
                .lineSpacing(CGFloat(settings.lineSpacing))
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.top)
    }
}


