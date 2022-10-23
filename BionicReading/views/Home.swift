//
//  Home.swift
//  BionicReading
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
    @Published var scannedTextList: [[String]] = []
    @Published var scannedText: String = "Hello world. This is an example document for the amazing lookup view"
    @Published var utterance = AVSpeechUtterance(string: "hello world")
}

struct Home: View {
    @State var showDocumentCameraView = false
    @State private var showFileImporter = false
    @State private var showFileExporter = false
    
    @StateObject var userSettings = UserCustomisations()
    @StateObject var scanResult = ScanResult()
    @State var isPlaying: Bool = false
    @State var showLookupView: Bool = false
    @State var lookupWord: String = "go"
    
    @State var isExporting: Bool = false
    
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
    func modifyText(text: String) -> LocalizedStringKey {
        if (userSettings.isBionicReading) {
            var markdownStringArray: [String] = []
            
            for substring in text.split(separator: " ") {
                markdownStringArray.append(convertToBionic(text: String(substring)))
            }

            return LocalizedStringKey(markdownStringArray.joined(separator: " "))
        }
        
        return LocalizedStringKey(text)
    }
    
    func text2speech() {
        let utterance = AVSpeechUtterance(string: scanResult.scannedText)
        utterance.voice = AVSpeechSynthesisVoice(language: "en-GB")
        self.synth.speak(utterance)
    }
    
    func exportToPDF() -> URL {
        print("Here?")
        isExporting = true
        
        let outputFileURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!.appendingPathComponent("SwiftUI.pdf")
        let pageSize = CGSize(width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height)
        let rootVC = UIApplication.shared.windows.first?.rootViewController

        //Render the PDF
        let pdfRenderer = UIGraphicsPDFRenderer(bounds: CGRect(origin: .zero, size: pageSize))
        DispatchQueue.main.async {
            do {
                try pdfRenderer.writePDF(to: outputFileURL, withActions: { (context) in
                    context.beginPage()
                    rootVC?.view.layer.render(in: context.cgContext)
                })
                print("wrote file to: \(outputFileURL.path)")
            } catch {
                print("Could not create PDF file: \(error.localizedDescription)")
            }
        }
        
        isExporting = false
        
        return outputFileURL
    }
    
    var body: some View {
        NavigationView {
            VStack {
                HStack {
                    Text("Easy Reading Assistant")
                        .foregroundColor(.black)
                        .fontWeight(.bold)
                        .textCase(.uppercase)
                        .contextMenu {
                            Button(action: {
                                showFileExporter.toggle()
                            }, label: {
                                Text("Export to PDF")
                            })
                            
                            Button(action: {
                                showFileImporter.toggle()
                            }, label: {
                                Text("Upload PDF")
                            })
                        }

                    Spacer()
                    
                    NavigationLink(destination: Settings()) {
                        Image("setting")
                    }
                }
                .padding()
                
                Divider()
                
                Group {
                    ScrollViewReader { proxy in
                        ScrollView(.vertical, showsIndicators: true) {
                            if scanResult.scannedTextList.count < 1 {
                                Text(modifyText(text: "Document Heading"))
                                    .foregroundColor(userSettings.fontColour)
                                    .font(Font(userSettings.headingFont))
                                    .fontWeight(.bold)
                                
                                Text(modifyText(text: "\(scanResult.scannedText)"))
                                    .foregroundColor(userSettings.fontColour)
                                    .font(Font(userSettings.font))
                                    .lineSpacing(10)
                                    .gesture(DragGesture(minimumDistance: 0, coordinateSpace: .local).onEnded { dragGesture in
                                        print(dragGesture.location.x)
                                        
                                    })
                                    .contextMenu {
                                        Button(action: {
                                            showLookupView.toggle()
                                            lookupWord = "go"
                                        }, label: {
                                            Text("Lookup")
                                        })
                                    }
                            } else {
                                //  Check whether text is a paragraph or heading by analysing paragraph line length
                                ForEach(scanResult.scannedTextList, id: \.self) { paragraph in
                                    if paragraph.count > 1 {
                                        Text(modifyText(text: paragraph.joined(separator: " ")))
                                            .foregroundColor(userSettings.fontColour)
                                            .font(Font(userSettings.headingFont))
                                    } else {
                                        Text(modifyText(text: paragraph[0]))
                                            .foregroundColor(userSettings.fontColour)
                                            .font(Font(userSettings.headingFont))
                                            .fontWeight(.bold)
                                    }
                                    
                                    Text("")
                                }
                            }
                            
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
                        .padding()
                        .background(userSettings.backgroundColour)
                    }
                }
                .padding()
                
                Group {
                   VStack {
                       Button {
                           showDocumentCameraView.toggle()
                       } label: {
                           HStack {
                               Image("scan")
                               
                               Text("Scan Document")
                                   .foregroundColor(.black)
                                   .textCase(.uppercase)
                                   .fontWeight(.semibold)
                                   .font(.system(size: 14))
                               
                               Image("arrow-right")
                                   .frame(maxWidth: .infinity, alignment: .trailing)
                           }
                           .padding()
                       }
                       .frame(maxWidth: .infinity, alignment: .leading)
                       
                       Divider()
                           .padding(.horizontal, 30)
                       
                       Button {
                           showFileImporter.toggle()
                       } label: {
                           HStack {
                               Image("upload")
                               
                               Text("Upload Document")
                                   .foregroundColor(.black)
                                   .fontWeight(.semibold)
                                   .textCase(.uppercase)
                                   .font(.system(size: 14))
                               
                               Image("arrow-right")
                                   .frame(maxWidth: .infinity, alignment: .trailing)
                           }
                               .padding()
                       }
                           .frame(maxWidth: .infinity, alignment: .leading)
                   }
               }
                   .background(Color.white)
            }
                .background(Color(hex: 0xFFF9F0, alpha: 1))
        }
            .environmentObject(userSettings)
            .environmentObject(scanResult)
            .navigationBarTitle("")
            .navigationBarBackButtonHidden(true)
            .navigationBarHidden(true)
            .sheet(isPresented: $showDocumentCameraView, content: {
                DocumentCameraView(settings: userSettings, scanResult: scanResult)
            })
            .sheet(isPresented: $showLookupView, content: {
                Lookup(word: "copy", wordData: nil, state: .Fetching)
                    .environmentObject(userSettings)
            })
            .fileImporter(isPresented: $showFileImporter, allowedContentTypes: [.pdf], onCompletion: { result in
                do {
                    let url = try result.get()
                    let images = convertPDFToImages(url: url)
                    var (paragraphs, joinedParagraphs) = testScanPDF(scan: images)
                    self.scanResult.scannedTextList = paragraphs
                    self.scanResult.scannedText = joinedParagraphs
                } catch {
                    print("OH DEAR")
                }
            })
            .fileExporter(isPresented: $showFileExporter, document: PDFDoc(teest: exportToPDF()), contentType: .plainText) { result in
                switch result {
                case .success(let url):
                    print("Saved to \(url)")
                case .failure(let error):
                    print(error.localizedDescription)
                }
            }
    }
}

struct Home_Previews: PreviewProvider {
    static var previews: some View {
        Home()
    }
}
