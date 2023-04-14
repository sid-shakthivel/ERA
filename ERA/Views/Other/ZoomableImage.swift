//
//  ZoomableImage.swift
//  ERA
//
//  Created by Siddharth Shakthivel Muthu Pandian on 25/03/2023.
//

import Foundation
import SwiftUI
import PDFKit

struct ZoomableImage: UIViewRepresentable {
    private(set) var image: UIImage
    
    private(set) var backgroundColor: Color
    
    private(set) var minScaleFactor: CGFloat

    private(set) var idealScaleFactor: CGFloat
    
    private(set) var maxScaleFactor: CGFloat

    public init(
        image: UIImage,
        backgroundColor: Color,
        minScaleFactor: CGFloat,
        idealScaleFactor: CGFloat,
        maxScaleFactor: CGFloat
    ) {
        self.image = image
        self.backgroundColor = backgroundColor
        self.minScaleFactor = minScaleFactor
        self.idealScaleFactor = idealScaleFactor
        self.maxScaleFactor = maxScaleFactor
    }

    public func makeUIView(context: Context) -> PDFView {
        let view = PDFView(frame: CGRect(x: 0, y: 0, width: 100, height: 100))
        guard let page = PDFPage(image: image) else { return view }
        let document = PDFDocument()
        document.insert(page, at: 0)

        view.backgroundColor = UIColor(.green)

        view.autoScales = true
        view.document = document

//        view.maxScaleFactor = maxScaleFactor
//        view.minScaleFactor = minScaleFactor
//        view.scaleFactor = idealScaleFactor
        return view
    }

    public func updateUIView(_ uiView: PDFView, context: Context) {
        // empty
    }
 }
