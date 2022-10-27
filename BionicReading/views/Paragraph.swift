//
//  Paragraph.swift
//  BionicReading
//
//  Created by Siddharth Shakthivel Muthu Pandian on 25/10/2022.
//

import SwiftUI
import AVFoundation

struct Paragraph: View {
    @Binding var paragraphFormat: ParagraphFormat
    @EnvironmentObject var userSettings: UserCustomisations
    @Binding var isEditingText: Bool
    
    @State var testString: String = "hello thereeee"
    
    let synth = AVSpeechSynthesizer()
    
    // Converts text to enhanced reading format by bolding the first half of every word
    func convertToBionic(text: String) -> String {
        var modifiedText = text
        let boldIndex = Int(ceil(Double(text.count) / 2)) + 1
        modifiedText.insert("*", at: modifiedText.startIndex)
        modifiedText.insert("*", at: modifiedText.index(modifiedText.startIndex, offsetBy: 1))
        
        modifiedText.insert("*", at: modifiedText.index(modifiedText.startIndex, offsetBy: boldIndex + 1))
        modifiedText.insert("*", at: modifiedText.index(modifiedText.startIndex, offsetBy: boldIndex + 2))
        
        return modifiedText
    }
        
    //  If enhanced reading is enabled, apply to each word within the string or return it
    func modifyText(text: String) -> LocalizedStringKey {
        if (userSettings.isEnhancedReading) {
            var markdownStringArray: [String] = []
            
            for substring in text.split(separator: " ") {
                markdownStringArray.append(convertToBionic(text: String(substring)))
            }

            return LocalizedStringKey(markdownStringArray.joined(separator: " "))
        }
        
        return LocalizedStringKey(text)
    }
    
    var body: some View {
        if paragraphFormat.isHeading {
            // Heading
            if isEditingText {
                TextField(paragraphFormat.text, text: $paragraphFormat.text)
                    .foregroundColor(userSettings.fontColour)
                    .font(Font(userSettings.headingFont))
                    .fontWeight(.bold)
            } else {
                Text(modifyText(text: paragraphFormat.text))
                    .foregroundColor(userSettings.fontColour)
                    .font(Font(userSettings.headingFont))
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .onTapGesture {
//                        let utterance = AVSpeechUtterance(string: paragraphFormat.text)
//                        utterance.voice = AVSpeechSynthesisVoice(language: userSettings.accent)
//                        self.synth.speak(utterance)
                        
                        print(paragraphFormat)
                    }
            }
        } else {
            // Normal paragraph
            if isEditingText {
                ZStack() {
                    TextEditor(text: $paragraphFormat.text)
                        .foregroundColor(userSettings.fontColour)
                        .scrollContentBackground(.hidden)
                        .background(userSettings.backgroundColour)
                        .font(Font(userSettings.font))
                        .frame(maxHeight: .infinity, alignment: .leading)
                        
                    Text(modifyText(text: paragraphFormat.text))
                        .font(Font(userSettings.font))
                        .foregroundColor(userSettings.fontColour)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .opacity(0)
                }
                .cornerRadius(5)
            } else {
                Text(modifyText(text: paragraphFormat.text))
                    .foregroundColor(userSettings.fontColour)
                    .font(Font(userSettings.font))
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .onTapGesture {
//                        let utterance = AVSpeechUtterance(string: paragraphFormat.text)
//                        utterance.voice = AVSpeechSynthesisVoice(language: userSettings.accent)
//                        self.synth.speak(utterance)
                        
                        print(paragraphFormat)
                    }
            }
        }
    }
}

struct Paragraph_Previews: PreviewProvider {
    static var previews: some View {
        Paragraph(paragraphFormat: .constant(ParagraphFormat(text: "Hello World", isHeading: false)), isEditingText: .constant(false))
    }
}
