//
//  durakApp.swift
//  durak
//
//  Created by Кирилл Иванников on 19.03.2023.
//

import SwiftUI

@main
struct durakApp: App {
    var body: some Scene {
        WindowGroup {
            ZStack {
                Color.black.opacity(0.8).ignoresSafeArea(.all)
                
                let engine = DurakEngine()
                ContentView(engine: engine)
            }
        }
    }
}
