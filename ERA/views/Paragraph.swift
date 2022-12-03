//
//  Paragraph.swift
//  ERA
//
//  Created by Siddharth Shakthivel Muthu Pandian on 25/10/2022.
//

import SwiftUI
import AVFoundation

struct Paragraph: View {
    @Binding var paragraphFormat: SavedParagraph
    @Binding var isEditingText: Bool
    @State var textToEdit: String
    
    @EnvironmentObject var userSettings: UserPreferences
    @EnvironmentObject var scanResult: ScanResult
    
    
//    init(paragraphFormat: SavedParagraph, isEditingText: Bool, textToEdit: String) {
//        if #unavailable(iOS 16.0) {
//            UITextView.appearance().backgroundColor = .clear
//        }
//    }
    
    var body: some View {
        Group {
            if paragraphFormat.isHeading {
                // Heading
                if isEditingText {
                    TextField(textToEdit, text: $textToEdit)
                        .foregroundColor(userSettings.fontColour)
                        .font(Font(userSettings.headingFont))
                        .onChange(of: textToEdit) { newValue in
                            paragraphFormat.text = newValue
                        }
                } else {
                    if #available(iOS 16.0, *) {
                        Text(paragraphFormat.text)
                            .foregroundColor(userSettings.fontColour)
                            .font(Font(userSettings.headingFont))
                            .tracking(CGFloat(userSettings.letterSpacing))
                            .frame(maxWidth: .infinity, alignment: .leading)
                    } else {
                        Text(paragraphFormat.text)
                            .foregroundColor(userSettings.fontColour)
                            .font(Font(userSettings.headingFont))
                            .frame(maxWidth: .infinity, alignment: .leading)
                    }
                }
            } else {
                // Normal paragraph
                if isEditingText {
                    if #available(iOS 16.0, *) {
                        TextField("", text: $textToEdit, axis: .vertical)
                            .foregroundColor(userSettings.fontColour)
                            .background(userSettings.backgroundColour)
                            .tracking(CGFloat(userSettings.letterSpacing))
                            .lineSpacing(CGFloat(userSettings.lineSpacing))
                            .font(Font(userSettings.paragraphFont))
                    } else {
                        TextEditor(text: $textToEdit)
                            .foregroundColor(userSettings.fontColour)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .clearListBackground()
                            .background(userSettings.backgroundColour)
                            .font(Font(userSettings.paragraphFont))
                            .lineSpacing(CGFloat(userSettings.lineSpacing))
                            .frame(minHeight: 500)
                    }
                } else {
                    if #available(iOS 16.0, *) {
                        Text(modifyText(state: userSettings.enhancedReadingStatus, text: paragraphFormat.text))
                            .foregroundColor(userSettings.fontColour)
                            .font(Font(userSettings.paragraphFont))
                            .lineSpacing(CGFloat(userSettings.lineSpacing))
                            .tracking(CGFloat(userSettings.letterSpacing))
                            .frame(maxWidth: .infinity, alignment: .leading)
                    } else {
                        Text(modifyText(state: userSettings.enhancedReadingStatus, text: paragraphFormat.text))
                            .foregroundColor(userSettings.fontColour)
                            .font(Font(userSettings.paragraphFont))
                            .lineSpacing(CGFloat(userSettings.lineSpacing))
                            .frame(maxWidth: .infinity, alignment: .leading)
                    }
                }
            }
        }
            .onChange(of: isEditingText) { newValue in
                if !newValue {
                    // If user goes from editing text to not editing text, the modified text needs to be altered
                    DispatchQueue.main.async {
                        let oldParagraphText = paragraphFormat.text
                        paragraphFormat.text = String(textToEdit)
                        
                        // Scanned text must be altered too by replacing the paragraph with the edited version
                        if !paragraphFormat.isHeading {
                            let text = scanResult.scannedText.replacingOccurrences(of: oldParagraphText, with: textToEdit)
                            scanResult.scannedText = text
                        }
                    }
                } else {
                    UITextView.appearance().backgroundColor = .clear
                }
            }
    }
}

//struct Paragraph_Previews: PreviewProvider {
//    static var previews: some View {
//        Paragraph(paragraphFormat: .constant(SavedParagraph(text: "Hello World", isHeading: false)), isEditingText: .constant(false), textToEdit: "Hello World")
//    }
//}
