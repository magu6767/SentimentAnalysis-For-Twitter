//
//  DataController.swift
//  SentimentAnalysis
//
//  Created by 間口秀人 on 2023/01/01.
//

import Foundation
import CoreData

class DataController: ObservableObject {
    let container = NSPersistentContainer(name: "SentimentAnalysis")
    
    init() {
        container.loadPersistentStores { description, error in
            if let error = error {
                print("Core Data failed to load: \(error.localizedDescription)")
            }
        }
    }
}
