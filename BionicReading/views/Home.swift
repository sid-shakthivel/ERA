//
//  Home.swift
//  BionicReading
//
//  Created by Siddharth Shakthivel Muthu Pandian on 15/10/2022.
//

import SwiftUI
import AVFoundation
import PDFKit
import HighlightedTextEditor

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
    @Published var scannedTextList: [[String]] = []
    @Published var scannedText: String = "Hello copy. **This is an example** document and I really really really hope this works perfectly fine"
    @Published var heading: String = "Example Heading"
    @Published var utterance = AVSpeechUtterance(string: "hello world")
}

class CanvasSettings: ObservableObject {
    @Published var selectedColour: Color = .clear
    @Published var lines: [Line] = []
    @Published var lastLine: Line?
    @Published var lineWidth: Double = 5
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
}

struct Home: View {
    @State var showDocumentCameraView = false
    @State var showFileImporter = false
    @State var showFileExporter = false
    @State var showMenu = false
    @State var showDictionary: Bool = false
    
    @State var document: PDFDoc? = nil
    
    @StateObject var userSettings = UserCustomisations()
    @StateObject var scanResult = ScanResult()
    @StateObject var canvasSettings = CanvasSettings()
    
    @State var isEditing: Bool = false

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
                            if isEditing {
                                Button(action: {
                                    isEditing = false
                                }, label: {
                                    Image(systemName: "pencil.slash")
                                        .font(.title)
                                })
                            } else {
                                Button(action: {
                                    isEditing = true
                                }, label: {
                                    Image(systemName: "pencil")
                                        .font(.title)
                                })
                            }
                                
                            
                            NavigationLink(destination: Settings()) {
                                Image(systemName: "gear")
                                    .font(.headline)
                                    .foregroundColor(Color(hex: 0xDFF4D0F, alpha: 1))
                            }
                        }
                    }
                    .padding()
                    
                    Divider()
                    
                    ZStack {
//                        Canvas { ctx, size in
//                            for line in canvasSettings.lines {
//                                var path = Path()
//                                path.addLines(line.points)
//
//                                ctx.stroke(path, with: .color(line.colour), style: StrokeStyle(lineWidth: canvasSettings.lineWidth, lineCap: .round, lineJoin: .round))
//                            }
//                        }
                        
                        ScrollView(.vertical, showsIndicators: true) {
                            if scanResult.scannedTextList.count < 1 {
                                // View generated on inital startup which is editable
                                
                                if isEditing {
                                    TextField(scanResult.heading, text: $scanResult.heading)
                                        .foregroundColor(userSettings.fontColour)
                                        .font(Font(userSettings.headingFont))
                                        .fontWeight(.bold)

                                    TextEditor(text: $scanResult.scannedText)
                                        .foregroundColor(userSettings.fontColour)
                                        .scrollContentBackground(.hidden)
                                        .background(userSettings.backgroundColour)
                                        .font(Font(userSettings.font))
                                        .frame(maxHeight: .infinity, alignment: .leading)
                                } else {
                                    Paragraph(isHeading: true, text: scanResult.heading)
                                    Paragraph(isHeading: false, text: scanResult.scannedText)
                                }
                            } else {
                                // View generated on scan/imported PDF
                                
                                ForEach(scanResult.scannedTextList, id: \.self) { paragraph in
                                    if paragraph.count < 2 {
                                        // Heading
                                        Paragraph(isHeading: true, text: paragraph[0])
                                    } else {
                                        // Paragraph
                                        Paragraph(isHeading: false, text: paragraph.joined(separator: " "))
                                    }
                                    Text("")
                                }
                            }
                        }
                        
//                        if canvasSettings.selectedColour != .clear {
//                            Canvas { ctx, size in
//                                for line in canvasSettings.lines {
//                                    var path = Path()
//                                    path.addLines(line.points)
//
//                                    ctx.stroke(path, with: .color(line.colour), style: StrokeStyle(lineWidth: canvasSettings.lineWidth, lineCap: .round, lineJoin: .round))
//                                }
//                            }
//                            .gesture(DragGesture(minimumDistance: 0, coordinateSpace: .local).onChanged({ value in
//                                if canvasSettings.selectedColour != .clear {
//                                    let position = value.location
//                                    if value.translation == .zero {
//                                        canvasSettings.lines.append(Line(points: [position], colour: canvasSettings.selectedColour))
//                                    } else {
//                                        guard let lastIndex = canvasSettings.lines.indices.last else { return }
//                                        canvasSettings.lines[lastIndex].points.append(position)
//                                    }
//                                }
//                            }))
//                        } else {
//                            Canvas { ctx, size in
//                                for line in canvasSettings.lines {
//                                    var path = Path()
//                                    path.addLines(line.points)
//
//                                    ctx.stroke(path, with: .color(line.colour), style: StrokeStyle(lineWidth: canvasSettings.lineWidth, lineCap: .round, lineJoin: .round))
//                                }
//                            }
//                        }
                    }
                        .padding()
                        .background(userSettings.backgroundColour)
                                                                
                    VStack {
                        HStack {
                            Image("setting")
                                .font(.largeTitle)
                                .onTapGesture(count: 2) {
                                    showDictionary.toggle()
                                }
                                .onTapGesture(count: 1) {
                                    showMenu.toggle()
                                }
                            
                            ForEach([Color.blue, Color.red, Color.black], id: \.self) { colour in
                                colourButton(colour: colour)
                            }
                            
                            Button(action: {
                                canvasSettings.selectedColour = .clear
                            }, label: {
                                Image(systemName: "checkmark")
                                    .font(.largeTitle)
                            })
                            
                            Button(action: {
                                canvasSettings.lines = []
                            }, label: {
                                Image(systemName: "trash.fill")
                                    .font(.largeTitle)
                                    .foregroundColor(.gray)
                            })
                            
                            Button(action: {
                                if canvasSettings.lines.count > 1 {
                                    canvasSettings.lastLine = canvasSettings.lines.removeLast()
                                }
                            }, label: {
                                Image(systemName: "arrow.uturn.backward")
                                    .font(.largeTitle)
                            })
                            
                            Button(action: {
                                if canvasSettings.lastLine != nil {
                                    canvasSettings.lines.append(canvasSettings.lastLine!)
                                    canvasSettings.lastLine = nil
                                }
                            }, label: {
                                Image(systemName: "arrow.uturn.forward")
                                    .font(.largeTitle)
                            })
                        }

                        Slider(value: $canvasSettings.lineWidth, in: 0...20)
                            .padding()
                    }
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
                        let (paragraphs, joinedParagraphs) = testScanPDF(scan: images)
                        self.scanResult.scannedTextList = paragraphs
                        self.scanResult.scannedText = joinedParagraphs
                    } catch {
                        print("OH DEAR")
                    }
                })
                .sheet(isPresented: $showDocumentCameraView, content: {
                    DocumentCameraView(settings: userSettings, scanResult: scanResult)
                })
                .sheet(isPresented: $showMenu, content: {
                    Menu(showDocumentCameraView: $showDocumentCameraView, showFileImporter: $showFileImporter, showMenu: $showMenu)
                        .environmentObject(canvasSettings)
                        .presentationDetents([.fraction(0.40), .fraction(0.20)])
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
    
    @ViewBuilder
    func colourButton(colour: Color) -> some View {
        Button(action: {
            canvasSettings.selectedColour = colour
        }, label: {
            Image(systemName: "circle.fill")
                .font(.largeTitle)
                .foregroundColor(colour)
                .mask {
                    Image(systemName: "pencil.tip")
                        .font(.largeTitle)
                }
        })
    }
}

struct Home_Previews: PreviewProvider {
    static var previews: some View {
        Home()
    }
}
