//
//  Paragraph.swift
//  ERA
//
//  Created by Siddharth Shakthivel Muthu Pandian on 25/10/2022.
//

import SwiftUI
import AVFoundation

struct Paragraph: View {
    @Binding var paragraphFormat: RetrievedParagraph
    @EnvironmentObject var userSettings: UserPreferences
    @Binding var isEditingText: Bool
    
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
                Text(modifyText(condition: userSettings.isDarkMode, text: paragraphFormat.text))
                    .foregroundColor(userSettings.fontColour)
                    .font(Font(userSettings.paragraphFont))
                    .lineSpacing(CGFloat(userSettings.lineSpacing))
                    .frame(maxWidth: .infinity, alignment: .leading)
            }
        }
    }
}

struct Paragraph_Previews: PreviewProvider {
    static var previews: some View {
        Paragraph(paragraphFormat: .constant(RetrievedParagraph(text: "Hello World", isHeading: false)), isEditingText: .constant(false))
    }
}
