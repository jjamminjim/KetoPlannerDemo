//
//  KetoPlannerDemoApp.swift
//  KetoPlannerDemo
//
//  Created by Jim Boyd on 10/27/25.
//

import SwiftUI
import SwiftData

@main
struct KetoPlannerDemoApp: App {
    var sharedModelContainer: ModelContainer = {
        let schema = Schema([
//            Item.self,
            ChatThread.self,
            BaseMessage.self,
//            UserMessage.self,
//            AssistantMessage.self
        ])
        let modelConfiguration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false)

        do {
            return try ModelContainer(for: schema, configurations: [modelConfiguration])
        } catch {
            fatalError("Could not create ModelContainer: \(error)")
        }
    }()

    var body: some Scene {
        WindowGroup {
//          ContentView()
            ChatView()
       }
        .modelContainer(sharedModelContainer)
    }
}


//@main
//struct KetoPlannerDemoApp: App {
//    var body: some Scene {
//        WindowGroup {
//            ChatView()
//        }
//        .modelContainer(sharedModelContainer)
//    }
//}
//
//let sharedModelContainer: ModelContainer = {
//    let schema = Schema([
//        ChatThread.self,
//        BaseMessage.self,
//        UserMessage.self,
//        AssistantMessage.self
//    ])
//    
//    let configuration = ModelConfiguration(isStoredInMemoryOnly: false)
//    return try! ModelContainer(for: schema, configurations: [configuration])
//}()
