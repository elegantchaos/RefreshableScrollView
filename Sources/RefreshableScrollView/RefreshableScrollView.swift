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

public struct RefreshableScrollView<Content: View>: View {
    @State private var previousScrollOffset: CGFloat = 0
    @State private var scrollOffset: CGFloat = 0
    @State private var frozen: Bool = false
    @State private var percentage: Double = 0
    @Environment(\.refresh) var refreshAction
    
    var threshold: CGFloat = 80
    @State var refreshing: Bool = false
    let content: Content
    
    public init(height: CGFloat = 80, @ViewBuilder content: () -> Content) {
        self.threshold = height
        self.content = content()
    }
    
    public var body: some View {
        return VStack {
            ScrollView {
                ZStack(alignment: .top) {
                    MovingView()
                    
                    VStack { self.content }.alignmentGuide(.top, computeValue: { d in (self.refreshing && self.frozen) ? -self.threshold : 0.0 })
                    
                    SymbolView(height: self.threshold, loading: self.refreshing, frozen: self.frozen, percentage: self.percentage)
                }
            }
            .background(FixedView())
            .onPreferenceChange(RefreshableKeyTypes.PrefKey.self) { values in
                self.refreshLogic(values: values)
            }
        }
    }
    
    func refreshLogic(values: [RefreshableKeyTypes.PrefData]) {
        DispatchQueue.main.async {
            // Calculate scroll offset
            let movingBounds = values.first { $0.vType == .movingView }?.bounds ?? .zero
            let fixedBounds = values.first { $0.vType == .fixedView }?.bounds ?? .zero
            
            self.scrollOffset  = movingBounds.minY - fixedBounds.minY
            
            self.percentage = min(1.0, scrollOffset / self.threshold)
            
            // Crossing the threshold on the way down, we start the refresh process
            if !self.refreshing && (self.scrollOffset > self.threshold && self.previousScrollOffset <= self.threshold) {
                self.refreshing = true
                Task {
                    await refreshAction?()
                    self.refreshing = false
                }
            }
            
            if self.refreshing {
                // Crossing the threshold on the way up, we add a space at the top of the scrollview
                if self.previousScrollOffset > self.threshold && self.scrollOffset <= self.threshold {
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
    
    struct SymbolView: View {
        var height: CGFloat
        var loading: Bool
        var frozen: Bool
        var percentage: Double
        
        
        var body: some View {
            VStack {
                Spacer()
                ActivityRep(loading: loading)
                    .opacity(percentage)
                    .controlSize(.large)
                Spacer()
            }
            .frame(height: height).fixedSize()
            .offset(y: -height + (self.loading && self.frozen ? height : 0.0))
        }
    }
    
    struct MovingView: View {
        var body: some View {
            GeometryReader { proxy in
                Color.clear.preference(key: RefreshableKeyTypes.PrefKey.self, value: [RefreshableKeyTypes.PrefData(vType: .movingView, bounds: proxy.frame(in: .global))])
            }.frame(height: 0)
        }
    }
    
    struct FixedView: View {
        var body: some View {
            GeometryReader { proxy in
                Color.clear.preference(key: RefreshableKeyTypes.PrefKey.self, value: [RefreshableKeyTypes.PrefData(vType: .fixedView, bounds: proxy.frame(in: .global))])
            }
        }
    }
}

struct RefreshableKeyTypes {
    enum ViewType: Int {
        case movingView
        case fixedView
    }
    
    struct PrefData: Equatable {
        let vType: ViewType
        let bounds: CGRect
    }
    
    struct PrefKey: PreferenceKey {
        static var defaultValue: [PrefData] = []
        
        static func reduce(value: inout [PrefData], nextValue: () -> [PrefData]) {
            value.append(contentsOf: nextValue())
        }
        
        typealias Value = [PrefData]
    }
}

struct ActivityRep: UIViewRepresentable {
    let loading: Bool
    
    func makeUIView(context: UIViewRepresentableContext<ActivityRep>) -> UIActivityIndicatorView {
        let view = UIActivityIndicatorView()
        view.style = .large
        view.hidesWhenStopped = false
        return view
    }
    
    func updateUIView(_ uiView: UIActivityIndicatorView, context: UIViewRepresentableContext<ActivityRep>) {
        if loading {
            uiView.startAnimating()
        } else {
            uiView.stopAnimating()
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

