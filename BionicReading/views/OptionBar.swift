//
//  OptionBar.swift
//  BionicReading
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
                Image("setting")
                    .font(.largeTitle)
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
                    Image(systemName: "checkmark")
                        .font(.largeTitle)
                })
                
                Button(action: {
                    canvasSettings.lines = []
                }, label: {
                    Image(systemName: "trash.fill")
                        .font(.largeTitle)
                        .foregroundColor(.gray)
                })
                
                Button(action: {
                    if canvasSettings.lines.count > 1 {
                        canvasSettings.lastLine = canvasSettings.lines.removeLast()
                    }
                }, label: {
                    Image(systemName: "arrow.uturn.backward")
                        .font(.largeTitle)
                })
                
                Button(action: {
                    if canvasSettings.lastLine != nil {
                        canvasSettings.lines.append(canvasSettings.lastLine!)
                        canvasSettings.lastLine = nil
                    }
                }, label: {
                    Image(systemName: "arrow.uturn.forward")
                        .font(.largeTitle)
                })
            }

            Slider(value: $canvasSettings.lineWidth, in: 0...20)
                .padding()
        }
    }
    
    @ViewBuilder
    func colourButton(colour: Color) -> some View {
        Button(action: {
            isDrawing = true
            canvasSettings.selectedColour = colour
        }, label: {
            Image(systemName: "circle.fill")
                .font(.largeTitle)
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
