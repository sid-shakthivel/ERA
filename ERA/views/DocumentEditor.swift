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
    @Published var lines: [Line] = []
    @Published var lastLine: Line?
    @Published var lineWidth: Double = 5
    @Published var isRubbing: Bool = false
    @Published var lineCap: CGLineCap = .round
}

struct Line {
    var points: [CGPoint]
    var colour: Color
    var lineCap: CGLineCap
    var lineWidth: Double
    var isHighlighter: Bool
}

struct DocumentEditor: View {
    @EnvironmentObject var userSettings: UserPreferences
    @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>
    
    @State var scanResult: ScanResult
    @State var images: [Image]
    
    @State var showFileExporter = false
    @State var showDictionary: Bool = false
    @State var showPencilEdit: Bool = false
    @State var document: PDFDoc? = nil
    @State var tooltipConfig = DefaultTooltipConfig()
    
    @State var isEditingText: Bool = false
    @State var isDrawing: Bool = false
    @State var isShowingHelp: Bool = false
    
    @StateObject var canvasSettings = CanvasSettings()
    @StateObject var speaker = Speaker()
    
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
    
    func setup_tooltips() {
        tooltipConfig.enableAnimation = true
        tooltipConfig.animationOffset = 10
        tooltipConfig.animationTime = 1
    }
    
    func initialisation() {
        setup_tooltips()
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
                            document = convertScreenToPDF()
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
                    
                    TabView {
                        ZStack {
                            ScrollView(.vertical, showsIndicators: true) {
                                if scanResult.scannedTextList.count < 1 {
                                    // View generated on intial startup (editable)
                                    Paragraph(paragraphFormat: $scanResult.scanHeading, isEditingText: $isEditingText, textToEdit: scanResult.scanHeading.text)
                                    Paragraph(paragraphFormat: $scanResult.scanText, isEditingText: $isEditingText, textToEdit: scanResult.scannedText)
                                } else {
                                    // View generated on scan/imported PDF
                                    ForEach($scanResult.scannedTextList, id: \.self) { $paragraph in
                                        Paragraph(paragraphFormat: $paragraph, isEditingText: $isEditingText, textToEdit: paragraph.text)
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
                                            canvasSettings.lines.append(Line(points: [position], colour: userSettings.backgroundColour, lineCap: canvasSettings.lineCap, lineWidth: canvasSettings.lineWidth, isHighlighter: false))
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
                            .tabItem {
                                Text("Text Editor")
                                    .foregroundColor(.black)
                                    .invertOnDarkTheme()
                                    .font(.system(size: 20))
                                    .textCase(.uppercase)
                            }
                        
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
                            .tabItem {
                                Text("Photo Viewer")
                                    .foregroundColor(.black)
                                    .invertOnDarkTheme()
                                    .font(.system(size: 20))
                                    .textCase(.uppercase)
                            }
                        
                    }

                    
                    OptionBar(showDictionary: $showDictionary, isDrawing: $isDrawing, isEditing: $isEditingText, showPencilEdit: $showPencilEdit, isShowingHelp: $isShowingHelp)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .environmentObject(userSettings)
                        .environmentObject(canvasSettings)
                }
                .invertBackgroundOnDarkTheme(isBase: true)
            }
                .onAppear(perform: initialisation)
                .environmentObject(userSettings)
                .environmentObject(scanResult)
                .environmentObject(canvasSettings)
                .navigationBarTitle("")
                .navigationBarBackButtonHidden(true)
                .navigationBarHidden(true)
                .sheet(isPresented: $showPencilEdit, content: {
                    if canvasSettings.lineCap == .round {
                        EditPencil(drawingToolName: "Pencil")
                            .environmentObject(canvasSettings)
                            .environmentObject(userSettings)
                            .presentationDetents([.fraction(0.30)])
                            .presentationDragIndicator(.visible)
                    } else {
                        EditPencil(drawingToolName: "Highlighter")
                            .environmentObject(canvasSettings)
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
                   document: document,
                   contentType: UTType.pdf,
                   defaultFilename: "NewPDF"
                ) { result in }
               .gesture(
                MagnificationGesture()
                    .onChanged { newScale in
                        let newFontSize = min(CGFloat(userSettings.paragraphFontSize) * newScale, 1.5)

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
