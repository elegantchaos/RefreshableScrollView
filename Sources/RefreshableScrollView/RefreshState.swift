// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
//  Created by Sam Deane on 11/02/22.
//  All code (c) 2022 - present day, Elegant Chaos Limited.
// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-

import SwiftUI

internal class RefreshState: ObservableObject {
    // MARK: Configuration
    /// How far the user must drag before refreshing starts.
    let travelDistance: CGFloat
    
    /// The offset of the indicator view from the top of the content.
    let activityOffset: CGFloat
    
    /// Should the activity indicator be inserted into the view contents,
    /// or floated above it?
    let insertActivity: Bool
    
    /// Refresh action to perform.
    var action: RefreshAction? = nil

    // MARK: Private State
    private var movingRect: CGRect = .zero
    private var fixedRect: CGRect = .zero
    private var previousScrollOffset: CGFloat = 0
    
    // MARK: Published State
    @Published var percentage: Double = 0
    @Published var refreshing: Bool = false
    @Published var frozen: Bool = false

    
    public init(mode: RefreshableScrollMode = .normal) {
        // TODO: can we auto-detect the presence of the navigation view and/or searchability, and adjust mode automatically?
        
        switch mode {
            case .normal:
                self.travelDistance = 80
                self.activityOffset = 80
                self.insertActivity = true
                
            case .navigation:
                self.travelDistance = 80
                self.activityOffset = 160
                self.insertActivity = false
                
            case .searchableNavigation:
                self.travelDistance = 80
                self.activityOffset = 240
                self.insertActivity = false
                
            case .custom(let distance, let offset, let insert):
                self.travelDistance = distance
                self.activityOffset = offset
                self.insertActivity = insert
        }
    }
    
    enum Update {
        case fixed
        case moving
    }
    
    func update(_ update: Update, newRect: CGRect) {
        switch update {
            case .fixed: fixedRect = newRect
            case .moving: movingRect = newRect
        }

        let scrollOffset  = movingRect.minY - fixedRect.minY
        let newPercentage = min(1.0, scrollOffset / travelDistance)
        
        if percentage != newPercentage {
            percentage = newPercentage
            
            // Crossing the threshold on the way down, we start the refresh process
            if !refreshing && (scrollOffset > travelDistance && previousScrollOffset <= travelDistance) {
                refreshing = true
                Task {
                    await action?()
                    DispatchQueue.main.async {
                        self.refreshing = false
                    }
                }
            }
            
            if refreshing {
                // Crossing the threshold on the way up, we add a space at the top of the scrollview
                if previousScrollOffset > travelDistance && scrollOffset <= travelDistance {
                    frozen = true
                    
                }
            } else {
                // remove the sapce at the top of the scroll view
                frozen = false
            }
            
            // Update last scroll offset
            previousScrollOffset = scrollOffset
        }
    }
}
