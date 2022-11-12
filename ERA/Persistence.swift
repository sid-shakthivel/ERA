//
//  Persistence.swift
//  ERA
//
//  Created by Siddharth Shakthivel Muthu Pandian on 12/11/2022.
//

import Foundation
import CoreData

struct PersistenceController {
    // A singleton for ERA to use
    static let shared = PersistenceController()

    // Storage for Core Data
    let container: NSPersistentContainer

    // An initializer to load Core Data, optionally able to use an in-memory store.
    init(inMemory: Bool = false) {
        container = NSPersistentContainer(name: "ERA")

        if inMemory {
            container.persistentStoreDescriptions.first?.url = URL(fileURLWithPath: "/dev/null")
        }

        container.loadPersistentStores { description, error in
            if let error = error {
                fatalError("Error: \(error.localizedDescription)")
            }
        }
    }
    
    func save() {
        let context = container.viewContext

        if context.hasChanges {
            do {
                try context.save()
            } catch {
                // Need to provide error message on 
            }
        }
    }
}
