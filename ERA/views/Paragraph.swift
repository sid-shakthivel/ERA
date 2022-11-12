//
//  Paragraph.swift
//  ERA
//
//  Created by Siddharth Shakthivel Muthu Pandian on 25/10/2022.
//

import SwiftUI
import AVFoundation
import NaturalLanguage

// Converts text to enhanced reading format by bolding the first half of every word
func enhanceText(text: String) -> String {
    var modifiedText = text
    
    let range = modifiedText.startIndex ..< modifiedText.endIndex
    let tagger = NLTagger(tagSchemes: [.lexicalClass])
    tagger.string = modifiedText
    
    tagger.enumerateTags(in: text.startIndex..<text.endIndex, unit: .word, scheme: .lemma) { tag, range in
        let stemForm = tag?.rawValue ?? String(text[range])
        print(stemForm, terminator: "")
        return true
    }
    
    let boldIndex = Int(ceil(Double(text.count) / 2)) + 1
    modifiedText.insert("*", at: modifiedText.startIndex)
    modifiedText.insert("*", at: modifiedText.index(modifiedText.startIndex, offsetBy: 1))
    
    modifiedText.insert("*", at: modifiedText.index(modifiedText.startIndex, offsetBy: boldIndex + 1))
    modifiedText.insert("*", at: modifiedText.index(modifiedText.startIndex, offsetBy: boldIndex + 2))
    
    return modifiedText
}

struct Paragraph: View {
    @Binding var paragraphFormat: TestingStuff
    @EnvironmentObject var userSettings: UserCustomisations
    @Binding var isEditingText: Bool
        
    // If enhanced reading is enabled, apply to each word within the string or return it
    func modifyText(text: String) -> LocalizedStringKey {
        if (userSettings.isEnhancedReading) {
            var markdownStringArray: [String] = []
            
            for substring in text.split(separator: " ") {
                markdownStringArray.append(enhanceText(text: String(substring)))
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
                Text(paragraphFormat.text)
                    .foregroundColor(userSettings.fontColour)
                    .font(Font(userSettings.headingFont))
                    .fontWeight(.bold)
                    .frame(maxWidth: .infinity, alignment: .leading)
            }
        } else {
            // Normal paragraph
            if isEditingText {
                ZStack {
                    TextEditor(text: $paragraphFormat.text)
                        .foregroundColor(userSettings.fontColour)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .scrollContentBackground(.hidden)
                        .background(userSettings.backgroundColour)
                        .font(Font(userSettings.paragraphFont))
                        .frame(minHeight: 500)
                }
                .toolbar {
                    ToolbarItemGroup(placement: .keyboard) {
                        Button {
                            isEditingText = false
                        } label: {
                            Text("Done")
                                .foregroundColor(.accentColor)
                                .padding(.trailing)
                        }
                    }
                }
                
//                TextField(paragraphFormat.text, text: $paragraphFormat.text, axis: .vertical)
//                    .textFieldStyle(.roundedBorder)
            } else {
                Text(modifyText(text: paragraphFormat.text))
                    .foregroundColor(userSettings.fontColour)
                    .font(Font(userSettings.paragraphFont))
                    .frame(maxWidth: .infinity, alignment: .leading)
            }
        }
    }
}

struct Paragraph_Previews: PreviewProvider {
    static var previews: some View {
        Paragraph(paragraphFormat: .constant(TestingStuff(text: "Hello World", isHeading: false)), isEditingText: .constant(false))
    }
}
