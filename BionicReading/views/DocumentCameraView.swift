//
//  DocumentCameraView.swift
//  BionicReading
//
//  Created by Siddharth Shakthivel Muthu Pandian on 29/09/2022.
//

import SwiftUI
import VisionKit
import Vision
import PDFKit

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

//        func CreatePDFData(_ paragraphs: [[String]]) -> Data {
//            // 1
//              let pdfMetaData = [
//                kCGPDFContextCreator: "ERA",
//                kCGPDFContextAuthor: "mindcore"
//              ]
//              let format = UIGraphicsPDFRendererFormat()
//              format.documentInfo = pdfMetaData as [String: Any]
//
//              // 2
//              let pageWidth = 8.5 * 72.0
//              let pageHeight = 11 * 72.0
//              let pageRect = CGRect(x: 0, y: 0, width: pageWidth, height: pageHeight)
//
//              // 3
//              let renderer = UIGraphicsPDFRenderer(bounds: pageRect, format: format)
//
//              // 4
//              let data = renderer.pdfData { (context) in
//                // 5
//                context.beginPage()
//                // 6
//                let standardAttributes = [
//                    NSAttributedString.Key.font: self.parent.settings.selectedFont,
//                    NSAttributedString.Key.backgroundColor: UIColor(self.parent.settings.selectedBackgroundColour),
//                    NSAttributedString.Key.foregroundColor: UIColor(self.parent.settings.selectedTextColour)
//                ]
//
//                  let headingAttributes = [
//                    NSAttributedString.Key.font: self.parent.settings.selectedHeadingFont,
//                      NSAttributedString.Key.backgroundColor: UIColor(self.parent.settings.selectedBackgroundColour),
//                      NSAttributedString.Key.foregroundColor: UIColor(self.parent.settings.selectedTextColour)
//                  ]
//
//                  var y = 0;
//                  for paragraph in paragraphs {
//                      /*
//                       If count is 1, it's assumed it is a heading
//                       If count is greater, it's assumed it's normal text
//                       */
//
//                      if paragraph.count == 1 {
//                          let adjustedText = paragraph[0] + String(repeating: " ", count: Int(pageWidth))
//                          // Attempt to centre headings
//
//                          print("Hello hello")
//                          print(paragraph[0].count)
//
//                          let centreXCoordinate = Int((Int(pageWidth) - paragraph[0].count) / 2)
//
//                          adjustedText.draw(at: CGPoint(x: centreXCoordinate, y: y), withAttributes: headingAttributes)
//                          y += Int(self.parent.settings.selectedHeadingFont.lineHeight)
//
//                          // Add a line break
////                          let lineBreak = String(repeating: " ", count: Int(pageWidth))
////
////                          y += Int(self.parent.settings.selectedHeadingFont.lineHeight)
////                          lineBreak.draw(at: CGPoint(x: 0, y: y), withAttributes: headingAttributes)
//                      } else {
//                          for line in paragraph {
//                              let adjustedText = line + String(repeating: " ", count: Int(pageWidth)) // Increase line size so it fits the screen
//                              adjustedText.draw(at: CGPoint(x: 0, y: y), withAttributes: standardAttributes)
//                              y += Int(self.parent.settings.selectedFont.lineHeight)
//                          }
//                      }
//                  }
//
//                  var totalCount = 0;
//
//                  for paragraph in paragraphs {
//                      totalCount += paragraph.count
//                  }
//
//                  // Get extra space within pdf adusted for too
//                  for _ in 0...(Int(pageHeight) - totalCount) {
//                      let adjustedText = String(repeating: " ", count: Int(pageWidth))
//
//                      adjustedText.draw(at: CGPoint(x: 0, y: y), withAttributes: standardAttributes)
//                      y += Int(self.parent.settings.selectedFont.lineHeight * 1.5)
//                  }
//              }
//
//              return data
//        }

        
        // Called when there are scanned images to analyse
        func documentCameraViewController(_ controller: VNDocumentCameraViewController, didFinishWith scan: VNDocumentCameraScan) {
            var paragraphs: [[String]] = []

            var currentParagraph: [String] = []
            var boundingBoxes: [CGPoint] = []

            let request = VNRecognizeTextRequest { [self] request, error in
                guard let observations = request.results as? [VNRecognizedTextObservation] else {
                    fatalError("Received invalid observations")
                }

                for observation in observations {
                    guard let bestCandidate = observation.topCandidates(1).first else {
                        print("No candidate")
                        continue
                    }

                    print(bestCandidate.string)
                    print(observation.topLeft)

                    if boundingBoxes.count > 0 {
                        // Check if there is a large enough gap between the current and previous candidate

                        /*
                            Paragraph is on a new line if:
                            Difference between Y coordinate of current line and last line is greater then 0.05 (Maybe this value can be relative???)
                            Difference between X coordinate of current line and last line is greater then 0.04 (Indent)
                            TODO: Need to ensure the max val is subtracted from min val
                            TODO: May need to average results
                         */
                        if (boundingBoxes[boundingBoxes.count - 1].y - observation.topLeft.y >= 0.04) || (observation.topLeft.x - boundingBoxes[boundingBoxes.count - 1].x >= 0.04) {
                            print("Creating new paragraph")
                            
                            // Create a new paragraph
                            paragraphs.append(currentParagraph)
                            currentParagraph.removeAll()
                            boundingBoxes.removeAll()
                        }
                    }

                    currentParagraph.append(bestCandidate.string)

                    boundingBoxes.append(observation.topLeft)
                }
            }

            request.recognitionLevel = .accurate
            request.usesLanguageCorrection = true

            let requests = [request]

            // Make a new custom scanned view which consits of a number of text
            for i in 0 ..< scan.pageCount {
                let img = scan.imageOfPage(at: i)
                guard let cgImage = img.cgImage else { continue }

                let requestHandler = VNImageRequestHandler(cgImage: cgImage, options: [:])
                try? requestHandler.perform(requests)
            }
            
            parent.scanResult.scannedTextList = paragraphs
            
            print("We have this many paragraphs?")
            print(paragraphs.count)
            
            parent.presentationMode.wrappedValue.dismiss()
          }
    }
}
