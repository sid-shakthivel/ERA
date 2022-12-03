//
//  Help.swift
//  ERA
//
//  Created by Siddharth Shakthivel Muthu Pandian on 03/12/2022.
//

import SwiftUI

struct Help: View {
    @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>
    @EnvironmentObject var userSettings: UserPreferences
    
    let columns: [GridItem] = Array(repeating: GridItem(.flexible()), count: 3)
    
    var body: some View {
        NavigationView {
            VStack {
                HStack {
                    Button {
                        presentationMode.wrappedValue.dismiss()
                    } label: {
                        Image("arrow-left")
                            .resizable()
                            .frame(width: 30, height: 30)
                            .invertOnDarkTheme()

                        Text("Help")
                            .foregroundColor(.black)
                            .invertOnDarkTheme()
                            .font(.system(size: 18, weight: .bold))
                            .textCase(.uppercase)
                    }
                    
                    Spacer()
                }
                .padding(.leading)
                .padding(.trailing)
                
                Divider()
                
                ScrollView {
                    LazyVGrid(columns: columns, spacing: 20) {
                        Group {
                            VStack {
                                Image("menu")
                                    .resizable()
                                    .frame(width: 35, height: 35, alignment: .leading)
                                    .invertOnDarkTheme()
                                
                                Text("Main menu")
                            }
                            
                            VStack {
                                Image("settings")
                                    .resizable()
                                    .frame(width: 35, height: 35, alignment: .leading)
                                    .invertOnDarkTheme()
                                
                                Text("Settings")
                            }
                            
                            VStack {
                                Image("export")
                                    .resizable()
                                    .frame(width: 35, height: 35, alignment: .leading)
                                    .invertOnDarkTheme()
                                
                                Text("Export as PDF")
                            }
                            
                            VStack {
                                Image("edit-text")
                                    .resizable()
                                    .frame(width: 35, height: 35, alignment: .leading)
                                    .invertOnDarkTheme()
                                
                                Text("Edit text")
                            }
                            
                            VStack {
                                Image("save")
                                    .resizable()
                                    .frame(width: 35, height: 35, alignment: .leading)
                                    .invertOnDarkTheme()
                                
                                Text("Save document")
                            }
                            
                            VStack {
                                Image("book")
                                    .resizable()
                                    .frame(width: 35, height: 35, alignment: .leading)
                                    .invertOnDarkTheme()
                                
                                Text("Dictionary")
                            }
                            
                            VStack {
                                Image("close-canvas")
                                    .resizable()
                                    .frame(width: 35, height: 35, alignment: .leading)
                                    .invertOnDarkTheme()
                                
                                Text("Stop editing the drawing")
                            }
                            
                            VStack {
                                Image("rubber")
                                    .resizable()
                                    .frame(width: 35, height: 35, alignment: .leading)
                                    .invertOnDarkTheme()
                                
                                Text("Rubber to rub out drawings")
                            }
                        }
                        
                        VStack {
                            Image("rubber")
                                .resizable()
                                .frame(width: 35, height: 35, alignment: .leading)
                                .invertOnDarkTheme()
                            
                            Text("Rubber to rub out drawings")
                        }
                        
                        VStack {
                            Image("rubber")
                                .resizable()
                                .frame(width: 35, height: 35, alignment: .leading)
                                .invertOnDarkTheme()
                            
                            Text("Rubber to rub out drawings")
                        }
                        
                        VStack {
                            Image("bin")
                                .resizable()
                                .frame(width: 35, height: 35, alignment: .leading)
                                .invertOnDarkTheme()
                            
                            Text("Delete all drawings")
                        }
                        
                        VStack {
                            Image(systemName: "arrow.uturn.backward")
                                .resizable()
                                .frame(width: 35, height: 35, alignment: .leading)
                                .foregroundColor(.black)
                                .invertOnDarkTheme()
                            
                            Text("Undo")
                        }
                        
                        VStack {
                            Image(systemName: "arrow.uturn.forward")
                                .resizable()
                                .frame(width: 35, height: 35, alignment: .leading)
                                .foregroundColor(.black)
                                .invertOnDarkTheme()
                            
                            Text("Redo")
                        }
                        
                        VStack {
                            Image(systemName: "pencil.tip")
                                .resizable()
                                .frame(width: 35, height: 35, alignment: .leading)
                                .foregroundColor(.black)
                                .invertOnDarkTheme()
                            
                            Text("Pen")
                        }
                        
                        VStack {
                            Image(systemName: "highlighter")
                                .resizable()
                                .frame(width: 35, height: 35, alignment: .leading)
                                .foregroundColor(.black)
                                .invertOnDarkTheme()
                            
                            Text("Highlighter")
                        }
                    }
                    .padding()
                }
            }
            .invertBackgroundOnDarkTheme(isBase: true)
        }
            .navigationBarHidden(true)
    }
}

struct Help_Previews: PreviewProvider {
    static var previews: some View {
        Help()
    }
}
