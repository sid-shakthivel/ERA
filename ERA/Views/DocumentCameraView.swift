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

// Ensure SavedParagraph is a subclass of NSObject in order to be serialised
class SavedParagraph: NSObject, NSSecureCoding {
    var text: String
    var isHeading: Bool
    
    enum CodingKeys: String {
        case text = "texting"
        case isHeading = "isHeading"
    }
    
    static var supportsSecureCoding: Bool = true
    
    init(text: String, isHeading: Bool) {
        self.text = text
        self.isHeading = isHeading
    }
    
    public func encode(with coder: NSCoder) {
        coder.encode(text, forKey: CodingKeys.text.rawValue)
        coder.encode(isHeading, forKey: CodingKeys.isHeading.rawValue)
    }
    
    public required convenience init?(coder: NSCoder) {
        let mIsHeading = coder.decodeBool(forKey: CodingKeys.isHeading.rawValue)
        let mText = coder.decodeObject(of: NSString.self, forKey: CodingKeys.text.rawValue) as? String
        self.init(text: mText ?? exampleText, isHeading: mIsHeading)
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
    // Collate all pages within scan into an array of UIImages to be fed under OCR
    var imageList: [UIImage] = []
    for i in 0 ..< scan.pageCount {
        let img = scan.imageOfPage(at: i)
        imageList.append(img)
    }
    return imageList
}

func convertPhotosToParagraphs(scan: [UIImage]) -> ([SavedParagraph], String) {
    var paragraphs: [SavedParagraph] = []

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
        
        // Analyse each observation to determine whether it's a paragraph or heading and whether an observation is part of a paragraph or not
        for observation in observations {
            guard let bestCandidate = observation.topCandidates(1).first else {
                continue
            }

            if checkNewParagraph(boundingBoxes: boundingBoxes, observation: observation, y_limit: average) {
                if currentParagraph.count < 2 {
                    // Heading
                    paragraphs.append(SavedParagraph(text: currentParagraph.joined(separator: ""), isHeading: true))
                } else {
                    // Paragraph
                    paragraphs.append(SavedParagraph(text: currentParagraph.joined(separator: ""), isHeading: false))
                }
                
                currentParagraph.removeAll()
                boundingBoxes.removeAll()
            }

            currentParagraph.append(bestCandidate.string)
            boundingBoxes.append(observation.topLeft)
        }
        
        if currentParagraph.count < 2 {
            // Heading
            paragraphs.append(SavedParagraph(text: currentParagraph.joined(separator: ""), isHeading: true))
        } else {
            // Paragraph
            paragraphs.append(SavedParagraph(text: currentParagraph.joined(separator: ""), isHeading: false))
        }
    }
    
    request.recognitionLevel = .accurate
    request.usesLanguageCorrection = true
    
    if #available(iOS 16, *) {
        request.automaticallyDetectsLanguage = true
    }
    
    let requests = [request]
    
    // For each photo within the scanned images, analyse and collate all the text together
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
    @Environment(\.managedObjectContext) var moc
    
    @Binding var fileStatus: FileStatus;

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
                do {
                    let images: [UIImage] = convertCameraDocumentScanToImages(scan: scan)
                    let savedImages = images
                    let result: ([SavedParagraph], String) = convertPhotosToParagraphs(scan: images)
                    
                    let newScanResult = Document(context: self.parent.moc)
                    newScanResult.id = UUID()
                    newScanResult.scanResult = ScanResult(scannedTextList: result.0, scannedText: result.1)
                    newScanResult.title = "Scan" + getDate()
                    
                    // Save images
                    let imageDataArray = convertImagesToData(images: savedImages)
                    let colatedImageData = try NSKeyedArchiver.archivedData(withRootObject: imageDataArray, requiringSecureCoding: true)
                    newScanResult.images = colatedImageData
                    
                    self.parent.fileStatus = .Finished
                    
                    try? self.parent.moc.save()
                } catch {}
            }
        }
    }
}
