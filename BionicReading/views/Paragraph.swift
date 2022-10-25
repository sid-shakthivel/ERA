//
//  Paragraph.swift
//  BionicReading
//
//  Created by Siddharth Shakthivel Muthu Pandian on 25/10/2022.
//

import SwiftUI

struct Paragraph: View {
    @State var text: String
    @ObservedObject var speaker = Speaker()
    
    var body: some View {
        LabelRepresented(text: speaker.label)
            .onTapGesture(count: 2) {
                speaker.speak(text)
            }
            .onAppear() {
                print("Hey")
                speaker.label = NSMutableAttributedString(string: text)
            }
    }
}

struct Paragraph_Previews: PreviewProvider {
    static var previews: some View {
        Paragraph(text: "Hello There")
    }
}
