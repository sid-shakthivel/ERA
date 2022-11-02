//
//  Home.swift
//  ERA
//
//  Created by Siddharth Shakthivel Muthu Pandian on 15/10/2022.
//

import SwiftUI
import AVFoundation
import PDFKit

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

class ScanResult: ObservableObject {
    @Published var scannedTextList: [TestingStuff] = []
    @Published var exampleHeading: TestingStuff = TestingStuff(text: "Example", isHeading: true)
    @Published var exampleText: TestingStuff = TestingStuff(text: "Hello World", isHeading: false)
}

class CanvasSettings: ObservableObject {
    @Published var selectedColour: Color = .black
    @Published var lines: [Line] = []
    @Published var lastLine: Line?
    @Published var lineWidth: Double = 5
    @Published var isRubbing: Bool = false
}

extension UIView {
    var screenShot: UIImage {
        let rect = self.bounds
        UIGraphicsBeginImageContextWithOptions(rect.size, false, 0.0)
        let context: CGContext = UIGraphicsGetCurrentContext()!
        self.layer.render(in: context)
        let capturedImage: UIImage = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()
        return capturedImage
    }
}

extension View {
    func takeScreenshot(origin: CGPoint, size: CGSize) -> UIImage {
        let window = UIWindow(frame: CGRect(origin: origin, size: size))
        let hosting = UIHostingController(rootView: self)
        hosting.view.frame = window.frame
        window.addSubview(hosting.view)
        window.makeKeyAndVisible()
        return hosting.view.screenShot
    }
}

extension String {
    var alphanumeric: String {
        return self.components(separatedBy: CharacterSet.alphanumerics.inverted).joined().lowercased()
    }
}

struct Line {
    var points: [CGPoint]
    var colour: Color
    var lineWidth: Double
}

struct Home: View {
    @State var showDocumentCameraView = false
    @State var showFileImporter = false
    @State var showFileExporter = false
    @State var showMenu: Bool
    @State var showDictionary: Bool = false
    @State var showPencilEdit: Bool = false
    
    @State var document: PDFDoc? = nil
    
    @StateObject var userSettings = UserCustomisations()
    @StateObject var scanResult = ScanResult()
    @StateObject var canvasSettings = CanvasSettings()
    
    @State var isEditingText: Bool = false
    @State var isDrawing: Bool = false

    var body: some View {
        GeometryReader { geometryProxy in
            NavigationView {
                VStack {
                    HStack {
                        Text("Easy Reading Assistant")
                            .foregroundColor(.black)
                            .fontWeight(.bold)
                            .textCase(.uppercase)
                            .contextMenu {
                                Button(action: {
                                    // Export to PDF
                                    let image = self.takeScreenshot(origin: geometryProxy.frame(in: .global).origin, size: geometryProxy.size)
                                    
                                    let pdfDocument = PDFDocument()
                                    let pdfPage = PDFPage(image: image)
                                    pdfDocument.insert(pdfPage!, at: 0)
                                    
                                    let data = pdfDocument.dataRepresentation()
                                    let documentDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
                                    let docURL = documentDirectory.appendingPathComponent("ExamplePDF.pdf")
                                    
                                    do{
                                      try data?.write(to: docURL)
                                    } catch(let error){
                                       print("error is \(error.localizedDescription)")
                                    }
                                    
                                    document = PDFDoc(teest: docURL)
                                    
                                    showFileExporter.toggle()
                                }, label: {
                                    Text("Export to PDF")
                                })
                            }

                        Spacer()
                        
                        Group {
                            if isEditingText {
                                Button(action: {
                                    isEditingText = false
                                    isDrawing = false
                                }, label: {
                                    Image("stop-edit")
                                        .resizable()
                                        .frame(width: 30, height: 30)
                                })
                            } else {
                                Button(action: {
                                    isEditingText = true
                                    isDrawing = false
                                }, label: {
                                    Image("edit")
                                        .resizable()
                                        .frame(width: 30, height: 30)
                                })
                            }
                            
                            NavigationLink(destination: Settings()) {
                                Image("settings")
                                    .resizable()
                                    .frame(width: 30, height: 30)
                            }
                        }
                    }
                    .padding()
                    
                    Divider()
                    
                    ZStack {
                        ScrollView(.vertical, showsIndicators: true) {
                            if scanResult.scannedTextList.count < 1 {
                                // View generated on intial startup (editable)
                                Paragraph(paragraphFormat: $scanResult.exampleHeading, isEditingText: $isEditingText)
                                Paragraph(paragraphFormat: $scanResult.exampleText, isEditingText: $isEditingText)
                            } else {
                                // View generated on scan/imported PDF
                                ForEach($scanResult.scannedTextList, id: \.self) { $paragraph in
                                    Paragraph(paragraphFormat: $paragraph, isEditingText: $isEditingText)
                                    Text("")
                                }
                            }
                        }
                        
                        if isDrawing {
                            Canvas { ctx, size in
                                for line in canvasSettings.lines {
                                    var path = Path()
                                    path.addLines(line.points)
                                    
                                    ctx.stroke(path, with: .color(line.colour), style: StrokeStyle(lineWidth: line.lineWidth, lineCap: .round, lineJoin: .round))
                                }
                            }
                            .gesture(DragGesture(minimumDistance: 0, coordinateSpace: .local).onChanged({ value in
                                let position = value.location
                                if value.translation == .zero {
                                    if canvasSettings.isRubbing {
                                        canvasSettings.lines.append(Line(points: [position], colour: .clear, lineWidth: canvasSettings.lineWidth))
                                    } else {
                                        canvasSettings.lines.append(Line(points: [position], colour: canvasSettings.selectedColour, lineWidth: canvasSettings.lineWidth))
                                    }
                                } else {
                                    guard let lastIndex = canvasSettings.lines.indices.last else { return }
                                    canvasSettings.lines[lastIndex].points.append(position)
                                }
                            }))
                        }
                    }
                        .padding()
                        .background(userSettings.backgroundColour)
                                                                
                    OptionBar(showDictionary: $showDictionary, showMenu: $showMenu, isDrawing: $isDrawing, isEditing: $isEditingText, showPencilEdit: $showPencilEdit)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .background(Color.white)
                }
                    .background(Color(hex: 0xFFF9F0, alpha: 1))
            }
                .environmentObject(userSettings)
                .environmentObject(scanResult)
                .environmentObject(canvasSettings)
                .navigationBarTitle("")
                .navigationBarBackButtonHidden(true)
                .navigationBarHidden(true)
                .fileImporter(isPresented: $showFileImporter, allowedContentTypes: [.pdf], onCompletion: { result in
                    do {
                        let url = try result.get()
                        let images = convertPDFToImages(url: url)
                        let paragraphs = testScanPDF(scan: images)
                        self.scanResult.scannedTextList = paragraphs
                    } catch {
                        print("OH DEAR")
                    }
                })
                .sheet(isPresented: $showDocumentCameraView, content: {
                    DocumentCameraView(settings: userSettings, scanResult: scanResult)
                })
                .sheet(isPresented: $showPencilEdit, content: {
                    EditPencil()
                        .environmentObject(canvasSettings)
                        .presentationDetents([.fraction(0.30)])
                        .presentationDragIndicator(.visible)
                })
                .sheet(isPresented: $showMenu, content: {
                    Menu(showDocumentCameraView: $showDocumentCameraView, showFileImporter: $showFileImporter, showDictionary: $showDictionary, showMenu: $showMenu)
                        .environmentObject(canvasSettings)
                        .presentationDetents([.fraction(0.30)])
                        .presentationDragIndicator(.visible)
                })
                .sheet(isPresented: $showDictionary, content: {
                    DictionaryLookup(wordData: nil, state: .Stationary)
                        .environmentObject(userSettings)
                })
                .fileExporter(
                   isPresented: $showFileExporter,
                   document: document,
                   contentType: UTType.pdf,
                   defaultFilename: "NewPDF"
               ) { result in
                   if case .success = result {
                       Swift.print("Success!")
                   } else {
                       Swift.print("Something went wrong…")
                   }
               }
        }
    }
}

struct Home_Previews: PreviewProvider {
    static var previews: some View {
        Home(showMenu: true)
    }
}
