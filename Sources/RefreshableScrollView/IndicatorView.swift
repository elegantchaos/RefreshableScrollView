// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
//  Created by Sam Deane on 11/02/22.
//  All code (c) 2022 - present day, Elegant Chaos Limited.
// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-

import SwiftUI

struct IndicatorView: View {
    @ObservedObject var state: RefreshState
    
    var body: some View {
        let height = state.activityOffset

        return CustomActivityView(animating: state.refreshing)
            .opacity(opacity)
            .frame(height: height).fixedSize()
            .offset(y: state.indicatorOffset)

//        return VStack {
//            Spacer()
//            CustomActivityView(animating: state.refreshing)
//                .opacity(opacity)
//            Spacer()
//        }
//        .frame(height: height).fixedSize()
//        .offset(y: state.indicatorOffset)
    }
    
    var opacity: Double {
        if state.refreshing && state.frozen {
            return 1.0
        }
        
        let opacity = (state.percentage < .activityThreshold) ? 0.0 : (state.percentage - .activityThreshold) / (1.0 - .activityThreshold)
        return opacity
    }
}
