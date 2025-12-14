//
//  Router.swift
//  Prayer Tracker
//
//  Created by John-Mark Iliev on 14.12.25.
//

import SwiftUI

enum Destination: Hashable {
    case today
}

struct AppCompositionRoot: View {
    @State private var router = Router()
    @State private var localPersistanceContainer = LocalPersistanceContainer()
    
    var body: some View {
        NavigationStack(path: $router.navigationPath) {
            TabBarScreen()
                .navigationDestination(for: Destination.self) { dest in
                    router.view(for: dest)
                }
        }
        .tint(.appTint)
        .environment(router)
    }
}


@MainActor
@Observable final class Router {
    
    var navigationPath = NavigationPath()
    var stack: [Destination] = []
    
    @ViewBuilder func view(for destination: Destination) -> some View {
        switch destination {
        case .today:
            TodayView()
        }
    }
    
//MARK: - Navigation Methods
    func navigateTo(_ destination: Destination) {
        self.navigationPath.append(destination)
        self.stack.append(destination)
    }
    
    func popBack() {
        self.navigationPath.removeLast()
        self.stack.removeLast()
    }
}
  
