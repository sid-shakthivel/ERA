//
//  BionicReadingApp.swift
//  BionicReading
//
//  Created by Siddharth Shakthivel Muthu Pandian on 29/09/2022.
//

import SwiftUI

@main
struct BionicReadingApp: App {
    let persistenceController = PersistenceController.shared

    var body: some Scene {
        WindowGroup {
            ContentView(selectedFont: UIFontDescriptor(name: "CourierNewPSMT", size: 20))
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
        }
    }
}
