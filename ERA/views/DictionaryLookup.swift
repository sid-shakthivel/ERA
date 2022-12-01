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

enum ErrorMessages {
    case NoInternet
    case UnknownWord
    case Nothing
}

struct DictionaryLookup: View {
    @EnvironmentObject var userSettings: UserPreferences
    
    @State var wordData: Word?
    @State var state: Status = Status.Fetching
    @State var errorMessage: ErrorMessages = ErrorMessages.Nothing
    @State var textInput: String = ""
    
    func fetchData() {
        textInput = cleanString(of: textInput)
        
        guard let url = URL(string: "https://api.dictionaryapi.dev/api/v2/entries/en/" + textInput) else {
            state = .Failure
            return
        }
        
        let session = URLSession.shared
        
        let task = session.dataTask(with: url) { data, response, error in
            guard let data = data, error == nil else {
                errorMessage = .NoInternet
                state = .Failure
                return
            }

            do {
                let tempWordData = try JSONDecoder().decode([Word].self, from: data)
                
                if tempWordData.isEmpty {
                    errorMessage = .UnknownWord
                    state = .Failure
                    return
                } else {
                    wordData = tempWordData[0]
                    state = .Success
                    return
                }
            } catch DecodingError.typeMismatch {
                errorMessage = .UnknownWord
                state = .Failure
                return
            } catch {
                errorMessage = .UnknownWord
                state = .Failure
                return
            }
       }

       task.resume()
    }

    // Strips string of whitespace and special characters
    func cleanString(of text: String) -> String {
        var modifiedText = text.trimmingCharacters(in: .whitespacesAndNewlines)
        modifiedText = modifiedText.withoutSpecialCharacters
        let removeCharacters: Set<Character> = [".", ":", ","]
        modifiedText.removeAll(where: { removeCharacters.contains($0) } )
        return modifiedText
    }
    
    var body: some View {
        VStack {
            VStack(alignment: .leading) {
                Text("Dictionary")
                    .foregroundColor(.black)
                    .invertOnDarkTheme()
                    .font(.system(size: 24, weight: .bold))
                    .padding()
                
                TextField("", text: $textInput)
                    .foregroundColor(.black)
                    .invertOnDarkTheme()
                    .placeholder(when: textInput.isEmpty) {
                        Text("Enter a word")
                            .foregroundColor(.black)
                            .invertOnDarkTheme()
                    }
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
                    if userSettings.isDarkMode {
                        ProgressView()
                            .scaleEffect(2)
                            .progressViewStyle(CircularProgressViewStyle(tint: Color(hex: 0xf4e0d6, alpha: 1)))
                    } else {
                        ProgressView()
                            .scaleEffect(2)
                            .progressViewStyle(CircularProgressViewStyle(tint: Color(hex: 0x0B1F29, alpha: 1)))
                    }
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .invertBackgroundOnDarkTheme(isBase: true)
                .padding()
            case .Failure:
                VStack {
                    switch errorMessage {
                    case .NoInternet:
                        Text("Dictionary requires internet")
                            .foregroundColor(.black)
                            .invertOnDarkTheme()
                            .font(Font(userSettings.headingFont))
//                            .fontWeight(.bold)
                    case .UnknownWord, .Nothing:
                        Text("Word not found!?")
                            .foregroundColor(.black)
                            .invertOnDarkTheme()
                            .font(Font(userSettings.headingFont))
//                            .fontWeight(.bold)
                    }
                }
                .invertBackgroundOnDarkTheme(isBase: true)
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            case .Success:
                VStack {
                    Text("\(wordData?.word ?? "Unknown")")
                        .foregroundColor(.black)
                        .invertOnDarkTheme()
                        .font(Font(userSettings.headingFont))
//                        .fontWeight(.bold)
                    
                    Text("\(wordData?.phonetic ?? "Unknown")")
                        .foregroundColor(.black)
                        .invertOnDarkTheme()
                        .font(Font(userSettings.subheadingFont))
                    
                    TabView {
                        List {
                            ForEach(wordData!.meanings, id: \.self) { meaning in
                                Text("\(meaning.partOfSpeech.capitalized)")
                                    .font(Font(userSettings.subheadingFont))
                                    .fontWeight(.bold)
                                ForEach(meaning.definitions, id: \.self) { definition in
                                    VStack(alignment: .leading) {
                                        Text(modifyText(condition: userSettings.isEnhancedReading, text: definition.definition))
                                            .font(Font(userSettings.paragraphFont))
                                            .foregroundColor(.black)
                                            .invertOnDarkTheme()
                                        Text(modifyText(condition: userSettings.isEnhancedReading, text: definition.example ?? "No Example"))
                                            .font(Font(userSettings.subParagaphFont))
                                            .foregroundColor(.black)
                                            .invertOnDarkTheme()
                                    }
                                    .invertBackgroundOnDarkTheme(isBase: true)
                                }
                            }
                        }
//                            .scrollContentBackground(.hidden)
                            .invertBackgroundOnDarkTheme(isBase: true)
                            .tabItem {
                                Label("Defintions", systemImage: "pencil.circle")
                            }
                        
                        List {
                            Text("Synonyms")
                            ForEach(wordData!.meanings, id: \.self) { meaning in
                                ForEach(meaning.synonyms, id: \.self) { synonym in
                                    VStack(alignment: .leading) {
                                        Text(modifyText(condition: userSettings.isEnhancedReading, text: synonym))
                                            .font(Font(userSettings.paragraphFont))
                                            .foregroundColor(.black)
                                            .invertOnDarkTheme()
                                    }
                                    .invertBackgroundOnDarkTheme(isBase: true)
                                }
                            }
                            
                            Text("Antonyms")
                            ForEach(wordData!.meanings, id: \.self) { meaning in
                                ForEach(meaning.antonyms, id: \.self) { antonym in
                                    VStack(alignment: .leading) {
                                        Text(modifyText(condition: userSettings.isEnhancedReading, text: antonym))
                                            .font(Font(userSettings.paragraphFont))
                                            .foregroundColor(.black)
                                            .invertOnDarkTheme()
                                    }
                                    .invertBackgroundOnDarkTheme(isBase: true)
                                }
                            }
                        }
//                            .scrollContentBackground(.hidden)
                            .listRowBackground(userSettings.backgroundColour)
                            .invertBackgroundOnDarkTheme(isBase: true)
                            .tabItem {
                                Label("Synonyms", systemImage: "pencil")
                            }
                    }
                }
                    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
                    .invertBackgroundOnDarkTheme(isBase: true)
            }
        }
        .invertBackgroundOnDarkTheme(isBase: true)
    }
}

struct Lookup_Previews: PreviewProvider {
    static var previews: some View {
        DictionaryLookup()
    }
}
