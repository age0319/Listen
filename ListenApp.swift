//
//  ListenApp.swift
//  Listen
//
//  Created by nokkun on 2022/01/19.
//

import SwiftUI

@main
struct ListenApp: App {
    let persistenceController = PersistenceController.shared

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
        }
    }
}
