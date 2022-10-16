//
//  ContentView.swift
//  BionicReading
//
//  Created by Siddharth Shakthivel Muthu Pandian on 29/09/2022.
//

import SwiftUI
import CoreData


struct ContentView: View { 
    var body: some View {
        Home()
            .preferredColorScheme(.light)
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView().environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
    }
}
