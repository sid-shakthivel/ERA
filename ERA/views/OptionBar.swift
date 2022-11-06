//
//  OptionBar.swift
//  ERA
//
//  Created by Siddharth Shakthivel Muthu Pandian on 27/10/2022.
//

import SwiftUI

extension View {
    func `if`<Content: View>(_ conditional: Bool, content: (Self) -> Content) -> TupleView<(Self?, Content?)> {
        if conditional {
            return TupleView((nil, content(self)))
        } else {
            return TupleView((self, nil))
        }
    }
}

struct OptionBar: View {
    @EnvironmentObject var canvasSettings: CanvasSettings
    @Binding var showDictionary: Bool
    @Binding var showMenu: Bool
    @Binding var isDrawing: Bool
    @Binding var isEditing: Bool
    @Binding var showPencilEdit: Bool
    
    var body: some View {
        HStack {
            Spacer()
            
            Button(action: {
                showMenu.toggle()
            }, label: {
                Image("menu")
                    .resizable()
                    .frame(width: 30, height: 30)
            })
            
            Spacer()
            
            Group {
                Group {
                    Button(action: {
                        isDrawing = true
                        canvasSettings.isRubbing = false
                    }, label: {
                        Image(systemName: "circle.fill")
                            .font(.title)
                            .foregroundColor(canvasSettings.selectedColour)
                    })

                    if isDrawing {
                        Button(action: {
                            showPencilEdit = true;
                            canvasSettings.isRubbing = false
                        }, label: {
                            Image(systemName: "circle.fill")
                                .font(.title)
                                .foregroundColor(canvasSettings.selectedColour)
                                .mask {
                                    Image(systemName: "scribble")
                                        .font(.largeTitle)
                                }
                        })
                    }
                }

                Button(action: {
                    isDrawing = false
                    isEditing = false
                }, label: {
                    Image("tick")
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
        OptionBar(showDictionary: .constant(false), showMenu: .constant(false), isDrawing: .constant(false), isEditing: .constant(false), showPencilEdit: .constant(false))
    }
}
