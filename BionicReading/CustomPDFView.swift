//
//  CustomPDFView.swift
//  BionicReading
//
//  Created by Siddharth Shakthivel Muthu Pandian on 10/10/2022.
//

import Foundation
import PDFKit
import SwiftUI

struct CustomPDFView: UIViewRepresentable {
    typealias UIViewType = PDFView

    let pdfDocument: PDFDocument

    init(_ pdfDocument: PDFDocument) {
        self.pdfDocument = pdfDocument
    }

    func makeUIView(context: UIViewRepresentableContext<CustomPDFView>) -> CustomPDFView.UIViewType {
        let pdfView = PDFView()
        pdfView.autoScales = true
        pdfView.displayMode = .singlePageContinuous
        pdfView.document = self.pdfDocument
        return pdfView
    }
    
    func updateUIView(_ uiView: PDFView, context: Context) {}
}
