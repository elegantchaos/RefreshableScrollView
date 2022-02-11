// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
//  Created by Sam Deane on 27/01/22.
//  All code (c) 2022 - present day, Elegant Chaos Limited.
// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-

import SwiftUI

struct RefreshableKey: PreferenceKey {
    enum ViewType: Int {
        case movingView
        case fixedView
    }
    
    struct ViewBounds: Equatable {
        let vType: ViewType
        let bounds: CGRect
    }
    
    static var defaultValue: ViewBounds?
    
    static func reduce(value: inout ViewBounds?, nextValue: () -> ViewBounds?) {
        value = nextValue()
    }
    
    typealias Value = ViewBounds?
}
