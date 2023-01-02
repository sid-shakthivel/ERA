//
//  HelpWidgets.swift
//  ERA
//
//  Created by Siddharth Shakthivel Muthu Pandian on 02/01/2023.
//

import SwiftUI

struct HelpWidgets: View {
    var body: some View {
        let columns: [GridItem] = Array(repeating: GridItem(.flexible()), count: 3)
        
        ScrollView {
            Group {
                HStack {
                    VStack {
                        Image("menu")
                            .resizable()
                            .frame(width: 35, height: 35, alignment: .leading)
                            .foregroundColor(.black)
                            .invertOnDarkTheme()
                        
                        Text("Menu")
                            .foregroundColor(.black)
                            .invertOnDarkTheme()
                    }
                    
                    Spacer()

                    Image(systemName: "arrow.forward")
                        .resizable()
                        .frame(width: 35, height: 35, alignment: .leading)
                        .foregroundColor(.black)
                        .invertOnDarkTheme()
                    
                    Spacer()
                    
                    VStack {
                        Text("Scan Document")
                            .foregroundColor(.black)
                            .invertOnDarkTheme()
                        
                        Text("Upload Document")
                            .foregroundColor(.black)
                            .invertOnDarkTheme()
                        
                        Text("Open Dictionary")
                            .foregroundColor(.black)
                            .invertOnDarkTheme()
                    }
                }
                    .padding()
                    .frame(maxWidth: .infinity, alignment: .leading)
            }
                .padding()
            
            LazyVGrid(columns: columns, spacing: 20) {
                Group {
                    VStack {
                        Image("settings")
                            .resizable()
                            .frame(width: 35, height: 35, alignment: .leading)
                            .invertOnDarkTheme()

                        Text("Settings")
                            .foregroundColor(.black)
                            .invertOnDarkTheme()
                    }

                    VStack {
                        Image("export")
                            .resizable()
                            .frame(width: 35, height: 35, alignment: .leading)
                            .invertOnDarkTheme()

                        Text("Export as PDF")
                            .foregroundColor(.black)
                            .invertOnDarkTheme()
                    }

                    VStack {
                        Image("edit-text")
                            .resizable()
                            .frame(width: 35, height: 35, alignment: .leading)
                            .invertOnDarkTheme()

                        Text("Edit text")
                            .foregroundColor(.black)
                            .invertOnDarkTheme()
                    }

                    VStack {
                        Image("save")
                            .resizable()
                            .frame(width: 35, height: 35, alignment: .leading)
                            .invertOnDarkTheme()

                        Text("Save")
                            .multilineTextAlignment(.center)
                            .foregroundColor(.black)
                            .invertOnDarkTheme()
                    }

                    VStack {
                        Image("dictionary")
                            .resizable()
                            .frame(width: 35, height: 35, alignment: .leading)
                            .invertOnDarkTheme()

                        Text("Dictionary")
                            .foregroundColor(.black)
                            .invertOnDarkTheme()
                    }

                    VStack {
                        Image("close-canvas")
                            .resizable()
                            .frame(width: 35, height: 35, alignment: .leading)
                            .invertOnDarkTheme()

                        Text("Stop editing the drawing")
                            .foregroundColor(.black)
                            .invertOnDarkTheme()
                    }

                    VStack {
                        Image("eraser")
                            .resizable()
                            .frame(width: 35, height: 35, alignment: .leading)
                            .invertOnDarkTheme()

                        Text("Eraser")
                            .foregroundColor(.black)
                            .invertOnDarkTheme()
                    }
                }

                VStack {
                    Image("play")
                        .resizable()
                        .frame(width: 35, height: 35, alignment: .leading)
                        .invertOnDarkTheme()

                    Text("Start text to speech")
                        .foregroundColor(.black)
                        .invertOnDarkTheme()
                }

                VStack {
                    Image("pause")
                        .resizable()
                        .frame(width: 35, height: 35, alignment: .leading)
                        .invertOnDarkTheme()

                    Text("Pause text to speech")
                        .foregroundColor(.black)
                        .invertOnDarkTheme()
                }

                VStack {
                    Image("bin")
                        .resizable()
                        .frame(width: 35, height: 35, alignment: .leading)
                        .invertOnDarkTheme()

                    Text("Delete all drawings")
                        .foregroundColor(.black)
                        .invertOnDarkTheme()
                }

                VStack {
                    Image(systemName: "arrow.uturn.backward")
                        .resizable()
                        .frame(width: 35, height: 35, alignment: .leading)
                        .foregroundColor(.black)
                        .invertOnDarkTheme()

                    Text("Undo")
                        .foregroundColor(.black)
                        .invertOnDarkTheme()
                }

                VStack {
                    Image(systemName: "arrow.uturn.forward")
                        .resizable()
                        .frame(width: 35, height: 35, alignment: .leading)
                        .foregroundColor(.black)
                        .invertOnDarkTheme()

                    Text("Redo")
                        .foregroundColor(.black)
                        .invertOnDarkTheme()
                }

                VStack {
                    Image(systemName: "pencil.tip")
                        .resizable()
                        .frame(width: 35, height: 35, alignment: .leading)
                        .foregroundColor(.black)
                        .invertOnDarkTheme()

                    Text("Pen")
                        .foregroundColor(.black)
                        .invertOnDarkTheme()
                }

                VStack {
                    Image(systemName: "highlighter")
                        .resizable()
                        .frame(width: 35, height: 35, alignment: .leading)
                        .foregroundColor(.black)
                        .invertOnDarkTheme()

                    Text("Highlighter")
                        .foregroundColor(.black)
                        .invertOnDarkTheme()
                }
            }
                .padding(.trailing)
        }
            .invertBackgroundOnDarkTheme(isBase: true)
    }
}

struct HelpWidgets_Previews: PreviewProvider {
    static var previews: some View {
        HelpWidgets()
    }
}
