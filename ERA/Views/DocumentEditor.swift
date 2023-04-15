//
//  DocumentEditor.swift
//  ERA
//
//  Created by Siddharth Shakthivel Muthu Pandian on 15/10/2022.
//

import SwiftUI
import AVFoundation
import PDFKit

import MLKit
import MLKitTranslate
import Zoomable

class TempCanvas: ObservableObject {
    @Published var isUsingHighlighter: Bool = false
    @Published var selectedColour: Color = .black
    @Published var selectedHighlighterColour: Color = Color(hex: 0xFFFF00, alpha: 0.5)
    @Published var lastLine: WorkingLine? // Stores the last line within the bufer
    @Published var lineBuffer: [WorkingLine] = [] // This is a buffer which holds temporary lines which are being worked upon
    @Published var lineWidth: Double = 2
    @Published var isRubbing: Bool = false
}

extension String {
    func splitTest(width: CGFloat, font: UIFont) -> [String] {
        print(width)
        
        guard !self.isEmpty else { return [String]() }

        var lines = [String]()

        // set up range of the split
        var splitStart = self.startIndex
        var splitEnd = self.startIndex

        repeat {
            // advance the end range for the split
            splitEnd = self.index(after: splitStart)

            // initial split to test
            var line = String(self[splitStart..<splitEnd])

            // while we're before the end test the rendered width
            while splitEnd < self.endIndex &&
                    line.size(withAttributes: [NSAttributedString.Key.font: font]).width < (width - 25) {
                // add one more character
                splitEnd = self.index(after: splitEnd)
                line = String(self[splitStart..<splitEnd])
            }
            
            print(line)

            // add split to array and set up next split
            lines.append(line)
            splitStart = splitEnd
        } while splitEnd < self.endIndex // don't go past the end of the string


        // add remainder of string to array
        lines.append(String(self[splitStart..<self.endIndex]))
        return lines
    }
}

struct DocumentEditor: View {
    @Environment(\.managedObjectContext) var moc
    @EnvironmentObject var userSettings: UserPreferences
    @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>
    
    @State var document: FetchedResults<Document>.Element // Contains all data
    @State var scanResult: ScanResult // Specifically contains just scan data in order to minimise unwrapping/nil
    @State var images: [UIImage]
    
    @State var showFileExporter: Bool = false
    @State var pdfDocument: PDFDoc? = nil

    @State var isEditingText: Bool = false
    @State var isDrawing: Bool = false
    @State var isShowingHelp: Bool = false
    @State var utilityBarStatus: UtilityBarStatus = .UtilityBar
    
    @State var downloadStatus: DownloadStatus = .Off
    
    @StateObject var speaker = Speaker()
    
    @StateObject var textEditorCanvas = TempCanvas()
    @StateObject var photoEditorCanvas = TempCanvas()

    @State var isViewingText: Bool = true
    @State var shouldTranslateText: Bool = false
    
    @State var currentTranslator: Translator = Translator.translator(options: TranslatorOptions(sourceLanguage: TranslateLanguage(rawValue: "en"), targetLanguage: TranslateLanguage(rawValue: "fr")))
    
    @GestureState private var scale: CGFloat = 1.0
    
    func speak_text() {
        do {
            try AVAudioSession.sharedInstance().setCategory(.playback,mode: .default)
        } catch let error {
            print("This error message from SpeechSynthesizer \(error.localizedDescription)")
        }
            
        let utterance = AVSpeechUtterance(string: scanResult.scannedText)
        utterance.voice = AVSpeechSynthesisVoice(language: userSettings.voice)
        utterance.volume = userSettings.volume
        utterance.pitchMultiplier = userSettings.pitch
        utterance.rate = userSettings.rate
        speaker.synth.speak(utterance)
    }
    
    func stop_speaking() {
        if speaker.synth.isSpeaking {
            speaker.synth.stopSpeaking(at: .immediate)
        }
    }
    
    func initialisation() {
        // Copy data from the saved buffer into the working bufffer
        guard let lines = (document.textCanvasData as? CanvasData)?.lines else { return }
        for line in lines {
            textEditorCanvas.lineBuffer.append(WorkingLine(points: line.points, colour: line.colour, lineCap: line.lineCap, lineWidth: line.lineWidth))
        }
        
        guard let photoLines = (document.photoCanvasData as? CanvasData)?.lines else { return }
        for line in photoLines {
            photoEditorCanvas.lineBuffer.append(WorkingLine(points: line.points, colour: line.colour, lineCap: line.lineCap, lineWidth: line.lineWidth))
        }
    }
    
    func save_document() {
        // Copy data from the working buffer into the saved buffer and attempt to save it into core data
        var savedLineBuffer: [SavedLine] = []
        for line in textEditorCanvas.lineBuffer {
            savedLineBuffer.append(SavedLine(points: line.points, colour: line.colour, lineCap: line.lineCap, lineWidth: line.lineWidth))
        }
        
        var savedPhotoLineBuffer: [SavedLine] = []
        for line in photoEditorCanvas.lineBuffer {
            savedPhotoLineBuffer.append(SavedLine(points: line.points, colour: line.colour, lineCap: line.lineCap, lineWidth: line.lineWidth))
        }
       
        moc.performAndWait {
            let newDocument = Document(context: moc)
            newDocument.id = UUID()
            
            var test: [SavedParagraph] = []
            
//          Copy over the attributes maybe in order to save em
            for savedParagraph in scanResult.scannedTextList {
                test.append(SavedParagraph(text: savedParagraph.text as String, isHeading: savedParagraph.isHeading))
            }

            let best = scanResult.scannedText as String
            
            newDocument.scanResult = ScanResult(scannedTextList: test, scannedText: best)
            newDocument.title = document.title
            newDocument.images = document.images
            newDocument.textCanvasData = CanvasData(lines: savedLineBuffer)
            newDocument.photoCanvasData = CanvasData(lines: savedPhotoLineBuffer)
            moc.delete(document)
            try? moc.save()
        }
    }
    
    @EnvironmentObject private var purchaseManager: PurchaseManager
    
    var body: some View {
        GeometryReader { geometryProxy in
            NavigationView {
                VStack {
                    HStack {
                        Button {
                            presentationMode.wrappedValue.dismiss()
                            stop_speaking()
                        } label: {
                            Image("arrow-left")
                                .resizable()
                                .frame(width: 30, height: 30)
                                .invertOnDarkTheme()

                            Text("Document Editor")
                                .foregroundColor(.black)
                                .invertOnDarkTheme()
                                .font(.system(size: 14, weight: .bold))
                                .textCase(.uppercase)
                        }

                        Spacer()

                        if (purchaseManager.hasUnlockedPremium) {
                            Button(action: {
                                pdfDocument = convertScreenToPDF()
                                showFileExporter.toggle()
                            }, label: {
                                Image("export")
                                    .resizable()
                                    .frame(width: 30, height: 35)
                                    .invertOnDarkTheme()
                            })
                        }

                        if (purchaseManager.hasUnlockedPremium) {
                            Button(action: {
                                // Save button which saves data to core data
                                isEditingText = false
                                isDrawing = false
                                save_document()
                            }, label: {
                                Image("save")
                                    .resizable()
                                    .frame(width: 20, height: 30)
                                    .invertOnDarkTheme()
                            })
                            
                            if isEditingText {
                                // Needs to save changes
                                Button(action: {
                                    isEditingText = false
                                    isDrawing = false
                                }, label: {
                                    Image("stop-editing")
                                        .resizable()
                                        .frame(width: 30, height: 30)
                                        .invertOnDarkTheme()
                                })
                            } else {
                                Button(action: {
                                    if utilityBarStatus != .TranslationBar {
                                        isEditingText = true
                                        isDrawing = false
                                    }
                                }, label: {
                                    Image("edit-text")
                                        .resizable()
                                        .frame(width: 30, height: 30)
                                        .invertOnDarkTheme()
                                })
                            }
                        }

                        if speaker.isPlayingAudio {
                            Button(action: {
                                // Check whether the speaker is paused or not
                                speaker.synth.pauseSpeaking(at: AVSpeechBoundary.immediate)
                                speaker.isPlayingAudio.toggle()
                            }, label: {
                                Image("pause")
                                    .resizable()
                                    .frame(width: 25, height: 25)
                                    .invertOnDarkTheme()
                            })
                        } else {
                            // Present play button and allow text to be played
                            Button(action: {
                                if speaker.synth.isPaused {
                                    speaker.synth.continueSpeaking()
                                } else {
                                    self.speak_text()
                                }
                                speaker.isPlayingAudio.toggle()
                            }, label: {
                                Image("play")
                                    .resizable()
                                    .frame(width: 25, height: 25)
                                    .invertOnDarkTheme()
                            })
                        }

                        NavigationLink(destination: Settings()) {
                            Image("settings")
                                .resizable()
                                .frame(width: 30, height: 30)
                                .invertOnDarkTheme()
                        }
                    }
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.trailing)
                        .padding(.leading)
                    
                    Divider()
                    
                    if isViewingText {
                        // Show the document view in which users can edit text
                        ZStack {
                            GeometryReader { testing in
                                ScrollView(.vertical, showsIndicators: true) {
                                    //                                 View generated on scan/imported PDF
                                    ForEach($scanResult.scannedTextList, id: \.self) { $paragraph in
                                        Group {
    //                                        Paragraph(paragraphFormat: $paragraph, isEditingText: $isEditingText, shouldTranslateText: $shouldTranslateText, currentTranslator: $currentTranslator, text: paragraph.text, width: geometryProxy.size.width, sentences: getSentences(text: paragraph.text, width: geometryProxy.size.width, fontWidth: CGFloat(userSettings.paragraphFontSize)))
                                            
                                            Paragraph(paragraphFormat: $paragraph, isEditingText: $isEditingText, shouldTranslateText: $shouldTranslateText, currentTranslator: $currentTranslator, text: paragraph.text, width: geometryProxy.size.width, sentences: paragraph.text.trimmingCharacters(in: .whitespacesAndNewlines).splitTest(width: testing.size.width, font: userSettings.paragraphFont))
                                            
                                            Text("")
                                        }
                                    }
                                }
                            }
                                
                            if isDrawing {
                                Canvas { ctx, size in
                                    for line in textEditorCanvas.lineBuffer {
                                        var path = Path()
                                        path.addLines(line.points)

                                        ctx.stroke(path, with: .color(line.colour), style: StrokeStyle(lineWidth: line.lineWidth ))
                                    }
                                }
                                .gesture(
                                    DragGesture(minimumDistance: 0, coordinateSpace: .local)
                                        .onChanged({ value in
                                            let position = value.location
                                            if value.translation == .zero {
                                                let lineCapStyle: CGLineCap = textEditorCanvas.isUsingHighlighter ? CGLineCap.butt : CGLineCap.round;
                                                let lineColour: Color = textEditorCanvas.isUsingHighlighter ? textEditorCanvas.selectedHighlighterColour : textEditorCanvas.selectedColour;

                                                if textEditorCanvas.isRubbing {
                                                    textEditorCanvas.lineBuffer.append(WorkingLine(points: [position], colour: userSettings.backgroundColour, lineCap: .round, lineWidth: textEditorCanvas.lineWidth))
                                                } else {
                                                    textEditorCanvas.lineBuffer.append(WorkingLine(points: [position], colour: lineColour, lineCap: lineCapStyle, lineWidth: textEditorCanvas.lineWidth))
                                                }
                                            } else {
                                                guard let lastIndex = textEditorCanvas.lineBuffer.indices.last else { return }
                                                textEditorCanvas.lineBuffer[lastIndex].points.append(position)
                                            }
                                        }))
                            }
                        }
                        .padding()
                        .background(userSettings.backgroundColour)
                    } else {
                        // Show photo view
                        ZStack {
                            ScrollView(.vertical, showsIndicators: true) {
                                ForEach(0..<images.count, id: \.self) { imageIndex in
                                    ZoomableView(size: CGSize(width: geometryProxy.size.width, height: geometryProxy.size.height * 0.85), min: 0.5, max: 50.0, showsIndicators: true) {
                                        Image(uiImage: images[imageIndex])
                                            .resizable()
                                            .scaledToFit()
                                            .background(Color.black)
                                            .clipped()
                                    }
                                }
                            }

                            if isDrawing {
                                Canvas { ctx, size in
                                    for line in photoEditorCanvas.lineBuffer {
                                        var path = Path()
                                        path.addLines(line.points)

                                        ctx.stroke(path, with: .color(line.colour), style: StrokeStyle(lineWidth: line.lineWidth ))
                                    }
                                }
                                .gesture(
                                    DragGesture(minimumDistance: 0, coordinateSpace: .local)
                                        .onChanged({ value in
                                            let position = value.location
                                            if value.translation == .zero {

                                                let lineCapStyle: CGLineCap = photoEditorCanvas.isUsingHighlighter ? CGLineCap.butt : CGLineCap.round;
                                                let lineColour: Color = photoEditorCanvas.isUsingHighlighter ? photoEditorCanvas.selectedHighlighterColour : photoEditorCanvas.selectedColour;

                                                if photoEditorCanvas.isRubbing {
                                                    photoEditorCanvas.lineBuffer.append(WorkingLine(points: [position], colour: userSettings.backgroundColour, lineCap: lineCapStyle, lineWidth: photoEditorCanvas.lineWidth))
                                                } else {
                                                    photoEditorCanvas.lineBuffer.append(WorkingLine(points: [position], colour: lineColour, lineCap: lineCapStyle, lineWidth: photoEditorCanvas.lineWidth))
                                                }
                                            } else {
                                                guard let lastIndex = photoEditorCanvas.lineBuffer.indices.last else { return }
                                                photoEditorCanvas.lineBuffer[lastIndex].points.append(position)
                                            }
                                        })
                                )
                            }
                        }
                            .padding()
                            .background(userSettings.backgroundColour)
                    }
                    
//                    DownloadBar(downloadStatus: $downloadStatus)
//
//                    Picker("", selection: $isViewingText) {
//                        Text("Document Editor")
//                            .tag(true)
//                            .foregroundColor(.black)
//                            .invertOnDarkTheme()
//
//                        Text("Photo Editor")
//                            .tag(false)
//                            .foregroundColor(.black)
//                            .invertOnDarkTheme()
//                    }
//                        .pickerStyle(.segmented)
//                        .padding(.leading)
//                        .padding(.trailing)
//
//                    UtilityBar(isDrawing: $isDrawing, isEditing: $isEditingText, utilityBarStatus: $utilityBarStatus, downloadStatus: $downloadStatus, currentTranslator: $currentTranslator, shouldTranslateText: $shouldTranslateText)
//                        .environmentObject(isViewingText ? textEditorCanvas : photoEditorCanvas)
                }
                .invertBackgroundOnDarkTheme(isBase: true)
            }
                .onAppear(perform: initialisation)
                .onDisappear(perform: save_document)
                .environmentObject(userSettings)
                .environmentObject(scanResult)
                .environmentObject(textEditorCanvas)
                .navigationBarTitle("")
                .navigationBarBackButtonHidden(true)
                .navigationBarHidden(true)
                .fileExporter(
                   isPresented: $showFileExporter,
                   document: pdfDocument,
                   contentType: UTType.pdf,
                   defaultFilename: "NewPDF"
                ) { result in }
               .gesture(
                MagnificationGesture()
                    .onChanged { newScale in
                        let newFontSize = CGFloat(userSettings.paragraphFontSize) * newScale

                        userSettings.paragraphFont = UIFont(descriptor: userSettings.paragraphFont.fontDescriptor, size: newFontSize)
                        userSettings.headingFont = UIFont(descriptor: userSettings.paragraphFont.fontDescriptor, size: CGFloat(newFontSize * 1.5))
                        userSettings.subheadingFont = UIFont(descriptor: userSettings.paragraphFont.fontDescriptor, size: CGFloat(newFontSize * 1.25))
                        userSettings.subParagaphFont = UIFont(descriptor: userSettings.paragraphFont.fontDescriptor, size: CGFloat(newFontSize * 0.75))
                    }
               )
        }
    }
}

