//
//  DataController.swift
//  ERA
//
//  Created by Siddharth Shakthivel Muthu Pandian on 20/11/2022.
//

import Foundation
import CoreData

class DataController: ObservableObject {
    // NSPersistentContainer is data type responsible for loading data model and providing access inside
    let container = NSPersistentContainer(name: "ERA")
    
    init() {
        // To load data model, must call this function, to tell Core Data to access saved data
        container.loadPersistentStores { description, error in
            if let error = error {
                print("Core data failed to load with error \(error.localizedDescription)")
            }
        }
    }
    
}
