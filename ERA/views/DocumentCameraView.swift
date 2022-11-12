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

class TestingStuff: ObservableObject, Hashable {
    static func == (lhs: TestingStuff, rhs: TestingStuff) -> Bool {
        lhs.identifier == rhs.identifier
    }
    
    var identifier: String {
        return UUID().uuidString
    }
    
    public func hash(into hasher: inout Hasher) {
        return hasher.combine(identifier)
    }
    
    @Published var text: String
    @Published var isHeading: Bool
    
    init(text: String, isHeading: Bool) {
        self.text = text
        self.isHeading = isHeading
    }
}

/*
    Paragraph is on a new line if:
    Difference between Y coordinate of current line and last line is greater then 0.05 (Maybe this value can be relative???)
    Difference between X coordinate of current line and last line is greater then 0.04 (Indent)
 */
func checkNewParagraph(boundingBoxes: [CGPoint], observation: VNRecognizedTextObservation, y_limit: CGFloat) -> Bool {
    if boundingBoxes.count > 0 {
        let difference = abs(boundingBoxes[boundingBoxes.count - 1].y - observation.topLeft.y)
        
        if difference >= (y_limit + 0.01) || difference <= (y_limit - 0.01) {
            // || (observation.topLeft.x - boundingBoxes[boundingBoxes.count - 1].x >= 0.04))
            return true
        }
    }
    return false
}

func convertCameraDocumentScanToImages(scan: VNDocumentCameraScan) -> [UIImage] {
    var imageList: [UIImage] = []
    for i in 0 ..< scan.pageCount {
        let img = scan.imageOfPage(at: i)
        imageList.append(img)
    }
    return imageList
}

func convertPhotosToParagraphs(scan: [UIImage]) -> ([TestingStuff], String) {
    var paragraphs: [TestingStuff] = []

    var currentParagraph: [String] = []
    var boundingBoxes: [CGPoint] = []
    
    var sum: CGFloat = 0
    
    let request = VNRecognizeTextRequest { request, error in
        guard let observations = request.results as? [VNRecognizedTextObservation] else {
            fatalError("Received invalid observations")
        }
        
        // Calculate the average difference between heights of observations
        for observation in observations {
            if boundingBoxes.count > 0 {
                sum += (boundingBoxes[boundingBoxes.count - 1].y - observation.topLeft.y)
            }
            
            boundingBoxes.append(observation.topLeft)
        }

        let average: CGFloat = sum / CGFloat(boundingBoxes.count)
        
        boundingBoxes.removeAll()

        for observation in observations {
            guard let bestCandidate = observation.topCandidates(1).first else {
                continue
            }

            if checkNewParagraph(boundingBoxes: boundingBoxes, observation: observation, y_limit: average) {
                if currentParagraph.count < 2 {
                    // Heading
                    paragraphs.append(TestingStuff(text: currentParagraph.joined(separator: ""), isHeading: true))
                } else {
                    // Paragraph
                    paragraphs.append(TestingStuff(text: currentParagraph.joined(separator: ""), isHeading: false))
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
    
    var text: String = ""
    for paragraph in paragraphs {
        text += paragraph.text
    }
    
    return (paragraphs, text)
}


/*
 To implement a view controller within SwiftUI, it must be wrapped inside a UIViewControllerRepresentable
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
        func documentCameraViewController(_ controller: VNDocumentCameraViewController, didFinishWith scan: VNDocumentCameraScan)
        {
            parent.presentationMode.wrappedValue.dismiss()
            DispatchQueue.main.async {
                let photoList = convertCameraDocumentScanToImages(scan: scan)
                let result = convertPhotosToParagraphs(scan: photoList)
                
                self.parent.scanResult.scannedTextList = result.0
                self.parent.scanResult.scannedText = result.1
            }
        }
    }
}
