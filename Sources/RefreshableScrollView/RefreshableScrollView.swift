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

public class RectStorage: ObservableObject {
    @Published var movingRect: CGRect = .zero
    @Published var fixedRect: CGRect = .zero

    @Published var previousScrollOffset: CGFloat = 0
    @Published var scrollOffset: CGFloat = 0
    @Published var frozen: Bool = false
    @Published var percentage: Double = 0
    
    /// How far the user must drag before refreshing starts.
    let travelDistance: CGFloat
    
    /// The offset of the indicator view from the top of the content.
    let activityOffset: CGFloat
    
    @Published var refreshing: Bool = false

    let insertActivity: Bool
    var action: RefreshAction? = nil
    
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
    
    func update() {
        // Calculate scroll offset
        scrollOffset  = movingRect.minY - fixedRect.minY
        
        percentage = min(1.0, scrollOffset / travelDistance)
        
        // Crossing the threshold on the way down, we start the refresh process
        if !refreshing && (scrollOffset > travelDistance && previousScrollOffset <= travelDistance) {
            refreshing = true
            Task {
                print("running action")
                await action?()
                print("done action")
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

public struct RefreshableScrollView<Content: View>: View {
    @Environment(\.refresh) var refreshAction
    
    @ViewBuilder let content: () -> Content
    @State private var rects: RectStorage
    
    public init(mode: RefreshableScrollMode = .normal, @ViewBuilder content: @escaping () -> Content) {
        let state = RectStorage(mode: mode)
        
        self.content = content
        self._rects = .init(initialValue: state)
    }
    
    public var body: some View {
        rects.action = refreshAction
        return RefreshableScrollViewInner(content: content)
            .environmentObject(rects)
    }
}

public struct RefreshableScrollViewInner<Content: View>: View {
    @EnvironmentObject var state: RectStorage
    
    let content: Content
    
    public init(@ViewBuilder content: () -> Content) {
        // TODO: can we auto-detect the presence of the navigation view and/or searchability, and adjust mode automatically?
        
        self.content = content()
    }
    
    public var body: some View {
//        Self._printChanges()
        
        return VStack {
            ScrollView {
                ZStack(alignment: .top) {
                    MovingView()
                    
                    self.content.alignmentGuide(.top, computeValue: alignmentGuide)
                    
                    IndicatorView(height: state.activityOffset, loading: state.refreshing, frozen: state.frozen, offset: shouldOffsetIndicator, percentage: state.percentage)
                }
            }
            .background(FixedView())
        }
    }
    
    var shouldOffsetIndicator: Bool {
        return !state.insertActivity || !(state.refreshing && state.frozen)
    }
    
    func alignmentGuide(dimensions: ViewDimensions) -> CGFloat {
        if state.insertActivity {
            return (state.refreshing && state.frozen) ? -state.activityOffset : 0.0
        } else {
            return 0
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
        @EnvironmentObject var rects: RectStorage
        
        var body: some View {
            GeometryReader { proxy in
                pushRect(proxy: proxy)
            }.frame(height: 0)
        }
        
        func pushRect(proxy: GeometryProxy) -> Color {
            
            let rect = proxy.frame(in: .global)
            if rect != rects.movingRect {
                DispatchQueue.main.async {
                    rects.movingRect = rect
                    rects.update()
                }
            }
            return Color.clear
        }
    }
    
    struct FixedView: View {
        @EnvironmentObject var rects: RectStorage
        
        var body: some View {
            GeometryReader { proxy in
                pushRect(proxy: proxy)
            }
        }
        
        func pushRect(proxy: GeometryProxy) -> Color {
            let rect = proxy.frame(in: .global)
            if rect != rects.fixedRect {
                DispatchQueue.main.async {
                    rects.fixedRect = rect
                    rects.update()
                }
            }
            return Color.clear
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

