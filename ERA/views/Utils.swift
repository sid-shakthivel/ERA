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

    print(document.numberOfPages)

    guard let page = document.page(at: 1) else {
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
