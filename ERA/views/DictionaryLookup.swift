//
//  Lookup.swift
//  ERA
//
//  Created by Siddharth Shakthivel Muthu Pandian on 17/10/2022.
//

import SwiftUI
import AVFoundation

struct Response: Codable {
    var posts: [Word]
}

struct License: Codable, Hashable {
    var name: String
    var url: String
}

struct Definition: Codable, Hashable {
    var definition: String
    var synonyms: [String]
    var antonyms: [String]
    var example: String?
}

struct Phonetic: Codable, Hashable {
    var text: String?
    var audio: String
    var sourceUrl: String?
    var licence: License?
}

struct Meaning: Codable, Hashable {
    var partOfSpeech: String
    var definitions: [Definition]
    var synonyms: [String]
    var antonyms: [String]
}

struct Word: Codable, Hashable {
    var word: String
    var phonetic: String?
    var phonetics: [Phonetic]
    var meanings: [Meaning]
    var license: License
    var sourceUrls: [String]
}

enum Status {
    case Success
    case Failure
    case Fetching
    case Stationary
}

struct DictionaryLookup: View {
    @EnvironmentObject var userSettings: UserCustomisations
    
    @State var wordData: Word?
    @State var state: Status = Status.Fetching
    @State var textInput: String = ""
    
    // If enhanced reading is enabled, apply to each word within the string or return it
    func modifyText(text: String) -> LocalizedStringKey {
        if (userSettings.isEnhancedReading) {
            var markdownStringArray: [String] = []
            
            for substring in text.split(separator: " ") {
                markdownStringArray.append(enhanceText(text: String(substring)))
            }

            return LocalizedStringKey(markdownStringArray.joined(separator: " "))
        }
        
        return LocalizedStringKey(text)
    }
    
    func fetchData() {
        guard let url = URL(string: "https://api.dictionaryapi.dev/api/v2/entries/en/" + textInput) else {
            state = .Failure
            return
        }
        
        URLSession.shared.dataTask(with: url) { (data, _, _) in
            // Fetch the first result - it's a success
            
            if let unwrapped_data = data {
                let tempWordData = try! JSONDecoder().decode([Word].self, from: unwrapped_data)
                
                if tempWordData.isEmpty {
                    state = .Failure
                } else {
                    wordData = tempWordData[0]
                    state = .Success
                }
            } else {
                state = .Failure
                return
            }
        }
        .resume()
    }

    var body: some View {
        Group {
            VStack(alignment: .leading) {
                Text("Dictionary")
                    .foregroundColor(.black)
                    .fontWeight(.bold)
                    .font(.system(size: 24))
                    .padding()
                
                TextField("Enter a word", text: $textInput)
                    .padding(.horizontal)
                    .onSubmit {
                        state = .Fetching
                        fetchData()
                    }
            }
            
            Spacer()
                
            switch state {
            case .Stationary:
                Text("")
            case .Fetching:
                VStack {
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle(tint: Color(hex: 0x0B1F29, alpha: 1)))
                        .scaleEffect(2)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .background(userSettings.backgroundColour)
                .padding()
            case .Failure:
                VStack {
                    Text("Failed to fetch data - check your internet connection")
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            case .Success:
                VStack {
                    Text("\(wordData?.word ?? "Unknown")")
                        .foregroundColor(userSettings.fontColour)
                        .font(Font(userSettings.headingFont))
                        .fontWeight(.bold)
                    
                    Text("\(wordData?.phonetic ?? "Unknown")")
                        .foregroundColor(userSettings.fontColour)
                        .font(Font(userSettings.subheadingFont))
                    
                    TabView {
                        List {
                            ForEach(wordData!.meanings, id: \.self) { meaning in
                                Text("\(meaning.partOfSpeech.capitalized)")
                                    .font(Font(userSettings.subheadingFont))
                                    .fontWeight(.bold)
                                ForEach(meaning.definitions, id: \.self) { definition in
                                    VStack(alignment: .leading) {
                                        Text(modifyText(text: definition.definition))
                                            .font(Font(userSettings.paragraphFont))
                                            .foregroundColor(userSettings.fontColour)
                                        Text(modifyText(text: definition.example ?? "No Exmaple"))
                                            .font(Font(userSettings.subParagaphFont))
                                            .foregroundColor(userSettings.fontColour)
                                    }
                                    .listRowBackground(userSettings.backgroundColour)
                                }
                            }
                        }
                        .scrollContentBackground(.hidden)
                        .background(userSettings.backgroundColour)
                        .tabItem {
                            Label("Defintions", systemImage: "pencil.circle")
                        }
                        
                        List {
                            Text("Synonyms")
                            ForEach(wordData!.meanings, id: \.self) { meaning in
                                ForEach(meaning.synonyms, id: \.self) { synonym in
                                    VStack(alignment: .leading) {
                                        Text(modifyText(text: synonym))
                                            .font(Font(userSettings.paragraphFont))
                                            .foregroundColor(userSettings.fontColour)
                                    }
                                    .listRowBackground(userSettings.backgroundColour)
                                }
                            }
                            
                            Text("Antonyms")
                            ForEach(wordData!.meanings, id: \.self) { meaning in
                                ForEach(meaning.antonyms, id: \.self) { antonym in
                                    VStack(alignment: .leading) {
                                        Text(modifyText(text: antonym))
                                            .font(Font(userSettings.paragraphFont))
                                            .foregroundColor(userSettings.fontColour)
                                    }
                                    .listRowBackground(userSettings.backgroundColour)
                                }
                            }
                        }
                        .scrollContentBackground(.hidden)
                        .background(userSettings.backgroundColour)
                        .tabItem {
                            Label("Synonyms", systemImage: "pencil")
                        }
                    }
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
                .background(userSettings.backgroundColour)
            }
        }
            .background(Color(hex: 0xFFF9F0, alpha: 1))
    }
}

struct Lookup_Previews: PreviewProvider {
    static var previews: some View {
        DictionaryLookup()
    }
}
