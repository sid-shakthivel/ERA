//
//  Scan.swift
//  BionicReading
//
//  Created by Siddharth Shakthivel Muthu Pandian on 09/10/2022.
//

import SwiftUI
import AVFoundation
import PDFKit

struct Scan: View {
    
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
    
    func modifyText(text: String) -> LocalizedStringKey {
        if (settings.isBionicReading) {
            // Make a new markdown array
            var markdownStringArray: [String] = []
            
            // Apply bionic reading to each word within the string
            for substring in text.split(separator: " ") {
                markdownStringArray.append(convertToBionic(text: String(substring)))
            }
            
            // Create a localised string which allows markdown
            return LocalizedStringKey(markdownStringArray.joined(separator: " "))
        }
        
        return LocalizedStringKey(text)
    }
    
    @State var showDocumentCameraView: Bool = false
    @State var scanText: AttributedString
    
    @EnvironmentObject var settings: UserCustomisations
    
    @State var pdfDocument: PDFDocument?
    
    let speechSynthesizer = AVSpeechSynthesizer()
    
    var body: some View {
        VStack {
            Text(scanText)
                .font(Font(settings.selectedFont))
            
            if pdfDocument != nil {
                CustomPDFView(pdfDocument!)
            } else {
                Text("Lorem ipsum dolor sit amet, consectetur adipiscing elit. Nulla dignissim dolor in augue gravida tempus. Phasellus orci dui, maximus vitae urna vel, tempor mollis quam. Nunc sed magna in sapien feugiat sodales id ut arcu. Sed nunc justo, vulputate at tincidunt nec, faucibus a nibh.")
                    .font(Font(settings.selectedFont))
            }
            
            Button("Scan Document") {
                showDocumentCameraView.toggle()
            }
            
//            Button("Listen") {
//                let utterance = AVSpeechUtterance(string: scanText)
//                utterance.pitchMultiplier = 1.0
//                utterance.rate = 0.5
//                utterance.voice = AVSpeechSynthesisVoice(language: "hi-IN")
//
//                speechSynthesizer.speak(utterance)
//            }
            
        }
        .sheet(isPresented: $showDocumentCameraView, content: {
            DocumentCameraView(scanText: $scanText, settings: _settings, pdfDocument: $pdfDocument)
        })
    }
}

struct Scan_Previews: PreviewProvider {
    static var previews: some View {
        Scan(showDocumentCameraView: false, scanText: "", pdfDocument: nil)
    }
}
