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
    
    var body: some View {
        Group {
            if paragraphFormat.isHeading {
                // Heading
                if isEditingText {
                    TextField(textToEdit, text: $textToEdit)
                        .foregroundColor(userSettings.fontColour)
                        .font(Font(userSettings.headingFont))
                        .fontWeight(.bold)
                        .tracking(CGFloat(userSettings.letterSpacing))
                        .onChange(of: textToEdit) { newValue in
                            paragraphFormat.text = newValue
                        }
                } else {
                    Text(paragraphFormat.text)
                        .foregroundColor(userSettings.fontColour)
                        .font(Font(userSettings.headingFont))
                        .tracking(CGFloat(userSettings.letterSpacing))
                        .fontWeight(.bold)
                        .frame(maxWidth: .infinity, alignment: .leading)
                }
            } else {
                // Normal paragraph
                if isEditingText {
                    ZStack {
                        TextEditor(text: $textToEdit)
                            .foregroundColor(userSettings.fontColour)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .scrollContentBackground(.hidden)
                            .background(userSettings.backgroundColour)
                            .tracking(CGFloat(userSettings.letterSpacing))
                            .font(Font(userSettings.paragraphFont))
                            .frame(minHeight: 500)
                    }
                } else {
                    Text(modifyText(condition: userSettings.isEnhancedReading, text: paragraphFormat.text))
                        .foregroundColor(userSettings.fontColour)
                        .font(Font(userSettings.paragraphFont))
                        .lineSpacing(CGFloat(userSettings.lineSpacing))
                        .tracking(CGFloat(userSettings.letterSpacing))
                        .frame(maxWidth: .infinity, alignment: .leading)
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
                            
                            print(scanResult.scannedText)
                        }
                    }
                }
            }
    }
}

//struct Paragraph_Previews: PreviewProvider {
//    static var previews: some View {
//        Paragraph(paragraphFormat: .constant(SavedParagraph(text: "Hello World", isHeading: false)), isEditingText: .constant(false), textToEdit: "Hello World")
//    }
//}
