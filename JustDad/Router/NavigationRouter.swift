//
//  NavigationRouter.swift
//  JustDad - Navigation router
//
//  Centralized navigation management for the app
//

import SwiftUI
import Foundation

// MARK: - NavigationRouter
@MainActor
class NavigationRouter: ObservableObject {
    // MARK: - Singleton
    static let shared = NavigationRouter()
    
    // MARK: - Navigation State
    @Published var paths: [Route] = []
    
    // Sheet presentations
    @Published var activeSheet: Route?
    
    // Full screen covers
    @Published var activeFullScreenCover: Route?
    
    // MARK: - Navigation Actions
    
    func push(_ route: Route) {
        paths.append(route)
    }
    
    func pop() {
        guard !paths.isEmpty else { return }
        paths.removeLast()
    }
    
    func popToRoot() {
        paths.removeAll()
    }
    
    func reset() {
        paths.removeAll()
        activeSheet = nil
        activeFullScreenCover = nil
    }
    
    // MARK: - Modal Presentation
    // TODO: Implement sheet presentation logic
    func presentSheet(_ route: Route) {
        activeSheet = route
    }
    
    func dismissSheet() {
        activeSheet = nil
    }
    
    // TODO: Implement full screen cover logic
    func presentFullScreenCover(_ route: Route) {
        activeFullScreenCover = route
    }
    
    func dismissFullScreenCover() {
        activeFullScreenCover = nil
    }
    
    // MARK: - Deep Link Handling
    // TODO: Implement deep link parsing and navigation
    func handleDeepLink(_ url: URL) {
        // Future implementation for deep linking
    }
}
