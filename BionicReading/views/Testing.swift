//
//  Testing.swift
//  BionicReading
//
//  Created by Siddharth Shakthivel Muthu Pandian on 17/10/2022.
//

import SwiftUI

struct Testing: View {
    @State var paragraph: [String]
    
    var body: some View {
        HStack {
            ForEach(paragraph.joined(separator: " ") .split(separator: " ", maxSplits: Int.max, omittingEmptySubsequences: true), id:\.self) { line in
                Text(line)
            }
        }
    }
}

struct Testing_Previews: PreviewProvider {
    static var previews: some View {
        Testing(paragraph: ["Hello"])
    }
}
