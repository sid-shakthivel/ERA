//
//  OptionBar.swift
//  ERA
//
//  Created by Siddharth Shakthivel Muthu Pandian on 27/10/2022.
//

import SwiftUI
import SwiftUITooltip

struct OptionBar: View {
    @EnvironmentObject var canvasSettings: TempCanvas
    @EnvironmentObject var settings: UserPreferences
    
    @Binding var showDictionary: Bool
    @Binding var isDrawing: Bool
    @Binding var isEditing: Bool
    @Binding var showPencilEdit: Bool
    @Binding var isShowingHelp: Bool
    
    @State var isUsingHighlighter: Bool = false
    @State var isUsingPencil: Bool = false
    
    @State var tooltipConfig = DefaultTooltipConfig()
    
    func setup_tooltips() {
        tooltipConfig.enableAnimation = true
        tooltipConfig.animationOffset = 10
        tooltipConfig.animationTime = 1
    }
    
    var body: some View {
        HStack {
            Spacer()
            
            Button(action: {
                showDictionary.toggle()
            }, label: {
                Image("book")
                    .resizable()
                    .frame(width: 25, height: 25)
                    .invertOnDarkTheme()
            })

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
                    isEditing = false
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
                    isEditing = false
                    canvasSettings.isRubbing = true
                    isUsingHighlighter = false
                    isUsingPencil = false
                }, label: {
                    Image("rubber")
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
            }
            
            Spacer()
        }
        .padding(.top)
        .invertBackgroundOnDarkTheme(isBase: false)
        .onAppear(perform: setup_tooltips)
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

//struct OptionBar_Previews: PreviewProvider {
//    static var previews: some View {
//        OptionBar(showDictionary: .constant(false), isDrawing: .constant(false), isEditing: .constant(false), showPencilEdit: .constant(false), isShowingHelp: .constant(false))
//    }
//}
