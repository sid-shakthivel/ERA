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
    @Published var scannedText: String = "Hello copy. This is an example document"
    @Published var heading: String = "Example Heading"
    @Published var utterance = AVSpeechUtterance(string: "hello world")
}

class CanvasSettings: ObservableObject {
    @Published var selectedColour: Color = .clear
    @Published var lines: [Line] = []
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
    
    @ObservedObject var speaker = Speaker()
    
    @State var isPlaying: Bool = false
    
    let synth = AVSpeechSynthesizer()
    
    // Converts text to bionic reading format by bolding the first half of every word
    func convertToBionic(text: String) -> String {
        var modifiedText = text
        let boldIndex = Int(ceil(Double(text.count) / 2)) + 1
        modifiedText.insert("*", at: modifiedText.startIndex)
        modifiedText.insert("*", at: modifiedText.index(modifiedText.startIndex, offsetBy: 1))
        
        modifiedText.insert("*", at: modifiedText.index(modifiedText.startIndex, offsetBy: boldIndex + 1))
        modifiedText.insert("*", at: modifiedText.index(modifiedText.startIndex, offsetBy: boldIndex + 2))
        
        return modifiedText
    }
        
    //  If bionic reading is enabled, apply to each word within the string or return it
    func modifyText(text: String) -> String {
        if (userSettings.isBionicReading) {
            var markdownStringArray: [String] = []
            
            for substring in text.split(separator: " ") {
                markdownStringArray.append(convertToBionic(text: String(substring)))
            }

            return String(markdownStringArray.joined(separator: " "))
        }
        
        return String(text)
    }
    
    func text2speech() {
//        let utterance = AVSpeechUtterance(string: scanResult.scannedText)
//        utterance.voice = AVSpeechSynthesisVoice(language: userSettings.accent)
//        self.synth.speak(utterance)
    }

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
                        
                        NavigationLink(destination: Settings()) {
                            Image(systemName: "gear")
                                .font(.headline)
                                .foregroundColor(Color(hex: 0xDFF4D0F, alpha: 1))
                        }
                    }
                    .padding()
                    
                    Divider()

                    ZStack {
                        
                        ScrollView(.vertical, showsIndicators: true) {
//                            LabelRepresented(text: speaker.label)
//                                .onAppear {
//                                    speaker.speak("Hi. This is a test.")
//                                }
                            
                            if scanResult.scannedTextList.count < 1 {
                                TextField(modifyText(text: scanResult.heading), text: $scanResult.heading, axis: .vertical)
                                    .foregroundColor(userSettings.fontColour)
                                    .font(Font(userSettings.headingFont))
                                
                                TextEditor(text: $scanResult.scannedText)
                                    .foregroundColor(userSettings.fontColour)
                                    .scrollContentBackground(.hidden)
                                    .background(userSettings.backgroundColour)
                                    .font(Font(userSettings.font))
                                    .frame(maxHeight: .infinity, alignment: .leading)
                                
                            } else {
                                //  Check whether text is a paragraph or heading by analysing paragraph line length
                                ForEach(scanResult.scannedTextList, id: \.self) { paragraph in
                                    if paragraph.count > 1 {
                                        Text(modifyText(text: paragraph.joined(separator: " ")))
                                            .foregroundColor(userSettings.fontColour)
                                            .font(Font(userSettings.headingFont))
                                            .frame(maxWidth: .infinity, alignment: .leading)
                                    } else {
                                        Text(modifyText(text: paragraph[0]))
                                            .foregroundColor(userSettings.fontColour)
                                            .font(Font(userSettings.headingFont))
                                            .fontWeight(.bold)
                                    }
                                    
                                    Text("")
                                }
                            }
                            
                            Spacer()
                            
                            if isPlaying {
                                Button(action: {
                                    isPlaying.toggle()
                                    synth.stopSpeaking(at: AVSpeechBoundary.immediate)
                                }, label: {
                                    Image(systemName: "pause.fill")
                                })
                                .padding()
                                .foregroundColor(Color(hex: 0xDF4D0F, alpha: 1))
                                .font(.system(size: 24))
                            } else {
                                Button(action: {
                                    isPlaying.toggle()
                                    text2speech()
                                }, label: {
                                    Image(systemName: "play.fill")
                                })
                                .padding()
                                .foregroundColor(Color(hex: 0xDF4D0F, alpha: 1))
                                .font(.system(size: 24))
                            }
                        }
                        .onTapGesture(count: 2) {
                            showDictionary.toggle()
                        }
                        .padding()
                        .background(userSettings.backgroundColour)
                        
                        if canvasSettings.selectedColour != .clear {
                            Canvas { ctx, size in
                                for line in canvasSettings.lines {
                                    var path = Path()
                                    path.addLines(line.points)

                                    ctx.stroke(path, with: .color(line.colour), style: StrokeStyle(lineWidth: canvasSettings.lineWidth, lineCap: .round, lineJoin: .round))
                                }
                            }
                            .gesture(DragGesture(minimumDistance: 0, coordinateSpace: .local).onChanged({ value in
                                if canvasSettings.selectedColour != .clear {
                                    let position = value.location
                                    if value.translation == .zero {
                                        canvasSettings.lines.append(Line(points: [position], colour: canvasSettings.selectedColour))
                                    } else {
                                        guard let lastIndex = canvasSettings.lines.indices.last else { return }
                                        canvasSettings.lines[lastIndex].points.append(position)
                                    }
                                }
                            }))
                        }
                    }
                                                                
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
                            
                            ForEach([Color.green, Color.blue, Color.red, Color.black], id: \.self) { colour in
                                colourButton(colour: colour)
                            }
                            clearButton()
                            eraseButton()
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
                .sheet(isPresented: $showDocumentCameraView, content: {
                    DocumentCameraView(settings: userSettings, scanResult: scanResult)
                })
                .sheet(isPresented: $showMenu, content: {
                    Menu(showDocumentCameraView: $showDocumentCameraView, showFileImporter: $showFileImporter)
                        .environmentObject(canvasSettings)
                        .presentationDetents([.fraction(0.40), .fraction(0.20)])
                        .presentationDragIndicator(.visible)
                })
                .sheet(isPresented: $showDictionary, content: {
                    DictionaryLookup(wordData: nil, state: .Stationary)
                        .environmentObject(userSettings)
                })
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
            print("here")
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
    
    
    @ViewBuilder
    func clearButton() -> some View {
        Button(action: {
            canvasSettings.selectedColour = .clear
        }, label: {
            Image(systemName: "pencil.tip")
                .font(.largeTitle)
                .foregroundColor(.gray)
        })
    }
    
    @ViewBuilder
    func eraseButton() -> some View {
        Button(action: {
            canvasSettings.lines = []
            canvasSettings.selectedColour = .clear
        }, label: {
            Image(systemName: "trash.fill")
                .font(.largeTitle)
                .foregroundColor(.gray)
        })
    }
}

struct Home_Previews: PreviewProvider {
    static var previews: some View {
        Home()
    }
}
