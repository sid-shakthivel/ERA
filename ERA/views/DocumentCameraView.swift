//
//  DocumentCameraView.swift
//  ERA
//
//  Created by Siddharth Shakthivel Muthu Pandian on 29/09/2022.
//

import SwiftUI
import VisionKit
import Vision
import AVFoundation

struct ParagraphFormat: Hashable {
    var text: String
    var isHeading: Bool
    
    init(text: String, isHeading: Bool) {
        self.text = text
        self.isHeading = isHeading
    }
}

/*
    Paragraph is on a new line if:
    Difference between Y coordinate of current line and last line is greater then 0.05 (Maybe this value can be relative???)
    Difference between X coordinate of current line and last line is greater then 0.04 (Indent)
    TODO: Need to ensure the max val is subtracted from min val
    TODO: May need to average results
 */
func checkNewParagraph(boundingBoxes: [CGPoint], observation: VNRecognizedTextObservation) -> Bool {
    if boundingBoxes.count > 0 && ((boundingBoxes[boundingBoxes.count - 1].y - observation.topLeft.y >= 0.04) || (observation.topLeft.x - boundingBoxes[boundingBoxes.count - 1].x >= 0.04)) {
        return true
    }
    return false
}

func scanPhotos(scan: VNDocumentCameraScan) -> [ParagraphFormat] {
    var paragraphs: [ParagraphFormat] = []

    var currentParagraph: [String] = []
    var boundingBoxes: [CGPoint] = []
    
    let request = VNRecognizeTextRequest { request, error in
        guard let observations = request.results as? [VNRecognizedTextObservation] else {
            fatalError("Received invalid observations")
        }

        for observation in observations {
            guard let bestCandidate = observation.topCandidates(1).first else {
                continue
            }

            if checkNewParagraph(boundingBoxes: boundingBoxes, observation: observation) {
                if currentParagraph.count < 2 {
                    // Heading
                    paragraphs.append(ParagraphFormat(text: currentParagraph.joined(separator: ""), isHeading: true))
                } else {
                    // Paragraph
                    
                    currentParagraph[currentParagraph.count-1] += "\n"
                    
                    paragraphs.append(ParagraphFormat(text: currentParagraph.joined(separator: ""), isHeading: false))
                }
                
                currentParagraph.removeAll()
                boundingBoxes.removeAll()
            }

            currentParagraph.append(bestCandidate.string)
            boundingBoxes.append(observation.topLeft)
        }
    }
    
    request.recognitionLevel = .accurate
    request.usesLanguageCorrection = true
    
    let requests = [request]
    
    // For each photo within the scanned images, analyse and collate all the text
    for i in 0 ..< scan.pageCount {
        let img = scan.imageOfPage(at: i)
        guard let cgImage = img.cgImage else { continue }

        let requestHandler = VNImageRequestHandler(cgImage: cgImage, options: [:])
        try? requestHandler.perform(requests)
    }
    
    return paragraphs
}

func testScanPDF(scan: [UIImage]) -> [ParagraphFormat] {
    var paragraphs: [ParagraphFormat] = []

    var currentParagraph: [String] = []
    var boundingBoxes: [CGPoint] = []
    
    let request = VNRecognizeTextRequest { request, error in
        guard let observations = request.results as? [VNRecognizedTextObservation] else {
            fatalError("Received invalid observations")
        }

        for observation in observations {
            guard let bestCandidate = observation.topCandidates(1).first else {
                continue
            }

            if checkNewParagraph(boundingBoxes: boundingBoxes, observation: observation) {
                if currentParagraph.count < 2 {
                    // Heading
                    paragraphs.append(ParagraphFormat(text: currentParagraph.joined(separator: ""), isHeading: true))
                } else {
                    // Paragraph
                    paragraphs.append(ParagraphFormat(text: currentParagraph.joined(separator: ""), isHeading: false))
                }
                
                currentParagraph.removeAll()
                boundingBoxes.removeAll()
            }

            currentParagraph.append(bestCandidate.string)
            boundingBoxes.append(observation.topLeft)
        }
    }
    
    request.recognitionLevel = .accurate
    request.usesLanguageCorrection = true
    
    let requests = [request]
    
    // For each photo within the scanned images, analyse and collate all the text
    for image in scan {
        guard let cgImage = image.cgImage else { continue }

        let requestHandler = VNImageRequestHandler(cgImage: cgImage, options: [:])
        try? requestHandler.perform(requests)
    }
    
    return paragraphs
}

/*
 To implement a view controller in swiftui, it must be wrapped inside a UIViewControllerRepresentable
 VNDocumentCameraViewController hasn't been ported to swiftui yet and thus this process must ensue
 */
struct DocumentCameraView: UIViewControllerRepresentable {
    @Environment(\.presentationMode) var presentationMode
    @ObservedObject var settings: UserCustomisations
    @ObservedObject var scanResult: ScanResult

    func updateUIViewController(_ viewController: VNDocumentCameraViewController, context: Context) {}

    func makeUIViewController(context: Context) -> VNDocumentCameraViewController {
        let viewController = VNDocumentCameraViewController()
        viewController.delegate = context.coordinator
        return viewController
    }

    func makeCoordinator() -> DocumentCameraView.DocumentCameraViewCoordinator {
        return DocumentCameraViewCoordinator(self)
    }

    /*
     Coordinators act as delegates for UIKit view controllers
     Delegates are objects which respond to events for specific views
     Class inherits from NSObject(parent class for everything) and DataScannerViewControllerDelegate which adds functionality for the view
     */
    class DocumentCameraViewCoordinator: NSObject, VNDocumentCameraViewControllerDelegate {
        var parent: DocumentCameraView

        init(_ parent: DocumentCameraView) {
            self.parent = parent
        }

        func documentCameraViewController(_ controller: VNDocumentCameraViewController, didFailWithError error: Error) {
            // Perhaps in the future out a message to user
            parent.presentationMode.wrappedValue.dismiss()
        }

        func documentCameraViewControllerDidCancel(_ controller: VNDocumentCameraViewController) {
            parent.presentationMode.wrappedValue.dismiss()
        }
        
        // Called when there are scanned images to analyse
        func documentCameraViewController(_ controller: VNDocumentCameraViewController, didFinishWith scan: VNDocumentCameraScan) {
            parent.scanResult.scannedTextList = scanPhotos(scan: scan)
            parent.presentationMode.wrappedValue.dismiss()
          }
    }
}
