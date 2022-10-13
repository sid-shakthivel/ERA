//
//  Settings.swift
//  BionicReading
//
//  Created by Siddharth Shakthivel Muthu Pandian on 09/10/2022.
//

import SwiftUI

struct Settings: View {    
    @State var selectedFont: UIFontDescriptor
    
    @State private var isShowingFontPicker = false
    
    @EnvironmentObject var settings: UserCustomisations
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Text"), content: {
                    Toggle(isOn: $settings.isBionicReading, label: {
                        Text("Bionic Reading")
                    })

                    HStack {
                        Stepper(onIncrement: {
                            if (settings.selectedTextSize + 1 < 100) {
                                settings.selectedTextSize += 1
                                
                                settings.selectedFont = UIFont(descriptor: settings.selectedFont.fontDescriptor, size: CGFloat(settings.selectedTextSize))
                            }
                        }, onDecrement: {
                            if (settings.selectedTextSize - 1 > 0) {
                                settings.selectedTextSize -= 1
                                
                                settings.selectedFont = UIFont(descriptor: settings.selectedFont.fontDescriptor, size: CGFloat(settings.selectedTextSize))
                            }
                        }) {
                            Text("Size")
                        }
                        Spacer()
                        TextField("Enter Value", value: $settings.selectedTextSize, formatter: NumberFormatter())
                    }

                    HStack {
                        Button("Font", action: {
                            isShowingFontPicker.toggle()
                        })
                        Spacer()
                        Text(selectedFont.postscriptName)
                    }
                })

                Section(header: Text("Background"), content: {
                    ColorPicker("Colour", selection: $settings.selectedBackgroundColour)
                })

                Link(destination: URL(string: "https://www.instagram.com")!, label: {
                    Label("Follow Mindcore On Instagram", systemImage: "link")
                })
            }
            .navigationTitle("Settings")
            .sheet(isPresented: $isShowingFontPicker) {
                CustomFontPicker(selectedFont: $selectedFont, settings: _settings)
            }
        }
    }
}

struct Settings_Previews: PreviewProvider {
    static var previews: some View {
        Settings( selectedFont: UIFontDescriptor(name: "CourierNewPSMT", size: 20))
    }
}
