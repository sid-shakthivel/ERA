//
//  FileExplorer.swift
//  ERA
//
//  Created by Siddharth Shakthivel Muthu Pandian on 19/11/2022.
//

import SwiftUI
import SwiftUITooltip

struct FileExplorer: View {
    @Environment(\.managedObjectContext) var moc
    @EnvironmentObject var userSettings: UserPreferences
    
    let columns: [GridItem] = Array(repeating: GridItem(.flexible()), count: 2)
    
    /*
     Retriving data from core data is done using fetch request (description of how data should be sent, sorted, filters)
     */
    @FetchRequest(sortDescriptors: []) var files: FetchedResults<Document>
    
    @State var showMenu: Bool = false
    @State var showDocumentCameraView = false
    @State var showFileImporter = false
    @State var showDictionary: Bool = false
    @State var showEditDocumentProperties: Bool = false
    
    @State var currentDocument: Document?
    
    @State var isLoading: Bool = false
    
    @State var isShowingHelp = false
    
    @State var tooltipConfig = DefaultTooltipConfig()
    
    func initialisation() {
        tooltipConfig.enableAnimation = true
        tooltipConfig.animationOffset = 10
        tooltipConfig.animationTime = 1
        tooltipConfig.showArrow = false
    }
        
    var body: some View {
        NavigationView {
            GeometryReader { geometryProxy in
                VStack {
                    HStack {
                        Text("Easy Reading Assistant")
                            .foregroundColor(.black)
                            .invertOnDarkTheme()
                            .font(.system(size: 20, weight: .bold))
                            .textCase(.uppercase)
                            .frame(maxWidth: .infinity, alignment: .leading)
                        
                        Spacer()
                        
                        NavigationLink(destination: Help()) {
                            Image("info")
                                .resizable()
                                .frame(width: 30, height: 30)
                                .invertOnDarkTheme()
                        }
                        
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
                        .font(.system(size: 24, weight: .semibold))
                        .frame(maxWidth: .infinity, alignment: .center)
                        .padding(.leading)
                    
                    ScrollView {                        
                        ZStack {
                            if files.count == 0 {
                                Text("You have no documents; please click the menu button in the bottom left hand corner to get started")
                                    .foregroundColor(.black)
                                    .invertOnDarkTheme()
                                    .font(.system(size: 20, weight: .semibold))
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                    .padding(.leading)
                                    .padding(.trailing)
                            } else { 
                                LazyVGrid(columns: columns, spacing: 20) {
                                    ForEach(files, id: \.id) { file in
                                        if file.images != nil {
                                            NavigationLink(destination: DocumentEditor(document: file, scanResult: file.scanResult!, images: getImagesfromData(data: file.images!))) {
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
                                                .animation(.easeOut, value: 10)
                                            }
                                        }
                                    }
                                }
                                .padding(.trailing)
                                .padding(.leading)
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
                    .onAppear(perform: initialisation)
                    .invertBackgroundOnDarkTheme(isBase: true)
                    .sheet(isPresented: $showMenu, content: {
                        if #available(iOS 16, *) {
                            Menu(showDocumentCameraView: $showDocumentCameraView, showFileImporter: $showFileImporter, showDictionary: $showDictionary, showMenu: $showMenu)
                                    .environmentObject(userSettings)
                                    .presentationDetents([.fraction(0.30)])
                                    .presentationDragIndicator(.visible)
                        } else {
                            Menu(showDocumentCameraView: $showDocumentCameraView, showFileImporter: $showFileImporter, showDictionary: $showDictionary, showMenu: $showMenu)
                                .environmentObject(userSettings)
                        }
                    })
                    .fileImporter(isPresented: $showFileImporter, allowedContentTypes: [.pdf], onCompletion: { result in
                        do {
                            isLoading = true
                            let url = try result.get()  // Retrieve exact URL on site

                            let images: [UIImage] = convertPDFToImages(url: url) // Use URL to conver the file into an array of photos
                            let result = convertPhotosToParagraphs(scan: images) // Get paragraph information

                            // Create new scanResult which is saved into core data
                            let newDocument = Document(context: moc)
                            newDocument.id = UUID()
                            newDocument.scanResult = ScanResult(scannedTextList: result.0, scannedText: result.1)
                            newDocument.title = "Scan" + getDate()

                            // Save images
                            let imageDataArray = convertImagesToData(images: images)
                            let colatedImageData = try NSKeyedArchiver.archivedData(withRootObject: imageDataArray, requiringSecureCoding: true)
                            newDocument.images = colatedImageData
                            newDocument.textCanvasData = CanvasData(lines: [])
                            
                            try? moc.save()
                            isLoading = false
                        } catch {}
                    })
                    .sheet(isPresented: $showDocumentCameraView, content: {
                        DocumentCameraView()
                    })
                    .sheet(isPresented: $showEditDocumentProperties) {
                        EditDocumentPropertiesTest(document: $currentDocument)
                    }
                    .sheet(isPresented: $showDictionary, content: {
                        DictionaryLookup(wordData: nil)
                            .environmentObject(userSettings)
                    })
            }
        }
            .navigationBarBackButtonHidden(true)
    }
}

struct EditDocumentPropertiesTest: View {
    @Binding var document: Document?
    var body: some View {
        EditDocumentProperties(document: document!, title: document!.title ?? "Unknown")
    }
}

//struct FileExplorer_Previews: PreviewProvider {
//    @available(iOS 16.0, *)
//    static var previews: some View {
//        FileExplorer()
//    }
//}
