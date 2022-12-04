//
//  EditDraw.swift
//  ERA
//
//  Created by Siddharth Shakthivel Muthu Pandian on 31/10/2022.
//

import SwiftUI

struct EditPencil: View {
    @EnvironmentObject var canvasSettings: TempCanvas
    @EnvironmentObject var settings: UserPreferences
    
    @State var drawingToolName: String
    
    let colours: [Color] = [.black, .red, .green, .yellow, .blue, .brown]
    
    var body: some View {
        VStack {
            Text("\(drawingToolName)")
                .foregroundColor(.black)
                .font(.system(size: 24))
                .fontWeight(.semibold)
            
            VStack {
                HStack {
                    ForEach(colours, id: \.self) { colour in
                        Button(action: {
                            canvasSettings.selectedColour = colour
                        }, label: {
                            Image(systemName: "circle.fill")
                                .foregroundColor(colour)
                                .font(.title)
                                .if(colour == canvasSettings.selectedColour) { view in
                                        view.overlay(
                                            RoundedRectangle(cornerRadius: 16)
                                                .stroke(.gray, lineWidth: 2)
                                        )
                                }
                        })

                        Spacer()
                    }
                    
                    Spacer()
                    
                    if canvasSettings.isUsingHighlighter {
                        ColorPicker(selection: $canvasSettings.selectedHighlighterColour) {
                        }
                            .font(.title)
                    } else {
                        ColorPicker(selection: $canvasSettings.selectedColour) {
                        }
                            .font(.title)
                    }
                }
                
                HStack {
                    Slider(value: $canvasSettings.lineWidth, in: 0...20)
                        .padding(.bottom)
                        .padding(.leading)
                        .padding(.trailing)
                    
                    Text("\(Int(canvasSettings.lineWidth)) pt")
                        .foregroundColor(.black)
                        .fontWeight(.bold)
                        .padding()
                }
            }
            .padding()
            .background(Color(hex: 0xFFF9F0, alpha: 1))
            .cornerRadius(25)
        }
            .padding()
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(Color(hex: 0xa6a6a6).edgesIgnoringSafeArea(.all))
    }
}

struct EditDraw_Previews: PreviewProvider {
    static var previews: some View {
        EditPencil(drawingToolName: "Pencil")
    }
}
