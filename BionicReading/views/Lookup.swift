//
//  Lookup.swift
//  BionicReading
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
    var text: String
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
    var phonetic: String
    var phonetics: [Phonetic]
    var meanings: [Meaning]
    var license: License
    var sourceUrls: [String]
}

enum Status {
    case Success
    case Failure
    case Fetching
}

struct Lookup: View {
    @EnvironmentObject var userSettings: UserCustomisations
    
    @State var word: String
    @State var wordData: Word?
    @State var state: Status = Status.Fetching
    
    @State var isPlaying: Bool = false
    
    @State var player: AVAudioPlayer!
    
    func playAudio() {
        if player != nil {
            player.stop()
        }
        player = nil
    }
    
    func pauseAudio() {
        let url = Bundle.main.url(forResource: "https://api.dictionaryapi.dev/media/pronunciations/en/copy-us", withExtension: "mp3")
        player = try! AVAudioPlayer(contentsOf: url!)
        player.play()
    }
    
    func fetchData() {
        guard let url = URL(string: "https://api.dictionaryapi.dev/api/v2/entries/en/" + word) else {
            print("Api not found")
            state = .Failure
            return
        }
        
        URLSession.shared.dataTask(with: url) { (data, _, _) in
            // Fetch the first result - it's a success
            let tempWordData = try! JSONDecoder().decode([Word].self, from: data!)
            print(tempWordData)
            if tempWordData.isEmpty {
                state = .Failure
            } else {
                wordData = tempWordData[0]
                state = .Success
            }
        }
        .resume()
    }

    var body: some View {
        Group {
            switch state {
            case .Fetching:
                Text("Fetching Data")
            case .Failure:
                Text("Failed to fetch data - check your internet connection")
            case .Success:
                VStack {
                    Text("\(wordData?.word ?? "Unknown")")
                        .foregroundColor(userSettings.fontColour)
                        .font(Font(userSettings.headingFont))
                    
                    Text("\(wordData?.phonetic ?? "Unknown")")
                        .foregroundColor(userSettings.fontColour)
                        .font(Font(userSettings.headingFont))
                    
//                    if isPlaying {
//                        Button(action: {
//                            isPlaying.toggle()
//                            pauseAudio()
//                        }, label: {
//                            Image(systemName: "pause.fill")
//                        })
//                            .padding()
//                            .foregroundColor(Color(hex: 0xDF4D0F, alpha: 1))
//                            .font(.system(size: 24))
//                    } else {
//                        Button(action: {
//                            isPlaying.toggle()
//                            playAudio()
//                        }, label: {
//                            Image(systemName: "play.fill")
//                        })
//                            .padding()
//                            .foregroundColor(Color(hex: 0xDF4D0F, alpha: 1))
//                            .font(.system(size: 24))
//                    }
                    
                    List {
                        ForEach(wordData!.meanings, id: \.self) { meaning in
                            ForEach(meaning.definitions, id: \.self) { definition in
                                VStack(alignment: .leading) {
                                    Text("\(definition.definition)")
                                    Text("\(definition.example ?? "No Example")")
                                        .font(.subheadline)
                                }
                                .listRowBackground(userSettings.backgroundColour)
                            }
                        }
                    }
                    .scrollContentBackground(.hidden)
                    .background(userSettings.backgroundColour)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
                .background(userSettings.backgroundColour)
                .padding()
            }
        }
        .onAppear() {
            fetchData()
        }
    }
}

struct Lookup_Previews: PreviewProvider {
    static var previews: some View {
        Lookup(word: "go")
    }
}
