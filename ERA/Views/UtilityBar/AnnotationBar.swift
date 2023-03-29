//
//  OptionBar.swift
//  ERA
//
//  Created by Siddharth Shakthivel Muthu Pandian on 27/10/2022.
//

import SwiftUI

struct AnnotationBar: View {
    @EnvironmentObject var canvasSettings: TempCanvas
    @EnvironmentObject var settings: UserPreferences
    
    @Binding var isDrawing: Bool
    @Binding var showPencilEdit: Bool
    @Binding var utilityBarStatus: UtilityBarStatus
    
    @State var isUsingHighlighter: Bool = false
    @State var isUsingPencil: Bool = false
    
    var body: some View {
        HStack {
            Spacer()
            
            Group {
                Button(action: {
                    isDrawing = true
                    isUsingPencil = true
                    isUsingHighlighter = false
                    canvasSettings.isUsingHighlighter = false;
                    canvasSettings.isRubbing = false
                }, label: {
                    Image(systemName: "pencil.tip")
                        .font(.title)
                })
                
                if isUsingPencil {
                    Button(action: {
                        showPencilEdit = true
                    }, label: {
                        ZStack {
                            Circle()
                                .fill(Color(hex: 0xe7b8a4))
                                .invertOnDarkTheme()
                                .frame(width: 35, height: 30)
                            
                            Circle()
                                .fill(canvasSettings.selectedColour)
                                .frame(width: 25, height: 20)
                        }
                    })
                        .transition(.slide)
                }
                
                Button(action: {
                    isDrawing = true
                    isUsingHighlighter = true
                    isUsingPencil = false
                    canvasSettings.isUsingHighlighter = true;
                    canvasSettings.isRubbing = false
                }, label: {
                    Image(systemName: "highlighter")
                        .font(.title)
                })
                
                if isUsingHighlighter {
                    Button(action: {
                        showPencilEdit = true
                    }, label: {
                        ZStack {
                            Circle()
                                .fill(Color(hex: 0xe7b8a4))
                                .invertOnDarkTheme()
                                .frame(width: 35, height: 30)
                            
                            Circle()
                                .fill(canvasSettings.selectedHighlighterColour)
                                .frame(width: 25, height: 20)
                        }
                    })
                        .transition(.slide)
                }
                
                Button(action: {
                    isDrawing = false
                    isUsingHighlighter = false
                    isUsingPencil = false
                }, label: {
                    Image("close-canvas")
                        .resizable()
                        .frame(width: 30, height: 30)
                        .invertOnDarkTheme()
                })
                
                Button(action: {
                    isDrawing = true
                    canvasSettings.isRubbing = true
                    isUsingHighlighter = false
                    isUsingPencil = false
                }, label: {
                    Image("eraser")
                        .resizable()
                        .frame(width: 30, height: 30)
                        .invertOnDarkTheme()
                })
            }
            
            Spacer()

            Group {                
                Image("bin")
                    .resizable()
                    .frame(width: 30, height: 30)
                    .invertOnDarkTheme()
                    .onTapGesture(count: 1) {
                        canvasSettings.lineBuffer = []
                    }

                Button(action: {
                    if canvasSettings.lineBuffer.count >= 1 {
                        canvasSettings.lastLine = canvasSettings.lineBuffer.removeLast()
                    }
                }, label: {
                    Image(systemName: "arrow.uturn.backward")
                        .font(.title)
                        .foregroundColor(Color(hex: 0xC24E1C))
                        .invertOnDarkTheme()
                })

                Button(action: {
                    if canvasSettings.lastLine != nil {
                        canvasSettings.lineBuffer.append(canvasSettings.lastLine!)
                        canvasSettings.lastLine = nil
                    }
                }, label: {
                    Image(systemName: "arrow.uturn.forward")
                        .font(.title)
                        .foregroundColor(Color(hex: 0xC24E1C))
                        .invertOnDarkTheme()
                })
                
                
                Button(action: {
                    utilityBarStatus = .UtilityBar
                    isDrawing = false
                    
                }, label: {
                    Image("stop-editing")
                        .resizable()
                        .frame(width: 30, height: 30)
                        .invertOnDarkTheme()
                })
            }
            
            Spacer()
        }
        .padding(.top)
        .invertBackgroundOnDarkTheme(isBase: false)
        .onAppear() {
            if settings.isDarkMode && canvasSettings.selectedColour == .black {
                canvasSettings.selectedColour = .white
                canvasSettings.selectedHighlighterColour = .white
            } else if !settings.isDarkMode && canvasSettings.selectedColour == .white {
                canvasSettings.selectedColour = .black
                canvasSettings.selectedHighlighterColour = .black
            }
        }
    }
}
