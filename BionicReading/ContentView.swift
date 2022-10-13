//
//  ContentView.swift
//  BionicReading
//
//  Created by Siddharth Shakthivel Muthu Pandian on 29/09/2022.
//

import SwiftUI
import CoreData

class UserCustomisations: ObservableObject {
    @Published var selectedTextSize: Int = 20
    @Published var selectedTextColour: Color = .orange
    @Published var selectedBackgroundColour: Color = .blue
    @Published var selectedFont: UIFont = UIFont.systemFont(ofSize: 20)
    @Published var selectedHeadingFont: UIFont = UIFont.systemFont(ofSize: 40)
    @Published var isBionicReading: Bool = false
}

struct ContentView: View {
    @State var selectedFont: UIFontDescriptor
    
    @StateObject var userSettings = UserCustomisations()
    
    var body: some View {
        TabView {
            Scan(scanText: "")
                .tabItem() {
                    Image(systemName: "house.fill")
                }
            
            Settings( selectedFont: selectedFont)
                .tabItem() {
                    Image(systemName: "gear")
                }
        }
        .accentColor(.red)
        .environmentObject(userSettings)
    }
}


struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView(selectedFont: UIFontDescriptor(name: "CourierNewPSMT", size: 20)).environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
    }
}
