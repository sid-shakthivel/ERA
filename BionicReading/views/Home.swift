//
//  Home.swift
//  BionicReading
//
//  Created by Siddharth Shakthivel Muthu Pandian on 15/10/2022.
//

import SwiftUI

extension Color {
    init(hex: UInt, alpha: Double = 1) {
        self.init(
            .sRGB,
            red: Double((hex >> 16) & 0xff) / 255,
            green: Double((hex >> 08) & 0xff) / 255,
            blue: Double((hex >> 00) & 0xff) / 255,
            opacity: alpha
        )
    }
}


class ScanResult: ObservableObject {
    @Published var scannedTextList: [[String]] = []
    @Published var scannedText: String = "Amet minim mollit non deserunt ullamco est sit aliqua dolor do amet sint. Velit officia consequat duis enim velit mollit. Exercitation veniam consequat sunt nostrud amet."
}

struct Home: View {
    @State var showDocumentCameraView = false
    @StateObject var userSettings = UserCustomisations()
    @StateObject var scanResult = ScanResult()
    
    // Converts text to bionic reading format by bolding the first half of every word
    func convertToBionic(text: String) -> String {
        var modifiedText = text
        let boldIndex = Int(ceil(Double(text.count) / 2)) + 1
        modifiedText.insert("*", at: modifiedText.startIndex)
        modifiedText.insert("*", at: modifiedText.index(modifiedText.startIndex, offsetBy: 1))
        
        modifiedText.insert("*", at: modifiedText.index(modifiedText.startIndex, offsetBy: boldIndex + 1))
        modifiedText.insert("*", at: modifiedText.index(modifiedText.startIndex, offsetBy: boldIndex + 2))
        
        print(boldIndex)
        
        return modifiedText
    }
        
    //  If bionic reading is enabled, apply to each word within the string or return it
    func modifyText(text: String) -> LocalizedStringKey {
        if (userSettings.isBionicReading) {
            var markdownStringArray: [String] = []
            
            for substring in text.split(separator: " ") {
                markdownStringArray.append(convertToBionic(text: String(substring)))
            }

            return LocalizedStringKey(markdownStringArray.joined(separator: " "))
        }
        
        return LocalizedStringKey(text)
    }
    
    var body: some View {
        NavigationView {
            VStack {
                HStack {
                    Text("Easy Reading Assistant")
                        .foregroundColor(.black)
                        .fontWeight(.bold)
                        .textCase(.uppercase)

                    Spacer()
                    
                    NavigationLink(destination: Settings()) {
                        Image("setting")
                    }
                }
                .padding()
                
                Divider()
                
                Group {
                    ScrollView(.vertical, showsIndicators: true) {
                        if scanResult.scannedTextList.count < 1 {
                            Text(modifyText(text: "Document Heading"))
                                .foregroundColor(userSettings.fontColour)
                                .font(Font(userSettings.headingFont))
                                .fontWeight(.bold)
                            
                            Text(modifyText(text: "\(scanResult.scannedText)"))
                                .foregroundColor(userSettings.fontColour)
                                .font(Font(userSettings.font))
                                .lineSpacing(10)
                        } else {
                            //  Check whether text is a paragraph or heading by analysing paragraph line length
                            ForEach(scanResult.scannedTextList, id: \.self) { paragraph in
                                if paragraph.count > 1 {
                                    Text(modifyText(text: paragraph.joined(separator: " ")))
                                        .foregroundColor(userSettings.fontColour)
                                        .font(Font(userSettings.headingFont))
                                } else {
                                    Text(modifyText(text: paragraph[0]))
                                        .foregroundColor(userSettings.fontColour)
                                        .font(Font(userSettings.headingFont))
                                        .fontWeight(.bold)
                                }
                                
                                Text("")
                            }
                        }
                        
                        
                    }
                    .padding()
                    .background(userSettings.backgroundColor)
                }
                .padding()
                
                Group {
                    VStack {
                        Button {
                            showDocumentCameraView.toggle()
                        } label: {
                            HStack {
                                Image("scan")
                                
                                Text("Scan Document")
                                    .foregroundColor(.black)
                                    .textCase(.uppercase)
                                    .fontWeight(.semibold)
                                    .font(.system(size: 14))
                                
                                Image("arrow-right")
                                    .frame(maxWidth: .infinity, alignment: .trailing)
                            }
                            .padding()
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                        
                        Divider()
                            .padding(.horizontal, 30)
                        
                        Button {
                            
                        } label: {
                            HStack {
                                Image("upload")
                                
                                Text("Upload Document")
                                    .foregroundColor(.black)
                                    .fontWeight(.semibold)
                                    .textCase(.uppercase)
                                    .font(.system(size: 14))
                                
                                Image("arrow-right")
                                    .frame(maxWidth: .infinity, alignment: .trailing)
                            }
                                .padding()
                        }
                            .frame(maxWidth: .infinity, alignment: .leading)
                    }
                }
                    .background(Color.white)
            }
                .background(Color(hex: 0xFFF9F0, alpha: 1))
        }
            .environmentObject(userSettings)
            .environmentObject(scanResult)
            .navigationBarTitle("")
            .navigationBarBackButtonHidden(true)
            .navigationBarHidden(true)
            .sheet(isPresented: $showDocumentCameraView, content: {
                DocumentCameraView(settings: userSettings, scanResult: scanResult)
            })
    }
}

struct Home_Previews: PreviewProvider {
    static var previews: some View {
        Home()
    }
}
