//
//  Settings.swift
//  BionicReading
//
//  Created by Siddharth Shakthivel Muthu Pandian on 09/10/2022.
//

import SwiftUI

class UserCustomisations: ObservableObject {
    @Published var fontSize: Int = 16
    
    @Published var fontColour: Color = .black
    @Published var isBionicReading: Bool = false
    
    @Published var font: UIFont = UIFont.systemFont(ofSize: 16)
    @Published var headingFont: UIFont = UIFont.systemFont(ofSize: 24)
    
    @Published var backgroundColour: Color = Color(hex: 0xFFF9F0, alpha: 1)
}

struct Settings: View {
    @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>
    @State private var isShowingFontPicker = false
    @EnvironmentObject var settings: UserCustomisations
    
    var body: some View {
        NavigationView {
            VStack {
                HStack {
                    Button {
                        presentationMode.wrappedValue.dismiss()
                    } label: {
                        Image("arrow-left")
                    }


                    Text("Settings")
                        .foregroundColor(.black)
                        .font(.system(size: 14))
                        .fontWeight(.bold)
                        .textCase(.uppercase)
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
                            Toggle(isOn: $settings.isBionicReading, label: {
                                Text("Bionic Reading")
                                    .foregroundColor(.black)
                                    .fontWeight(.bold)
                                    .font(.system(size: 14))
                            })
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
                                    Text("\(settings.font.fontName)")
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

                            Picker(selection: $settings.fontSize, content: {
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
                                .background(Color(hex: 0xFFFFFF, alpha: 1))
                                .border(Color(hex: 0xF2EDE4, alpha: 1), width: 1)
                                .onChange(of: settings.fontSize, perform: { newFontSize in
                                    settings.font = UIFont(descriptor: settings.font.fontDescriptor, size: CGFloat(settings.fontSize))
                                    
                                    settings.headingFont = UIFont(descriptor: settings.font.fontDescriptor, size: CGFloat(Double(settings.fontSize) * 1.5))
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
    
                    Button(action: {
                        // Resets settings back to default
                        
                        settings.fontSize = 16;
                        settings.fontColour = .black
                        settings.isBionicReading = false
                        settings.font = UIFont.systemFont(ofSize: 16)
                        settings.headingFont = UIFont.systemFont(ofSize: 24)
                        settings.backgroundColour = Color(hex: 0xFFF9F0, alpha: 1)
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
                    CustomFontPicker(settings: _settings)
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
