// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
//  Created by Sam Deane on 11/02/22.
//  All code (c) 2022 - present day, Elegant Chaos Limited.
// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-

import SwiftUI

struct BoundsReaderView: View {
    let state: RefreshState
    let mode: RefreshState.Update
    
    var body: some View {
        GeometryReader { proxy in
            pushRect(proxy: proxy)
        }.frame(height: mode == .moving ? 0 : nil)
    }
    
    func pushRect(proxy: GeometryProxy) -> Color {
        let rect = proxy.frame(in: .global)
        DispatchQueue.main.async {
            state.update(mode, newRect: rect)
        }
        return Color.clear
    }
}
