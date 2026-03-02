//
//  Router.swift
//  Prayer Tracker
//
//  Created by John-Mark Iliev on 14.12.25.
//

import SwiftUI

enum Destination: Hashable {
    case home
}

@MainActor
@Observable final class Router {
    
    var navigationPath = NavigationPath()
    var stack: [Destination] = []
    
    @ViewBuilder func view(for destination: Destination) -> some View {
        switch destination {
        case .home:
            TabBarScreen()
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
    
    func popToRoot() {
        let count = navigationPath.count
        self.navigationPath.removeLast(count)
        self.stack.removeAll()
    }
}
  
