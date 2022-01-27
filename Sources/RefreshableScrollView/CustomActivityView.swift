// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
//  Created by Sam Deane on 27/01/22.
//  All code (c) 2022 - present day, Elegant Chaos Limited.
// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-

import SwiftUI

/// A large UIActivityView which stays visible all the time.

struct CustomActivityView: UIViewRepresentable {
    let animating: Bool
    
    func makeUIView(context: UIViewRepresentableContext<CustomActivityView>) -> UIActivityIndicatorView {
        let view = UIActivityIndicatorView()
        view.style = .large
        view.hidesWhenStopped = false
        return view
    }
    
    func updateUIView(_ uiView: UIActivityIndicatorView, context: UIViewRepresentableContext<CustomActivityView>) {
        if animating {
            uiView.startAnimating()
        } else {
            uiView.stopAnimating()
        }
    }
}
