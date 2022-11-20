//
//  FileExplorer.swift
//  ERA
//
//  Created by Siddharth Shakthivel Muthu Pandian on 19/11/2022.
//

import SwiftUI

struct FileExplorer: View {
    @Environment(\.managedObjectContext) var moc
    @EnvironmentObject var userSettings: UserPreferences
    
    let columns: [GridItem] = Array(repeating: GridItem(.flexible()), count: 2)
    
    /*
     Retriving data from core data is done using fetch request (description of how data should be sent, sorted, filters)
     */
    @FetchRequest(sortDescriptors: []) var files: FetchedResults<ScanTest>
    
    @State var showDocumentCameraView = false
    @State var showFileImporter = false
    @State var showFileExporter = false
    @State var showMenu: Bool = false
    @State var showDictionary: Bool = false
    @State var showPencilEdit: Bool = false
    
    @StateObject var scanResult = ScanResult() // Needs to be removed
    
    var body: some View {
        GeometryReader { geometryProxy in
            VStack {
                HStack {
                    Text("Easy Reading Assistant")
                        .foregroundColor(.black)
                        .invertOnDarkTheme()
                        .fontWeight(.bold)
                        .textCase(.uppercase)
                        .frame(maxWidth: .infinity, alignment: .leading)
                }
                    .padding(.leading)
                
                Divider()
                
                Text("Home")
                    .foregroundColor(.black)
                    .invertOnDarkTheme()
                    .font(.system(size: 24))
                    .fontWeight(.semibold)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.leading)
                    
                
                ScrollView {
                    LazyVGrid(columns: columns, spacing: 30) {
                        ForEach(files, id: \.id) { file in
                            Text(file.title ?? "")
                        }
                    }
                    
//                    Button(action: {
//                        let scanTest = ScanTest(context: moc)
//                        scanTest.id = UUID()
//                        scanTest.testStuff = ScanResult()
//                    }, label: {
//                        Text("Click me")
//                            .background(.red)
//                    })
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
            .invertBackgroundOnDarkTheme()
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
                    newScanResult.title = "Scan" + DateFormatter().string(from: Date())
                    try? moc.save()
                    
                } catch {
                    print("OH DEAR")
                }
            })
            .sheet(isPresented: $showDocumentCameraView, content: {
                DocumentCameraView()
            })
            .sheet(isPresented: $showDictionary, content: {
                DictionaryLookup(wordData: nil, state: .Stationary)
                    .environmentObject(userSettings)
            })
        }
    }
}

struct FileExplorer_Previews: PreviewProvider {
    static var previews: some View {
        FileExplorer()
    }
}
