// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
//  Created by Sam Deane on 27/01/2022.
//  All code (c) 2022 - present day, Elegant Chaos.
// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-

// This is a modified version of the view presented here:
// https://swiftui-lab.com/scrollview-pull-to-refresh/
//
// Many thanks to SwiftUI Lab for the inspiration.
//
// The need to pass in a binding has been removed, and it works with
// the standard `refreshable` modifier introduced in SwiftUI 3.
//
// It is intended for situations where you want pull-to-refresh, but
// don't want to use `List`.

import Foundation
import SwiftUI

extension Double {
    static let activityThreshold = 0.6
}

public enum RefreshableScrollMode {
    case normal
    case navigation
    case searchableNavigation
    case custom(Double, Double, Bool)
}

public struct RefreshableScrollView<Content: View>: View {
    @Environment(\.refresh) var refreshAction

    @State private var previousScrollOffset: CGFloat = 0
    @State private var scrollOffset: CGFloat = 0
    @State private var frozen: Bool = false
    @State private var percentage: Double = 0
    
    /// How far the user must drag before refreshing starts.
    var travelDistance: CGFloat
    
    /// The offset of the indicator view from the top of the content.
    var activityOffset: CGFloat
    
    @State var refreshing: Bool = false
    let content: Content
    
    let insertActivity: Bool
    
    
    public init(mode: RefreshableScrollMode = .normal, @ViewBuilder content: () -> Content) {
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

        self.content = content()
    }
    
    public var body: some View {
        return VStack {
            ScrollView {
                ZStack(alignment: .top) {
                    MovingView()
                    
                    self.content.alignmentGuide(.top, computeValue: alignmentGuide)
                    
                    IndicatorView(height: self.activityOffset, loading: self.refreshing, frozen: self.frozen, offset: shouldOffsetIndicator, percentage: self.percentage)
                }
            }
            .background(FixedView())
            .onPreferenceChange(RefreshableKey.self) { values in
                self.refreshLogic(values: values)
            }
        }
    }
    
    var shouldOffsetIndicator: Bool {
        return !insertActivity || !(refreshing && frozen)
    }
    
    func alignmentGuide(dimensions: ViewDimensions) -> CGFloat {
        if insertActivity {
            return (self.refreshing && self.frozen) ? -self.activityOffset : 0.0
        } else {
            return 0
        }
    }
    
    func refreshLogic(values: [RefreshableKey.ViewBounds]) {
        DispatchQueue.main.async {
            // Calculate scroll offset
            let movingBounds = values.first { $0.vType == .movingView }?.bounds ?? .zero
            let fixedBounds = values.first { $0.vType == .fixedView }?.bounds ?? .zero
            
            self.scrollOffset  = movingBounds.minY - fixedBounds.minY
            
            self.percentage = min(1.0, scrollOffset / self.travelDistance)
            
            // Crossing the threshold on the way down, we start the refresh process
            if !self.refreshing && (self.scrollOffset > self.travelDistance && self.previousScrollOffset <= self.travelDistance) {
                self.refreshing = true
                Task {
                    await refreshAction?()
                    self.refreshing = false
                }
            }
            
            if self.refreshing {
                // Crossing the threshold on the way up, we add a space at the top of the scrollview
                if self.previousScrollOffset > self.travelDistance && self.scrollOffset <= self.travelDistance {
                    self.frozen = true
                    
                }
            } else {
                // remove the sapce at the top of the scroll view
                self.frozen = false
            }
            
            // Update last scroll offset
            self.previousScrollOffset = self.scrollOffset
        }
    }
    
    struct IndicatorView: View {
        let height: CGFloat
        let loading: Bool
        let frozen: Bool
        let offset: Bool
        let percentage: Double
        
        var body: some View {
            VStack {
                Spacer()
                CustomActivityView(animating: loading)
                    .opacity(opacity)
                Spacer()
            }
            .frame(height: height).fixedSize()
            .offset(y: offset ? -height: 0.0)
        }
        
        var opacity: Double {
            if loading && frozen {
                return 1.0
            }
            
            let opacity = (percentage < .activityThreshold) ? 0.0 : (percentage - .activityThreshold) / (1.0 - .activityThreshold)
            return opacity
        }
    }
    
    struct MovingView: View {
        var body: some View {
            GeometryReader { proxy in
                Color.clear.preference(key: RefreshableKey.self, value: [RefreshableKey.ViewBounds(vType: .movingView, bounds: proxy.frame(in: .global))])
            }.frame(height: 0)
        }
    }
    
    struct FixedView: View {
        var body: some View {
            GeometryReader { proxy in
                Color.clear.preference(key: RefreshableKey.self, value: [RefreshableKey.ViewBounds(vType: .fixedView, bounds: proxy.frame(in: .global))])
            }
        }
    }
}

struct RefreshableScrollViewTestContainer: View {
    var body: some View {
        RefreshableScrollView() {
            ForEach(1..<100) { item in
                Text("\(item)")
            }
        }
        .refreshable {
            print("refreshing")
        }
    }
}

struct RefreshableScrollView_Previews: PreviewProvider {
    
    static var previews: some View {
        RefreshableScrollViewTestContainer()
    }
}

