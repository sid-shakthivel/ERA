//
//  Paragraph.swift
//  BionicReading
//
//  Created by Siddharth Shakthivel Muthu Pandian on 25/10/2022.
//

import SwiftUI
import AVFoundation

struct LabelRepresented: UIViewRepresentable {
    var text : NSAttributedString?
    var width: CGFloat
    @Binding var font: UIFont
    var colour: UIColor
    var isHeading: Bool
    
    func makeUIView(context: Context) -> UILabel {
        let label = UILabel()
        label.lineBreakMode = .byWordWrapping
        label.numberOfLines = 0
        label.preferredMaxLayoutWidth = width
        label.font = font
        label.textColor = colour
        label.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
        return label
    }
    
    func updateUIView(_ uiView: UILabel, context: Context) {
        uiView.font = font
        uiView.attributedText = text
        uiView.textColor = colour
    }
}

class Speaker: NSObject, ObservableObject, AVSpeechSynthesizerDelegate {
    let synth = AVSpeechSynthesizer()
    @Published var label: NSAttributedString? // <- change to AttributedString
    
    override init() {
        super.init()
        synth.delegate = self
    }

    func speak(_ string: String) {
        let utterance = AVSpeechUtterance(string: string)
        utterance.voice = AVSpeechSynthesisVoice(language: "en-GB")
        utterance.rate = 0.4
        synth.speak(utterance)
    }
    
    // Functions to highlight text
    func speechSynthesizer(_ synthesizer: AVSpeechSynthesizer, willSpeakRangeOfSpeechString characterRange: NSRange, utterance: AVSpeechUtterance)
    {
        let mutableAttributedString = NSMutableAttributedString(string: utterance.speechString)
        mutableAttributedString.addAttribute(.backgroundColor, value: UIColor.red, range: characterRange)
        label = mutableAttributedString
    }

    func speechSynthesizer(_ synthesizer: AVSpeechSynthesizer, didFinish utterance: AVSpeechUtterance) {
        label = NSAttributedString(string: utterance.speechString)
    }
}

struct Paragraph: View {
    @State var isHeading: Bool
    @State var text: String
    
    @ObservedObject var speaker = Speaker()
    @EnvironmentObject var userSettings: UserCustomisations
    
    // Converts text to enhanced reading format by bolding the first half of every word
    func convertToEnhanced(text: String) -> String {
        var modifiedText = text
        let boldIndex = Int(ceil(Double(text.count) / 2)) + 1
        modifiedText.insert("*", at: modifiedText.startIndex)
        modifiedText.insert("*", at: modifiedText.index(modifiedText.startIndex, offsetBy: 1))
        
        modifiedText.insert("*", at: modifiedText.index(modifiedText.startIndex, offsetBy: boldIndex + 1))
        modifiedText.insert("*", at: modifiedText.index(modifiedText.startIndex, offsetBy: boldIndex + 2))
        
        return modifiedText
    }
        
    //  If enhanced reading is enabled, apply to each word within the string or return it
    func modifyText(attributedText: NSAttributedString) -> NSAttributedString {
        if (userSettings.isBionicReading) {
            var text = attributedText.string
            var markdownStringArray: [String] = []

            for substring in text.split(separator: " ") {
                markdownStringArray.append(convertToEnhanced(text: String(substring)))
            }
            
            var joinedString =  String(markdownStringArray.joined(separator: " "))
           
            do {
                var attributedJoined = try NSAttributedString(markdown: joinedString)
            } catch {
                return NSAttributedString("Unknown Error")
            }
        }
        
        return attributedText
    }
    
    var body: some View {
        GeometryReader { geometry in
            if isHeading {
                // Heading
                LabelRepresented(text: speaker.label, width: geometry.size.width, font: $userSettings.headingFont, colour: UIColor(userSettings.fontColour), isHeading: true)
                    .foregroundColor(userSettings.fontColour)
                    .font(Font(userSettings.headingFont))
                    .fontWeight(.bold)
                    .onTapGesture(count: 2) {
                        speaker.speak(text)
                    }
                    .onAppear() {
                        speaker.label = try? NSMutableAttributedString(markdown: text)
                    }
            } else {
                // Normal paragraph
                LabelRepresented(text: modifyText(attributedText: speaker.label ?? NSAttributedString("Unknown Error")), width: geometry.size.width, font: $userSettings.font, colour: UIColor(userSettings.fontColour), isHeading: false)
                    .foregroundColor(userSettings.fontColour)
                    .font(Font(userSettings.font))
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .onTapGesture(count: 2) {
                        speaker.speak(text)
                    }
                    .onAppear() {
                        speaker.label = try? NSMutableAttributedString(markdown: text)
                    }
            }
        }
        .padding(.bottom)
    }
}

struct Paragraph_Previews: PreviewProvider {
    static var previews: some View {
        Paragraph(isHeading: false, text: "Hello There")
    }
}
