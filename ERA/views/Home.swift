//
//  Home.swift
//  ERA
//
//  Created by Siddharth Shakthivel Muthu Pandian on 15/10/2022.
//

import SwiftUI
import AVFoundation
import PDFKit
import SwiftUITooltip

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

extension UIColor {
    var inverted: UIColor {
        var r: CGFloat = 0.0, g: CGFloat = 0.0, b: CGFloat = 0.0, a: CGFloat = 0.0
        self.getRed(&r, green: &g, blue: &b, alpha: &a)
        return UIColor(red: (1 - r), green: (1 - g), blue: (1 - b), alpha: a) // Assuming you want the same alpha value.
    }
}

class ScanResult: ObservableObject {
    @Published var scannedTextList: [TestingStuff] = []
    @Published var exampleHeading: TestingStuff = TestingStuff(text: "Example", isHeading: true)
    @Published var exampleText: TestingStuff = TestingStuff(text: "Welcome to ERA", isHeading: false)
    @Published var scannedText: String = "Welcome to ERA"
}

class CanvasSettings: ObservableObject {
    @Published var selectedColour: Color = .black
    @Published var selectedHighlighterColour: Color = Color(hex: 0x000000, alpha: 0.5)
    @Published var lines: [Line] = []
    @Published var lastLine: Line?
    @Published var lineWidth: Double = 5
    @Published var isRubbing: Bool = false
    @Published var lineCap: CGLineCap = .round
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
    var lineCap: CGLineCap
    var lineWidth: Double
    var isHighlighter: Bool
}

struct Home: View {
    @State var showDocumentCameraView = false
    @State var showFileImporter = false
    @State var showFileExporter = false
    @State var showMenu: Bool
    @State var showDictionary: Bool = false
    @State var showPencilEdit: Bool = false
    
    @State var document: PDFDoc? = nil
    
    @StateObject var scanResult = ScanResult()
    @StateObject var canvasSettings = CanvasSettings()
    
    @State var isEditingText: Bool = false
    @State var isDrawing: Bool = false
    @State var isPlayingAudio: Bool = false
    @State var isShowingHelp: Bool = false
    
    @EnvironmentObject var userSettings: UserCustomisations
    
    let synth = AVSpeechSynthesizer()
    
    // Speaks given text
    func speak_text() {
        let utterance = AVSpeechUtterance(string: scanResult.scannedText)
        utterance.voice = AVSpeechSynthesisVoice(language: userSettings.voice)
        utterance.volume = userSettings.volume
        utterance.pitchMultiplier = userSettings.pitch
        utterance.rate = userSettings.rate
        synth.speak(utterance)
    }
    
    func stop_speaking() {
        synth.stopSpeaking(at: .immediate)
    }

    
    var tooltipConfig = DefaultTooltipConfig()
    
    var body: some View {
        GeometryReader { geometryProxy in
            NavigationView {
                VStack {
                    HStack {
                        Text("Easy Reading Assistant")
                            .fontWeight(.bold)
                            .textCase(.uppercase)
                            .if(userSettings.isDarkMode) { view in
                                view
                                    .foregroundColor(.white)
                            }
                            .if(!userSettings.isDarkMode) { view in
                                view
                                    .foregroundColor(.black)
                            }
                        
                        Spacer()
                        
                        Group {
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
                                Image(systemName: "square.and.arrow.up.fill")
                                    .resizable()
                                    .frame(width: 20, height: 20)
                            })
                            .if(isShowingHelp) { view in
                                view
                                    .tooltip(.left, config: tooltipConfig) {
                                        Text("Export PDF")
                                            .font(Font(userSettings.subParagaphFont))
                                    }
                            }
                            
                            if isPlayingAudio {
                                Button(action: {
                                    // Check whether the speaker is paused or not
                                    synth.pauseSpeaking(at: AVSpeechBoundary.immediate)
                                    isPlayingAudio.toggle()
                                }, label: {
                                    Image("pause")
                                        .resizable()
                                        .frame(width: 20, height: 20)
                                })
                                    .padding(.trailing)
                            } else {
                                // Present play button and allow text to be played
                                Button(action: {
                                    if synth.isPaused {
                                        synth.continueSpeaking()
                                    } else {
                                        self.speak_text()
                                    }
                                    
                                    isPlayingAudio.toggle()
                                }, label: {
                                    Image("play-but-big")
                                        .resizable()
                                        .frame(width: 20, height: 20)
                                })
                                    .padding(.trailing)
                                    .if(isShowingHelp) { view in
                                        view
                                            .tooltip(.bottom) {
                                                Text("Play/Pause")
                                                    .font(Font(userSettings.subParagaphFont))
                                            }
                                    }
                            }
                            
                            Button(action: {
                                isShowingHelp.toggle()
                            }, label: {
                                Image(systemName: "info.circle.fill")
                                    .resizable()
                                    .frame(width: 20, height: 20)
                            })
                            
                            NavigationLink(destination: Settings()) {
                                Image("settings")
                                    .resizable()
                                    .frame(width: 30, height: 30)
                            }
                        }
                    }
                    .padding(.leading)
                    .padding(.trailing)
                    
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
                                    
                                    ctx.stroke(path, with: .color(line.colour), style: StrokeStyle(lineWidth: line.lineWidth, lineCap: canvasSettings.lineCap, lineJoin: .round))
                                }
                            }
                            .gesture(DragGesture(minimumDistance: 0, coordinateSpace: .local).onChanged({ value in
                                let position = value.location
                                if value.translation == .zero {
                                    if canvasSettings.isRubbing {
                                        canvasSettings.lines.append(Line(points: [position], colour: .clear, lineCap: canvasSettings.lineCap, lineWidth: canvasSettings.lineWidth, isHighlighter: false))
                                    } else {
                                        if canvasSettings.lineCap == .round {
                                            canvasSettings.lines.append(Line(points: [position], colour: canvasSettings.selectedColour, lineCap: canvasSettings.lineCap, lineWidth: canvasSettings.lineWidth, isHighlighter: false))
                                        } else {
                                            canvasSettings.lines.append(Line(points: [position], colour: canvasSettings.selectedHighlighterColour, lineCap: canvasSettings.lineCap, lineWidth: canvasSettings.lineWidth, isHighlighter: false))
                                        }
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
                                                                
                    OptionBar(showDictionary: $showDictionary, showMenu: $showMenu, isDrawing: $isDrawing, isEditing: $isEditingText, showPencilEdit: $showPencilEdit, isShowingHelp: $isShowingHelp)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .if(userSettings.isDarkMode) { view in
                            view
                                .background(ColourConstants.darkModeLighter)
                        }
                        .if(!userSettings.isDarkMode) { view in
                            view
                                .background(ColourConstants.lightModeLighter)
                        }
                }
                .if(userSettings.isDarkMode) { view in
                    view
                        .background(ColourConstants.darkModeBackground)
                }
                .if(!userSettings.isDarkMode) { view in
                    view
                        .background(ColourConstants.lightModeBackground)
                }
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
                        let result = testScanPDF(scan: images)
                        self.scanResult.scannedTextList = result.0
                        self.scanResult.scannedText = result.1
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
        Home(showMenu: false)
    }
}
