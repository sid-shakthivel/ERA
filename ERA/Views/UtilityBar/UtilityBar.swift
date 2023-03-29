//
//  UtilityBar.swift
//  ERA
//
//  Created by Siddharth Shakthivel Muthu Pandian on 29/03/2023.
//

import SwiftUI
import MLKit
import MLKitTranslate

enum UtilityBarStatus {
    case AnnotationBar
    case TranslationBar
    case UtilityBar
}

struct UtilityBar: View {
    @EnvironmentObject var userSettings: UserPreferences
    @EnvironmentObject var canvasSettings: TempCanvas
    
    @Binding var isDrawing: Bool
    @Binding var isEditing: Bool
    @State var showPencilEdit: Bool = false
    
    @State var sourceLangauge: TranslateLanguage = TranslateLanguage(rawValue: "en")
    @State var targetLanguage: TranslateLanguage = TranslateLanguage(rawValue: "fr")
    @State var showDictionary: Bool = false
    
    @Binding var utilityBarStatus: UtilityBarStatus
    @Binding var downloadStatus: DownloadStatus
    @Binding var currentTranslator: Translator
    @Binding var shouldTranslateText: Bool
    
    func updateTranslation() {
        downloadStatus = .Downloading
        
        let options = TranslatorOptions(sourceLanguage: sourceLangauge, targetLanguage: targetLanguage)
        currentTranslator = Translator.translator(options: options)
        
        let conditions = ModelDownloadConditions(
            allowsCellularAccess: false,
            allowsBackgroundDownloading: true
        )
        
        currentTranslator.downloadModelIfNeeded(with: conditions) { error in
            downloadStatus = .Off
            
            guard error == nil
            else {
                downloadStatus = .Failure
                DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                    downloadStatus = .Off
                }
                return }
            
            downloadStatus = .Finished
            DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                downloadStatus = .Off
            }
        }
    }
    
    var body: some View {
        Group {
            switch utilityBarStatus {
            case .AnnotationBar:
                AnnotationBar(isDrawing: $isDrawing, showPencilEdit: $showPencilEdit, utilityBarStatus: $utilityBarStatus)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .environmentObject(userSettings)
                    .environmentObject(canvasSettings)
            case .TranslationBar:
                HStack {
                    HStack {
                        Picker(selection: $sourceLangauge, content: {
                            ForEach(TranslateLanguage.allLanguages().sorted{$0.rawValue < $1.rawValue}, id: \.self) { language in
                                HStack {
                                    Text(Locale.current.localizedString(forLanguageCode: language.rawValue)!)
                                        .font(.system(size: 14))
                                        .fontWeight(.regular)
                                        .foregroundColor(.white)
                                        .invertOnDarkTheme()
                                        .padding()
                                }
                            }
                        }, label: {

                        })
                            .onChange(of: sourceLangauge) { _ in
                                updateTranslation()
                            }
                        
                        Spacer()
                        
                        Image(systemName: "arrow.right")
                            .resizable()
                            .frame(width: 50, height: 30)
                        
                        Spacer()
                        
                        Picker(selection: $targetLanguage, content: {
                            ForEach(TranslateLanguage.allLanguages().sorted{$0.rawValue < $1.rawValue}, id: \.self) { language in
                                HStack {
                                    Text(Locale.current.localizedString(forLanguageCode: language.rawValue)!)
                                        .font(.system(size: 14))
                                        .fontWeight(.regular)
                                        .foregroundColor(.white)
                                        .invertOnDarkTheme()
                                        .padding()
                                }
                            }
                        }, label: {

                        })
                            .onChange(of: targetLanguage) { _ in
                                updateTranslation()
                            }
                        
                        Spacer()
                    }
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .invertBackgroundOnDarkTheme(isBase: false)
                        .cornerRadius(10)
                        .overlay(
                            RoundedRectangle(cornerRadius: 10)
                                .stroke(Color(hex: userSettings.isDarkMode ? 0xAB9D96 : 0xF2EDE4, alpha: 1), lineWidth: 1)
                        )
                        .padding(.leading)
                        .padding(.trailing)
                    
                    Spacer()
                    
                    Button(action: {
                        utilityBarStatus = .UtilityBar
                    }, label: {
                        Image("stop-editing")
                            .resizable()
                            .frame(width: 30, height: 30)
                            .invertOnDarkTheme()
                    })
                    
                    Spacer()
                }
                
                Picker("", selection: $shouldTranslateText) {
                    Text("Original")
                        .tag(false)
                        .foregroundColor(.black)
                        .invertOnDarkTheme()
                    
                    Text("Translation")
                        .tag(true)
                        .foregroundColor(.black)
                        .invertOnDarkTheme()
                }
                    .pickerStyle(.segmented)
                    .padding(.leading)
                    .padding(.trailing)
            case .UtilityBar:
                HStack {
                    Spacer()
                    
                    Button(action: {
                        showDictionary.toggle()
                    }, label: {
                        Image("dictionary")
                            .resizable()
                            .frame(width: 25, height: 25)
                            .invertOnDarkTheme()
                    })
                    
                    Spacer()
                    
                    Button(action: {
                        // Open annotation bar
                        utilityBarStatus = .AnnotationBar
                        isEditing = false
                    }, label: {
                        Image(systemName: "scribble")
                            .resizable()
                            .frame(width: 25, height: 25)
                            .foregroundColor(.black)
                            .invertOnDarkTheme()
                    })
                    
                    Spacer()
                    
                    Button(action: {
                        // Open translation bar
                        utilityBarStatus = .TranslationBar
                    }, label: {
                        Image("translate")
                            .resizable()
                            .frame(width: 25, height: 25)
                            .invertOnDarkTheme()
                    })
                    
                    Spacer()
                }
                .padding(.top)
                .invertBackgroundOnDarkTheme(isBase: false)
            }
        }
            .sheet(isPresented: $showDictionary, content: {
                DictionaryLookup(wordData: nil)
                    .environmentObject(userSettings)
            })
            .sheet(isPresented: $showPencilEdit, content: {
                // Provide settings for photo canvas
                let name = canvasSettings.isUsingHighlighter == true ? "Highlighter": "Pencil";
                
                if #available(iOS 16, *) {
                    EditPencil(drawingToolName: name)
                        .environmentObject(canvasSettings)
                        .environmentObject(userSettings)
                        .presentationDetents([.fraction(0.30)])
                        .presentationDragIndicator(.visible)
                } else {
                    EditPencil(drawingToolName: name)
                        .environmentObject(canvasSettings)
                        .environmentObject(userSettings)
                }
            })
    }
}
