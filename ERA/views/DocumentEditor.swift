//
//  DocumentEditor.swift
//  ERA
//
//  Created by Siddharth Shakthivel Muthu Pandian on 15/10/2022.
//

import SwiftUI
import AVFoundation
import PDFKit
import SwiftUITooltip

class CanvasSettings: ObservableObject {
    @Published var selectedColour: Color = .black
    @Published var selectedHighlighterColour: Color = Color(hex: 0x000000, alpha: 0.5)
    @Published var lastLine: WorkingLine? // Stores the last line within the bufer
    @Published var lineBuffer: [WorkingLine] = [] // This is a buffer which holds temporary lines which are being worked upon
    @Published var lineWidth: Double = 5
    @Published var isRubbing: Bool = false
    @Published var lineCap: CGLineCap = .round
}

struct DocumentEditor: View {
    @Environment(\.managedObjectContext) var moc
    @EnvironmentObject var userSettings: UserPreferences
    @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>
    
    @State var document: FetchedResults<Document>.Element // Contains all data
    @State var scanResult: ScanResult // Specifically contains just scan data in order to minimise unwrapping/nil
    @State var images: [Image]
    
    @State var showFileExporter = false
    @State var showDictionary: Bool = false
    @State var showPencilEdit: Bool = false
    @State var pdfDocument: PDFDoc? = nil
    @State var tooltipConfig = DefaultTooltipConfig()
    
    @State var isEditingText: Bool = false
    @State var isDrawing: Bool = false
    @State var isShowingHelp: Bool = false
    
    @StateObject var speaker = Speaker()
    @StateObject var canvasStuff = CanvasSettings()
    
    @State var isViewingText: Bool = true
    
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
        speaker.synth.stopSpeaking(at: .immediate)
    }
    
    func initialisation() {
        // Configure the tooltips
        tooltipConfig.enableAnimation = true
        tooltipConfig.animationOffset = 10
        tooltipConfig.animationTime = 1
        
        // Copy data from the saved buffer into the working bufffer
        guard let lines = (document.canvasData as? CanvasData)?.lines else { return }
        for line in lines {
            canvasStuff.lineBuffer.append(WorkingLine(points: line.points, colour: line.colour, lineCap: line.lineCap, lineWidth: line.lineWidth, isHighlighter: line.isHighlighter))
        }
    }
    
    func save_document() {
        // Copy data from the working buffer into the saved buffer and attempt to save it into core data
        var savedLineBuffer: [SavedLine] = []
        for line in canvasStuff.lineBuffer {
            savedLineBuffer.append(SavedLine(points: line.points, colour: line.colour, lineCap: line.lineCap, lineWidth: line.lineWidth, isHighlighter: line.isHighlighter))
        }
       
        moc.performAndWait {
            let newDocument = Document(context: moc)
            newDocument.id = UUID()
            
            var test: [SavedParagraph] = []
            // Copy over the attributes maybe in order to save em
            for savedParagraph in scanResult.scannedTextList {
                test.append(SavedParagraph(text: savedParagraph.text as String, isHeading: savedParagraph.isHeading))
            }
            
            let best = scanResult.scannedText as String
            
            newDocument.scanResult = ScanResult(scannedTextList: test, scannedText: best)
            newDocument.title = document.title
            newDocument.images = document.images
            newDocument.canvasData = CanvasData(lines: savedLineBuffer)
            moc.delete(document)
            try? moc.save()
        }
    }
    
    var body: some View {
        GeometryReader { geometryProxy in
            NavigationView {
                VStack {
                    HStack {
                        Button {
                            presentationMode.wrappedValue.dismiss()
                        } label: {
                            Image("arrow-left")
                                .resizable()
                                .frame(width: 30, height: 30)
                                .invertOnDarkTheme()

                            Text("Document Editor")
                                .foregroundColor(.black)
                                .invertOnDarkTheme()
                                .font(.system(size: 14))
                                .fontWeight(.bold)
                                .textCase(.uppercase)
                        }
                        
                        Spacer()
                        
                        Button(action: {
                            pdfDocument = convertScreenToPDF()
                            showFileExporter.toggle()
                        }, label: {
                            Image("export")
                                .resizable()
                                .frame(width: 30, height: 35)
                                .invertOnDarkTheme()
                        })
                            .if(isShowingHelp) { view in
                                view
                                    .tooltip(.left, config: tooltipConfig) {
                                        Text("Export PDF")
                                            .font(Font(userSettings.subParagaphFont))
                                    }
                            }
                        
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
                                isEditingText = true
                                isDrawing = false
                            }, label: {
                                Image("edit-text")
                                    .resizable()
                                    .frame(width: 30, height: 30)
                                    .invertOnDarkTheme()
                            })
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
                            ScrollView(.vertical, showsIndicators: true) {
//                                if scanResult.scannedTextList.count < 1 {
//                                    // View generated on intial startup (editable)
//                                    Paragraph(paragraphFormat: $scanResult.scanHeading, isEditingText: $isEditingText, textToEdit: scanResult.scanHeading.text)
//                                    Paragraph(paragraphFormat: $scanResult.scanText, isEditingText: $isEditingText, textToEdit: scanResult.scannedText)
//                                } else {
//
//                                }
                                
                                // View generated on scan/imported PDF
                                ForEach($scanResult.scannedTextList, id: \.self) { $paragraph in
                                    Paragraph(paragraphFormat: $paragraph, isEditingText: $isEditingText, textToEdit: paragraph.text)
                                    Text("")
                                }
                            }
                            
                            if isDrawing { 
                                Canvas { ctx, size in
                                    for line in canvasStuff.lineBuffer {
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
                                                if canvasStuff.isRubbing {
                                                    canvasStuff.lineBuffer.append(WorkingLine(points: [position], colour: userSettings.backgroundColour, lineCap: canvasStuff.lineCap, lineWidth: canvasStuff.lineWidth, isHighlighter: false))
                                                } else {
                                                    if canvasStuff.lineCap == .round {
                                                        canvasStuff.lineBuffer.append(WorkingLine(points: [position], colour: canvasStuff.selectedColour, lineCap: canvasStuff.lineCap, lineWidth: canvasStuff.lineWidth, isHighlighter: false))
                                                    } else {
                                                        canvasStuff.lineBuffer.append(WorkingLine(points: [position], colour: canvasStuff.selectedHighlighterColour, lineCap: canvasStuff.lineCap, lineWidth: canvasStuff.lineWidth, isHighlighter: false))
                                                    }
                                                }
                                            } else {
                                                guard let lastIndex = canvasStuff.lineBuffer.indices.last else { return }
                                                canvasStuff.lineBuffer[lastIndex].points.append(position)
                                            }
                                        })
                                )
                            }
                        }
                            .padding()
                            .background(userSettings.backgroundColour)
                    } else {
                        // Show photo view
                        ZStack {
                            ScrollView(.vertical, showsIndicators: true) {
                                ForEach(0..<images.count, id: \.self) { imageIndex in
                                    images[imageIndex]
                                       .resizable()
                                       .frame(width: geometryProxy.size.width, height: geometryProxy.size.height * 0.85)
                                       .aspectRatio(contentMode: .fit)
                                }
                            }
                        }
                            .padding()
                            .background(userSettings.backgroundColour)
                    }
                    
                    Picker("", selection: $isViewingText) {
                        Text("Document Editor")
                            .tag(true)
                            .foregroundColor(.black)
                            .invertOnDarkTheme()
                        
                        Text("Photo Editor")
                            .tag(false)
                            .foregroundColor(.black)
                            .invertOnDarkTheme()
                    }
                        .pickerStyle(.segmented)
                        .padding(.leading)
                        .padding(.trailing)
                    
                    OptionBar(showDictionary: $showDictionary, isDrawing: $isDrawing, isEditing: $isEditingText, showPencilEdit: $showPencilEdit, isShowingHelp: $isShowingHelp)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .environmentObject(userSettings)
                        .environmentObject(canvasStuff)
                }
                .invertBackgroundOnDarkTheme(isBase: true)
            }
                .onAppear(perform: initialisation)
                .onDisappear(perform: save_document)
                .environmentObject(userSettings)
                .environmentObject(scanResult)
                .environmentObject(canvasStuff)
                .navigationBarTitle("")
                .navigationBarBackButtonHidden(true)
                .navigationBarHidden(true)
                .sheet(isPresented: $showPencilEdit, content: {
                    if canvasStuff.lineCap == .round {
                        EditPencil(drawingToolName: "Pencil")
                            .environmentObject(canvasStuff)
                            .environmentObject(userSettings)
                            .presentationDetents([.fraction(0.30)])
                            .presentationDragIndicator(.visible)
                    } else {
                        EditPencil(drawingToolName: "Highlighter")
                            .environmentObject(canvasStuff)
                            .environmentObject(userSettings)
                            .presentationDetents([.fraction(0.30)])
                            .presentationDragIndicator(.visible)
                    }
                })
                .sheet(isPresented: $showDictionary, content: {
                    DictionaryLookup(wordData: nil, state: .Stationary)
                        .environmentObject(userSettings)
                })
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



//struct Home_Previews: PreviewProvider {
//    static var previews: some View {
//        Home(showMenu: false)
//    }
//}
