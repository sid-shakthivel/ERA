//
//  Paragraph.swift
//  ERA
//
//  Created by Siddharth Shakthivel Muthu Pandian on 25/10/2022.
//

import SwiftUI
import AVFoundation
import MLKitTranslate

extension Array {
    func replicateUpTo(numberOfElements: UInt) -> [Element] {
        if Int(numberOfElements) < count {
            return Array(self[0..<Int(numberOfElements)])
        } else {
            var result = self
            (0..<(Int(numberOfElements)/result.count)-1).forEach({ _ in result += self})
            return result + self[0..<(Int(numberOfElements) - (Int(numberOfElements)/count) * count)]
        }
    }
}



struct Paragraph: View {
    @Binding var paragraphFormat: SavedParagraph
    @Binding var isEditingText: Bool
    @Binding var shouldTranslateText: Bool
    @Binding var currentTranslator: Translator
    
    @State var text: String
    
    @EnvironmentObject var userSettings: UserPreferences
    @EnvironmentObject var scanResult: ScanResult
    
    var width: Double
    @State var sentences: [String]
    
    func getGradient(index: Int) -> [Color] {
        let val = index % 4
        
        if (userSettings.gradientReaderStatus == .Classic) {
            switch val {
            case 0:
                return [.black, .blue]
            case 1:
                return [.blue, .black]
            case 2:
                return [.black, .red]
            case 3:
                return [.red, .black]
            default:
                return [.black, .blue]
            }
        } else if (userSettings.gradientReaderStatus == .Gray) {
            switch val {
            case 0:
                return [.black, .gray]
            case 1:
                return [.gray, .black]
            case 2:
                return [.black, Color(uiColor: UIColor.lightGray)]
            case 3:
                return [Color(uiColor: UIColor.lightGray), .black]
            default:
                return [.black, .blue]
            }
        } else if (userSettings.gradientReaderStatus == .Dark) {
            switch val {
            case 0:
                return [.black, .blue]
            case 1:
                return [.blue, .black]
            case 2:
                return [.black, .brown]
            case 3:
                return [.brown, .black]
            default:
                return [.black, .blue]
            }
        }
        
        return [.black]
    }
    
    var body: some View {
        Group {
            if paragraphFormat.isHeading {
                // Heading
                if isEditingText {
                    TextField(text, text: $text)
                        .foregroundColor(userSettings.fontColour)
                        .font(Font(userSettings.headingFont))
                        .onChange(of: text) { newValue in
                            paragraphFormat.text = newValue
                        }
                } else {
                    if #available(iOS 16.0, *) {
                        Text(text)
                            .foregroundColor(userSettings.fontColour)
                            .font(Font(userSettings.headingFont))
                            .tracking(CGFloat(userSettings.letterTracking))
                            .frame(maxWidth: .infinity, alignment: .leading)
                    } else {
                        Text(text)
                            .foregroundColor(userSettings.fontColour)
                            .font(Font(userSettings.headingFont))
                            .frame(maxWidth: .infinity, alignment: .leading)
                    }
                }
            } else {
                // Normal paragraph
                if isEditingText {
                    if #available(iOS 16.0, *) {
                        TextField("", text: $text, axis: .vertical)
                            .foregroundColor(userSettings.fontColour)
                            .background(userSettings.backgroundColour)
                            .tracking(CGFloat(userSettings.letterTracking))
                            .lineSpacing(CGFloat(userSettings.lineSpacing))
                            .font(Font(userSettings.paragraphFont))
                    } else {
                        TextEditor(text: $text)
                            .foregroundColor(userSettings.fontColour)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .clearListBackground()
                            .background(userSettings.backgroundColour)
                            .font(Font(userSettings.paragraphFont))
                            .lineSpacing(CGFloat(userSettings.lineSpacing))
                            .frame(minHeight: 500)
                    }
                } else {
                    if userSettings.gradientReaderStatus == .Off {
                        if #available(iOS 16.0, *) {
                            Text(modifyText(state: userSettings.enhancedReadingStatus, text: text))
                                .font(Font(userSettings.paragraphFont))
                                .lineSpacing(CGFloat(userSettings.lineSpacing))
                                .tracking(CGFloat(userSettings.letterTracking))
                                .frame(maxWidth: .infinity, alignment: .leading)
                        } else {
                            Text(modifyText(state: userSettings.enhancedReadingStatus, text: text))
                                .foregroundColor(userSettings.fontColour)
                                .font(Font(userSettings.paragraphFont))
                                .lineSpacing(CGFloat(userSettings.lineSpacing))
                                .frame(maxWidth: .infinity, alignment: .leading)
                        }
                    } else {
                        ForEach(sentences, id: \.self) { sentence in
                            if #available(iOS 16.0, *) {
                                Text(modifyText(state: userSettings.enhancedReadingStatus, text: sentence.trimmingCharacters(in: .whitespacesAndNewlines)))
                                    .foregroundStyle(
                                        LinearGradient(
                                            colors: getGradient(index: sentences.firstIndex(of: sentence)!),
                                            startPoint: .leading,
                                            endPoint: .trailing
                                        )
                                    )
                                    .font(Font(userSettings.paragraphFont))
                                    .multilineTextAlignment(.leading)
                                    .lineSpacing(CGFloat(userSettings.lineSpacing))
                                    .tracking(CGFloat(userSettings.letterTracking))
                                    .frame(maxWidth: .infinity, alignment: .leading)
                            } else {
                                Text(modifyText(state: userSettings.enhancedReadingStatus, text: sentence.trimmingCharacters(in: .whitespacesAndNewlines)))
                                    .foregroundColor(userSettings.fontColour)
                                    .multilineTextAlignment(.leading)
                                    .font(Font(userSettings.paragraphFont))
                                    .lineSpacing(CGFloat(userSettings.lineSpacing))
                                    .frame(maxWidth: .infinity, alignment: .leading)
                            }
                        }
                    }
                }
            }
        }
                .onChange(of: isEditingText) { newValue in
                        if !newValue {
                            // If user goes from editing text to not editing text, the modified text needs to be altered
                            DispatchQueue.main.async {
                                let oldParagraphText = paragraphFormat.text
                                paragraphFormat.text = String(text)
                                
                                // Scanned text must be altered too by replacing the paragraph with the edited version
                                if !paragraphFormat.isHeading {
                                    let tempText = scanResult.scannedText.replacingOccurrences(of: oldParagraphText, with: text)
                                    scanResult.scannedText = tempText
                                }
                                
                                sentences = getSentences(text: text, width: width, fontWidth: CGFloat(userSettings.paragraphFontSize))
                            }
                        } else {
                            UITextView.appearance().backgroundColor = .clear
                        }
                    }
                .onChange(of: shouldTranslateText) { newValue in
                    if (newValue) {
                        currentTranslator.translate(paragraphFormat.text) { translatedText, error in
                            text = translatedText ?? "Error with translation"
                        }
                    } else {
                        text = paragraphFormat.text
                    }
                }
                .onChange(of: userSettings.paragraphFont) { _ in
                    sentences = getSentences(text: text, width: width, fontWidth: CGFloat(userSettings.paragraphFontSize))
                }
    }
}
