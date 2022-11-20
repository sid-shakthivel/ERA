//
//  FileExplorer.swift
//  ERA
//
//  Created by Siddharth Shakthivel Muthu Pandian on 19/11/2022.
//

import SwiftUI

struct DummyData {
    let id: UUID
    var scannedTextList: [RetrievedParagraph] = []
    var scannedText: String = "Hello there"
    
    var scanHeading: RetrievedParagraph = RetrievedParagraph(text: "Welcome to ERA", isHeading: true)
    var scanText: RetrievedParagraph = RetrievedParagraph(text: "Hello there", isHeading: false)
}

struct FileExplorer: View {
    var dummyData: [DummyData] = [
        DummyData(id: UUID()),
        DummyData(id: UUID()),
        DummyData(id: UUID()),
        DummyData(id: UUID())
    ]
    
    let columns: [GridItem] = Array(repeating: GridItem(.flexible()), count: 2)
    
    /*
     Retriving data from core data is done using fetch request (description of how data should be sent, sorted, filters)
     */
    @FetchRequest(sortDescriptors: []) var files: FetchedResults<ScanTest>
    
    var body: some View {
        GeometryReader { geometryProxy in
            VStack {
                HStack {
                    Text("Easy Reading Assistant")
                        .foregroundColor(.black)
                        .fontWeight(.bold)
                        .textCase(.uppercase)
                        .frame(maxWidth: .infinity, alignment: .leading)
                }
                    .padding(.leading)
                
                Divider()
                
                ScrollView {
                    LazyVGrid(columns: columns, spacing: 30) {
                        ForEach(files, id: \.id) { file in
                            Text(file.testStuff?.scannedText ?? "")
                        }
                    }
                    
                    Button(action: {
                        
                    }, label: {
                        
                    })
                }
                
                HStack {
                    Image("menu")
                        .resizable()
                        .frame(width: 25, height: 25)
                }
                .padding(.horizontal)
            }
        }
    }
}

struct FileExplorer_Previews: PreviewProvider {
    static var previews: some View {
        FileExplorer()
    }
}
