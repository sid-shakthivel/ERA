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
    @EnvironmentObject var settings: UserCustomisations
    
    @Binding var showDictionary: Bool
    @Binding var showMenu: Bool
    @Binding var isDrawing: Bool
    @Binding var isEditing: Bool
    @Binding var showPencilEdit: Bool
    @Binding var isShowingHelp: Bool
    
    @State var isShowingHighlighter: Bool = false
    @State var isShowingPencil: Bool = false
    
    var body: some View {
        HStack {
            Spacer()
            
            Button(action: {
                showMenu.toggle()
            }, label: {
                Image("hamburger")
                    .resizable()
                    .frame(width: 25, height: 25)
            })
            .if(isShowingHelp) { view in
                view
                    .tooltip(.top) {
                        Text("Menu")
                            .font(Font(settings.subParagaphFont))
                    }
                }
            
            Spacer()
            
            Group {
                HStack {
                    ZStack {
                        if isDrawing && canvasSettings.lineCap == .round {
                            Capsule()
                                .fill(.red)
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
                                    .background(Color.red)
                                    .clipShape(Circle())
                            })

                            if isShowingPencil {
                                Button(action: {
                                    showPencilEdit = true
                                    isShowingPencil = false
                                    canvasSettings.isRubbing = false
                                }, label: {
                                    Image("edit-attributes")
                                        .resizable()
                                        .frame(width: 25, height: 25)
                                })
                            }
                        }
                    }
                    
                    ZStack {
                        if isDrawing && canvasSettings.lineCap == .butt {
                            Capsule()
                                .fill(.yellow)
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
                                    Image("edit-attributes")
                                        .resizable()
                                        .frame(width: 25, height: 25)
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
                    Image("tick")
                        .resizable()
                        .frame(width: 30, height: 30)
                })
                    .if(isShowingHelp) { view in
                        view
                            .tooltip(.top) {
                                Text("Close canvas")
                                    .font(Font(settings.subParagaphFont))
                            }
                    }
                
                Button(action: {
                    isDrawing = false
                }, label: {
                    Image("rubber")
                        .resizable()
                        .frame(width: 30, height: 30)
                })
            }

            Spacer()

            Group {
                Button(action: {
                    canvasSettings.lines = []
                }, label: {
                    Image("bin")
                        .resizable()
                        .frame(width: 30, height: 30)
                })

                Button(action: {
                    if canvasSettings.lines.count >= 1 {
                        canvasSettings.lastLine = canvasSettings.lines.removeLast()
                    }
                }, label: {
                    Image(systemName: "arrow.uturn.backward")
                        .font(.title)
                        .foregroundColor(Color(hex: 0xC24E1C))
                })


                Button(action: {
                    if canvasSettings.lastLine != nil {
                        canvasSettings.lines.append(canvasSettings.lastLine!)
                        canvasSettings.lastLine = nil
                    }
                }, label: {
                    Image(systemName: "arrow.uturn.forward")
                        .font(.title)
                        .foregroundColor(Color(hex: 0xC24E1C))
                })
            }

            Spacer()
        }
        .padding(.top)
    }
}

struct OptionBar_Previews: PreviewProvider {
    static var previews: some View {
        OptionBar(showDictionary: .constant(false), showMenu: .constant(false), isDrawing: .constant(false), isEditing: .constant(false), showPencilEdit: .constant(false), isShowingHelp: .constant(false))
    }
}
