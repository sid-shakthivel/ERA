//
//  OptionBar.swift
//  ERA
//
//  Created by Siddharth Shakthivel Muthu Pandian on 27/10/2022.
//

import SwiftUI
import SwiftUITooltip

struct OptionBar: View {
    @EnvironmentObject var canvasSettings: CanvasSettings
    @EnvironmentObject var settings: UserPreferences
    
    @Binding var showDictionary: Bool
    @Binding var isDrawing: Bool
    @Binding var isEditing: Bool
    @Binding var showPencilEdit: Bool
    @Binding var isShowingHelp: Bool
    
    @State var isShowingHighlighter: Bool = false
    @State var isShowingPencil: Bool = false
    
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
            .if(isShowingHelp) { view in
                view
                    .tooltip(.top, config: tooltipConfig) {
                        Text("Dictionary")
                            .font(Font(settings.subParagaphFont))
                    }
                }
            
            Spacer()
            
            Group {
                HStack {
                    ZStack {
                        if isDrawing && canvasSettings.lineCap == .round {
                            Capsule()
                                .fill(Color(UIColor(canvasSettings.selectedColour).inverted))
                                .frame(width: 80, height: 30)
                        }
                        
                        HStack {
                            Button(action: {
                                isDrawing = true
                                isShowingPencil = true
                                isShowingHighlighter = false
                                canvasSettings.lineCap = .round
                                canvasSettings.isRubbing = false
                            }, label: {
                                Image(systemName: "pencil.tip")
                                    .font(.title)
                                    .foregroundColor(canvasSettings.selectedColour)
                            })
                            .if(isDrawing && canvasSettings.lineCap == .round, transform: { view in
                                view
                                    .background(Color(UIColor(canvasSettings.selectedColour).inverted))
                                    .clipShape(Circle())
                            })

                            if isShowingPencil {
                                Button(action: {
                                    showPencilEdit = true
                                    isShowingPencil = false
                                    canvasSettings.isRubbing = false
                                }, label: {
                                    Image("edit-pencil")
                                        .resizable()
                                        .frame(width: 35, height: 30)
                                        .invertOnDarkTheme()
                                })
                            }
                        }
                    }
                    
                    ZStack {
                        if isDrawing && canvasSettings.lineCap == .butt {
                            Capsule()
                                .fill(Color(UIColor(canvasSettings.selectedHighlighterColour).inverted))
                                .frame(width: 80, height: 30)
                        }
                        
                        HStack {
                            Button(action: {
                                isDrawing = true
                                isShowingHighlighter = true
                                isShowingPencil = false
                                canvasSettings.lineCap = .butt
                                canvasSettings.isRubbing = false
                            }, label: {
                                Image(systemName: "highlighter")
                                    .font(.title)
                                    .foregroundColor(canvasSettings.selectedHighlighterColour)
                            })

                            if isShowingHighlighter {
                                Button(action: {
                                    showPencilEdit = true;
                                    canvasSettings.isRubbing = false
                                    isDrawing = false
                                }, label: {
                                    Image("edit-pencil")
                                        .resizable()
                                        .frame(width: 35, height: 30)
                                        .invertOnDarkTheme()
                                })
                            }
                        }
                    }
                }

                Button(action: {
                    isDrawing = false
                    isEditing = false
                    isShowingHighlighter = false
                    isShowingPencil = false
                }, label: {
                    Image("close-canvas")
                        .resizable()
                        .frame(width: 30, height: 30)
                        .invertOnDarkTheme()
                })
                    .if(isShowingHelp) { view in
                        view
                            .tooltip(.top, config: tooltipConfig) {
                                Text("Close canvas")
                                    .font(Font(settings.subParagaphFont))
                            }
                    }
                
                Button(action: {
                    isDrawing = true
                    isEditing = false
                    canvasSettings.isRubbing = true
                    isShowingHighlighter = false
                    isShowingPencil = false
                    canvasSettings.lineCap = .square
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
                       // On single tap clear the canvas
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
            
//            if !isShowingHighlighter || !isShowingPencil {
//                Spacer()
//
//                Button(action: {
//                    isShowingHelp.toggle()
//                }, label: {
//                    Image("info")
//                        .resizable()
//                        .frame(width: 30, height: 30)
//                        .invertOnDarkTheme()
//                })
//            }
            
            Spacer()
        }
        .invertBackgroundOnDarkTheme(isBase: false)
        .onAppear(perform: setup_tooltips)
        .padding(.top)
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
