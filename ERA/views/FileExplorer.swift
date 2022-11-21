//
//  FileExplorer.swift
//  ERA
//
//  Created by Siddharth Shakthivel Muthu Pandian on 19/11/2022.
//

import SwiftUI
import AVFoundation

struct FileExplorer: View {
    @Environment(\.managedObjectContext) var moc
    @EnvironmentObject var userSettings: UserPreferences
    
    let columns: [GridItem] = Array(repeating: GridItem(.flexible()), count: 2)
    
    /*
     Retriving data from core data is done using fetch request (description of how data should be sent, sorted, filters)
     */
    @FetchRequest(sortDescriptors: []) var files: FetchedResults<ScanTest>
    
    @State var showMenu: Bool = false
    @State var showDocumentCameraView = false
    @State var showFileImporter = false
    @State var showDictionary: Bool = false
    @State var showEditDocumentProperties: Bool = false
    
    @State var currentDocument: ScanTest?
    
    var accents: [String] = AVSpeechSynthesisVoice.speechVoices().map { $0.language }
        
    var body: some View {
        GeometryReader { geometryProxy in
            NavigationView {
                VStack {
                    HStack {
                        Text("Easy Reading Assistant")
                            .foregroundColor(.black)
                            .invertOnDarkTheme()
                            .fontWeight(.bold)
                            .textCase(.uppercase)
                            .frame(maxWidth: .infinity, alignment: .leading)
                        
                        Spacer()
                        
                        NavigationLink(destination: Settings()) {
                            Image("settings")
                                .resizable()
                                .frame(width: 30, height: 30)
                                .invertOnDarkTheme()
                        }
                    }
                    .padding(.leading)
                    .padding(.trailing)
                    
                    Divider()
                    
                    Text("Home")
                        .foregroundColor(.black)
                        .invertOnDarkTheme()
                        .font(.system(size: 24))
                        .fontWeight(.semibold)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding()
                    
                    ScrollView {
                        ZStack {
                            LazyVGrid(columns: columns, spacing: 20) {
                                ForEach(files, id: \.id) { file in
                                    NavigationLink(destination: DocumentEditor( scanResult: file.scanResult!, images: getImagesfromData(data: file.images!))) {
                                        ZStack {
                                            if (userSettings.isDarkMode) {
                                                RoundedRectangle(cornerRadius: 10)
                                                    .fill(ColourConstants.darkModeDarker)
                                            } else {
                                                RoundedRectangle(cornerRadius: 10)
                                                    .fill(ColourConstants.lightModeLighter)
                                            }
                                            
                                            VStack {
                                                getFirstImageFromData(data: file.images!)?
                                                    .resizable()
                                                    .frame(width: 100, height: 200)
                                                    .aspectRatio(contentMode: .fit)
                                                
                                                Text("\(file.title ?? "Unknown Title")")
                                            }
                                            .padding()
                                        }
                                        .contextMenu {
                                            Button {
                                                // Delete an entry from core data
                                                moc.delete(file)
                                                try? moc.save()
                                            } label: {
                                                Text("Delete")
                                            }
                                            
                                            Button {
                                                currentDocument = file
                                                showEditDocumentProperties = true
                                            } label: {
                                                Text("Edit")
                                            }
                                        }
                                    }
                                }
                                .padding()
                            }
                        }
                    }
                    
                    HStack() {
                        ZStack {
                            Circle()
                                .fill(Color(hex: 0xc24e1c))
                                .invertOnDarkTheme()
                                .frame(width: 70, height: 70)
                            
                            Button(action: {
                                showMenu.toggle()
                            }, label: {
                                Image("menu")
                                    .resizable()
                                    .frame(width: 35, height: 35, alignment: .leading)
                                    .padding()
                                    .invertOnDarkTheme()
                            })
                        }
                        
                        Spacer()
                    }
                    .padding(.leading)
                }
                    .invertBackgroundOnDarkTheme(isBase: true)
                    .sheet(isPresented: $showMenu, content: {
                        Menu(showDocumentCameraView: $showDocumentCameraView, showFileImporter: $showFileImporter, showDictionary: $showDictionary, showMenu: $showMenu)
                                .environmentObject(userSettings)
                            .presentationDetents([.fraction(0.30)])
                            .presentationDragIndicator(.visible)
                    })
                    .fileImporter(isPresented: $showFileImporter, allowedContentTypes: [.pdf], onCompletion: { result in
                        do {
                            let url = try result.get()  // Retrieve exact URL on site
                            let images = convertPDFToImages(url: url) // Use URL to conver the file into an array of photos
                            let result = convertPhotosToParagraphs(scan: images) // Get paragraph information
                            
                            // Create new scanResult which is saved into core data
                            let newScanResult = ScanTest(context: moc)
                            newScanResult.id = UUID()
                            newScanResult.scanResult = ScanResult(scannedTextList: result.0, scannedText: result.1)
                            newScanResult.title = "Scan" + getDate()
                            
                            // Save images
                            let imageDataArray = convertImagesToData(images: images)
                            let colatedImageData = try NSKeyedArchiver.archivedData(withRootObject: imageDataArray, requiringSecureCoding: true)
                            newScanResult.images = colatedImageData
                            
                            try? moc.save()
                            
                        } catch {
                            print("OH DEAR")
                        }
                    })
                    .sheet(isPresented: $showDocumentCameraView, content: {
                        DocumentCameraView()
                    })
                    .sheet(isPresented: $showEditDocumentProperties) {
                        EditDocumentPropertiesTest(document: $currentDocument)
                    }
                    .sheet(isPresented: $showDictionary, content: {
                        DictionaryLookup(wordData: nil, state: .Stationary)
                            .environmentObject(userSettings)
                    })
            }
        }
    }
}

struct EditDocumentPropertiesTest: View {
    @Binding var document: ScanTest?
    var body: some View {
        EditDocumentProperties(scanTest: document!, title: document!.title ?? "Unknown")
    }
}

struct FileExplorer_Previews: PreviewProvider {
    static var previews: some View {
        FileExplorer()
    }
}
