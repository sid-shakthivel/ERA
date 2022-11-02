//
//  EditDraw.swift
//  ERA
//
//  Created by Siddharth Shakthivel Muthu Pandian on 31/10/2022.
//

import SwiftUI

struct EditPencil: View {
    @EnvironmentObject var canvasSettings: CanvasSettings
    
    let colours: [Color] = [.black, .red, .green, .yellow, .blue, .brown]
    
    var body: some View {
        VStack {
            Text("Pencil")
                .foregroundColor(.black)
                .font(.system(size: 24))
                .fontWeight(.semibold)
            
            VStack {
                HStack {
//                    ForEach(colours, id: \.self) { colour in
//                        Button(action: {
//                            canvasSettings.selectedColour = colour
//                        }, label: {
//                            Image(systemName: "circle.fill")
//                                .foregroundColor(colour)
//                                .font(.title)
//                                .border(.blue)
//                        })
//
//                        Spacer()
//                    }
                    
                    Text("Colour")
                        .font(.system(size: 16))
                        .fontWeight(.semibold)
                        .padding()
                    
                    Spacer()
                    
                    ColorPicker(selection: $canvasSettings.selectedColour) {
                    }
                        .font(.title)
                }
                
                HStack {
                    Slider(value: $canvasSettings.lineWidth, in: 0...20)
                        .padding(.bottom)
                        .padding(.leading)
                        .padding(.trailing)
                    
                    Text("\(Int(canvasSettings.lineWidth)) pt")
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
        EditPencil()
    }
}
