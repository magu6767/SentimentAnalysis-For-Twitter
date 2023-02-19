//
//  SentimentAnalysisApp.swift
//  SentimentAnalysis
//
//  Created by 間口秀人 on 2022/12/24.
//

import SwiftUI

@main
struct SentimentAnalysisApp: App {
    @StateObject private var dataController = DataController()

    var body: some Scene {
        WindowGroup {
            NavigationStack{
                ContentView()
                    .environment(\.managedObjectContext, dataController.container.viewContext)
            }
        }
    }
}
