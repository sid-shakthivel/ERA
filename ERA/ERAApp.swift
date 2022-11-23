//
//  ERAApp.swift
//  ERA
//
//  Created by Siddharth Shakthivel Muthu Pandian on 29/09/2022.
//

import SwiftUI

class AppDelegate: NSObject, UIApplicationDelegate {
    func application(_ application: UIApplication) -> Bool {
        SavedParagraphAttributeTransformer.register()
        ScanResultAttributeTransformer.register()
        return true
    }
}

@main
struct ERAApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    
    @StateObject private var dataController = DataController()
    
    var body: some Scene {
        WindowGroup {
            /*
             Managed object con texts are live versions of data, allows modification of data, they exist in memory before being saved to persistent storage
             */
            ContentView()
                .environment(\.managedObjectContext, dataController.container.viewContext)
        }
    }
}

