//
//  Utils.swift
//  ERA
//
//  Created by Siddharth Shakthivel Muthu Pandian on 03/11/2022.
//

import Foundation
import UniformTypeIdentifiers
import SwiftUI
import PDFKit
import AVFoundation
import NaturalLanguage

struct ColourConstants {
    static let lightModeBackground = Color(hex: 0xFFF9F0, alpha: 1)
    static let darkModeBackground = Color(hex: 0x0B1F29, alpha: 1)
    static let lightModeLighter = Color(hex: 0xFFFFFF, alpha: 1)
    static let darkModeLighter = Color(hex: 0x061015, alpha: 1)
}

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

struct InvertOnThemeChange: ViewModifier {
    @EnvironmentObject var userPreferences: UserPreferences

    func body(content: Content) -> some View {
        if (userPreferences.isDarkMode) {
            content.colorInvert()
        } else{
            content
        }
    }
}

struct BackgroundThemeChange: ViewModifier {
    @EnvironmentObject var userPreferences: UserPreferences
    
    func body(content: Content) -> some View {
        if (userPreferences.isDarkMode) {
            content
                .listRowBackground(ColourConstants.darkModeBackground)
                .background(ColourConstants.darkModeBackground)
        }
        else {
            content
                .listRowBackground(ColourConstants.lightModeBackground)
                .background(ColourConstants.lightModeBackground)
        }
    }
}

extension View {
    func invertOnDarkTheme() -> some View {
        modifier(InvertOnThemeChange())
    }
    
    func invertBackgroundOnDarkTheme() -> some View {
        modifier(BackgroundThemeChange())
    }
}

extension UIColor {
    var inverted: UIColor {
        var r: CGFloat = 0.0, g: CGFloat = 0.0, b: CGFloat = 0.0, a: CGFloat = 0.0
        self.getRed(&r, green: &g, blue: &b, alpha: &a)
        return UIColor(red: (1 - r), green: (1 - g), blue: (1 - b), alpha: a) // Assuming you want the same alpha value.
    }
}

/*
 Takes a string and boldens first half of word if it meets requirements
 */
func enhanceWord(word: String) -> String {
    var mutWord = word
    
    /*
     Word must be over 3 characters to be important
     */
    if mutWord.count > 3 {
        // Perform NLP to determine word class as only important words such as nouns, verbs, and adverbs should be boldened
        let tagger = NLTagger(tagSchemes: [.lexicalClass])
        
        tagger.string = mutWord
        let tag = tagger.tag(at: mutWord.startIndex, unit: .word, scheme: .lexicalClass)
        
        if tag.0?.rawValue == "Noun" || tag.0?.rawValue == "Verb" || tag.0?.rawValue == "Adverb" || tag.0?.rawValue == "Adjective" || tag.0?.rawValue == "OtherWord" {
            let boldIndex = Int(ceil(Double(mutWord.count) / 2)) + 1
            mutWord.insert("*", at: mutWord.startIndex)
            mutWord.insert("*", at: mutWord.index(mutWord.startIndex, offsetBy: 1))
            
            mutWord.insert("*", at: mutWord.index(mutWord.startIndex, offsetBy: boldIndex + 1))
            mutWord.insert("*", at: mutWord.index(mutWord.startIndex, offsetBy: boldIndex + 2))
        }
    }
    
    return mutWord
}

/*
 For a specific condition, perform enhanced reading algorithm upon every word
 */
func modifyText(condition: Bool, text: String) -> LocalizedStringKey {
    if condition {
        var markdownStringArray: [String] = []
        
        for substring in text.split(separator: " ") {
            markdownStringArray.append(enhanceWord(word: String(substring)))
        }

        return LocalizedStringKey(markdownStringArray.joined(separator: " "))
    } else {
        return LocalizedStringKey(text)
    }
}

struct PDFDoc: FileDocument {
    // Tell the system we support only plain text
    static var readableContentTypes = [UTType.pdf]

    var url = ""

    // Simple initializer that creates new, empty documents
    init(fileUrl: URL) {
        self.url = fileUrl.path
    }

    // Initializer loads data that has been saved previously
    init(configuration: ReadConfiguration) throws {
        url = ""
    }

    // Called when the system wants to write our data to disk
    func fileWrapper(configuration: WriteConfiguration) throws -> FileWrapper {
        let file = try FileWrapper(url: URL(fileURLWithPath: url), options: .immediate)
        return file
    }
}

/*
 Converts a swiftui view into a pdf which can be saved
 */
func convertScreenToPDF() -> PDFDoc {
    let outputFileURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!.appendingPathComponent("Example.pdf")
   let pageSize = CGSize(width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height)
   let rootVC = UIApplication.shared.windows.first?.rootViewController
    
    // Render the pdf
    let pdfRenderer = UIGraphicsPDFRenderer(bounds: CGRect(origin: .zero, size: pageSize))
    
    DispatchQueue.main.async {
        do {
            try pdfRenderer.writePDF(to: outputFileURL, withActions: { (context) in
                context.beginPage()
                rootVC?.view.layer.render(in: context.cgContext)
            })
        } catch {
            
        }
    }
    
    return PDFDoc(fileUrl: outputFileURL)
}

/*
 Converts a local PDF file into an array of UIImages which can be fed into convertPhotosToParagraphs
 */
func convertPDFToImages(url: URL) -> [UIImage] {
    var images: [UIImage] = []
    _ = url

    guard url.startAccessingSecurityScopedResource() else {
        print("Error: could not access content of url: \(url)")
        return images
    }

    guard let document = CGPDFDocument(url as CFURL) else {
        return images
    }
    
    // Loop through the first 10 pages within the PDF and create an array of images
    for i in 1...10 {
        guard let page = document.page(at: i) else {
            return images
        }
        
        let pageRect = page.getBoxRect(.mediaBox)
        let renderer = UIGraphicsImageRenderer(size: pageRect.size)
        
        let img = renderer.image { ctx in
            UIColor.white.set()
            ctx.fill(pageRect)

            ctx.cgContext.translateBy(x: 0.0, y: pageRect.size.height)
            ctx.cgContext.scaleBy(x: 1.0, y: -1.0)

            ctx.cgContext.drawPDFPage(page)
        }
        images.append(img)
    }

    return images
}


func encodeColor(colour: Color) throws -> Data {
    let uiColour = UIColor(colour)
    return try NSKeyedArchiver.archivedData(
        withRootObject: uiColour,
        requiringSecureCoding: true
    )
}

func decodeColor(from data: Data) throws -> Color {
    let uiColour = try NSKeyedUnarchiver
            .unarchiveTopLevelObjectWithData(data) as? UIColor
    return Color(uiColor: uiColour ?? UIColor(red: 0, green: 0, blue: 0, alpha: 1))
}
