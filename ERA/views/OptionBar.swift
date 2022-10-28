//
//  OptionBar.swift
//  ERA
//
//  Created by Siddharth Shakthivel Muthu Pandian on 27/10/2022.
//

import SwiftUI

struct OptionBar: View {
    @EnvironmentObject var canvasSettings: CanvasSettings
    @Binding var showDictionary: Bool
    @Binding var showMenu: Bool
    @Binding var isDrawing: Bool
    
    var body: some View {
        VStack {
            HStack {
                Image("menu")
                    .onTapGesture(count: 2) {
                        showDictionary.toggle()
                    }
                    .onTapGesture(count: 1) {
                        showMenu.toggle()
                    }
                
                ForEach([Color.blue, Color.red, Color.black], id: \.self) { colour in
                    colourButton(colour: colour)
                }
                
                Button(action: {
                    isDrawing = false
                    canvasSettings.selectedColour = .clear
                }, label: {
                    Image("tick")
                        .font(.largeTitle)
                })
                
                Button(action: {
                    canvasSettings.lines = []
                }, label: {
                    Image("bin")
                        .font(.largeTitle)
                        .foregroundColor(.gray)
                })
                
                Button(action: {
                    if canvasSettings.lines.count > 1 {
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
            .padding()

            Slider(value: $canvasSettings.lineWidth, in: 0...20)
                .padding(.bottom)
                .padding(.leading)
                .padding(.trailing)
        }
    }
    
    @ViewBuilder
    func colourButton(colour: Color) -> some View {
        Button(action: {
            isDrawing = true
            canvasSettings.selectedColour = colour
        }, label: {
            Image(systemName: "circle.fill")
                .font(.title)
                .foregroundColor(colour)
                .mask {
                    Image(systemName: "pencil.tip")
                        .font(.largeTitle)
                }
        })
    }
}

struct OptionBar_Previews: PreviewProvider {
    static var previews: some View {
        OptionBar(showDictionary: .constant(false), showMenu: .constant(false), isDrawing: .constant(false))
    }
}
