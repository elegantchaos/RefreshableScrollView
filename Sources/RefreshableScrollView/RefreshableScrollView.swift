// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
//  Created by Sam Deane on 27/01/2022.
//  All code (c) 2022 - present day, Elegant Chaos.
// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-

// Many thanks to SwiftUI Lab for the original inspiration: https://swiftui-lab.com/scrollview-pull-to-refresh/

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


// A drop-in replacement for ScrollView, for situations where you want pull-to-refresh,
// but don't want to use a `List`.

public struct RefreshableScrollView<Content: View>: View {
    @Environment(\.refresh) var refreshAction
    @Environment(\.isSearching) var isSearching
    
    @StateObject var state: RefreshState
    
    let content: Content
    
    public let axes: Axis.Set
    
    public let showsIndicators: Bool
    
    public init(axes: Axis.Set = .vertical, showsIndicators: Bool = true, mode: RefreshableScrollMode = .normal, @ViewBuilder content: () -> Content) {
        // TODO: can we auto-detect the presence of the navigation view and/or searchability, and adjust mode automatically?
        
        self.content = content()
        self.axes = axes
        self.showsIndicators = showsIndicators
        _state = .init(wrappedValue: RefreshState(mode: mode))
    }
    
    public var body: some View {
        state.action = isSearching ? nil : refreshAction
        return VStack {
            ScrollView(isSearching ? [] : [axes], showsIndicators: showsIndicators) {
                ZStack(alignment: .top) {
                    BoundsReaderView(state: state, mode: .moving)
                        .background(Color.red)

                    self.content.alignmentGuide(.top, computeValue: { _ in state.alignmentOffset})
                    
                    IndicatorView(state: state)
                }
            }
            .background(
                BoundsReaderView(state: state, mode: .fixed)
            )
        }
    }
}

struct RefreshableScrollView_Previews: PreviewProvider {
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

    static var previews: some View {
        RefreshableScrollViewTestContainer()
    }
}

