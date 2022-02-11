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
    
    public init(mode: RefreshableScrollMode = .normal, @ViewBuilder content: () -> Content) {
        // TODO: can we auto-detect the presence of the navigation view and/or searchability, and adjust mode automatically?
        
        self.content = content()
        _state = .init(wrappedValue: RefreshState(mode: mode))
    }
    
    public var body: some View {
        state.action = isSearching ? nil : refreshAction
        return VStack {
            ScrollView(isSearching ? [] : [.vertical]) {
                ZStack(alignment: .top) {
                    BoundsReaderView(state: state, mode: .moving)
                    
                    self.content.alignmentGuide(.top, computeValue: alignmentGuide)
                    
                    IndicatorView(height: state.activityOffset, loading: state.refreshing, frozen: state.frozen, offset: shouldOffsetIndicator, percentage: state.percentage)
                }
            }
            .background(BoundsReaderView(state: state, mode: .fixed))
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

