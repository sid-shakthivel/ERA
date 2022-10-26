//
//  PDFHandler.swift
//  BionicReading
//
//  Created by Siddharth Shakthivel Muthu Pandian on 20/10/2022.
//

import Foundation
import UniformTypeIdentifiers
import SwiftUI
import PDFKit
import AVFoundation

struct PDFDoc: FileDocument {
    // tell the system we support only plain text
    static var readableContentTypes = [UTType.pdf]

    // by default our document is empty
    var url = ""

    // a simple initializer that creates new, empty documents
    init(teest: URL) {
        self.url = teest.path
    }

    // this initializer loads data that has been saved previously
    init(configuration: ReadConfiguration) throws {
        url = ""
    }

    // this will be called when the system wants to write our data to disk
    func fileWrapper(configuration: WriteConfiguration) throws -> FileWrapper {
        let file = try FileWrapper(url: URL(fileURLWithPath: url), options: .immediate)
        return file
    }
}

// Convert PDF to array of images which can be processed
func convertPDFToImages(url: URL) -> [UIImage] {
    var images: [UIImage] = []
    _ = url
    
    guard url.startAccessingSecurityScopedResource() else {
        print("Error: could not access content of url: \(url)")
        return images
    }
    
    guard let document = CGPDFDocument(url as CFURL) else {
        print("NO DOCUMENT")
        return images
    }

    print(document.numberOfPages)
    
    guard let page = document.page(at: 1) else {
        print("NO PAGES?")
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


