// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
//  Created by Sam Deane on 27/06/22.
//  All code (c) 2022 - present day, Elegant Chaos Limited.
// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-

import SwiftUI
import UIKit

/// Implements a ScrollView which uses the native UIScrollView to implement
/// a refresh control.
///
/// This has the example of working with the proper UIRefreshControl. However,
/// it doesn't play well with SwiftUI's NavigationView. For that scenario, use
/// ``RefreshableScrollView`` instead.
public struct NativeRefreshableScrollView<Content: View>: UIViewControllerRepresentable {
    @Environment(\.refresh) var refreshAction

    let content: Content
    let axes: Axis.Set
    let showsIndicators: Bool
    @State var isRefreshing: Bool = false

    public init(axes: Axis.Set = .vertical, showsIndicators: Bool = true, @ViewBuilder content: () -> Content) {
        self.axes = axes
        self.showsIndicators = showsIndicators
        self.content = content()
    }
    
    /// Internal view controller which handles the UIScrollView, and
    /// embeds a UIHostingController in it, which contains the SwiftUI
    /// contents of the scroll view.
    public class Controller: UIViewController, UIScrollViewDelegate {
        var contentController: UIHostingController<Content>?
        var scrollView: UIScrollView?
        
        /// Setup the UIKit views for the first time.
        func setup(for content: Content, refreshAction: RefreshAction?, showsIndicators: Bool, axes: Axis.Set) {
            
            let refreshControl = UIRefreshControl()

            let action = UIAction { _ in
                Task {
                    refreshControl.beginRefreshing()
                    await refreshAction?()
                    refreshControl.endRefreshing()
                }
            }
            
            refreshControl.addAction(action, for: .primaryActionTriggered)
            
            let scrollView = UIScrollView()
            scrollView.refreshControl = refreshControl
            scrollView.showsVerticalScrollIndicator = showsIndicators && axes.contains(.vertical)
            scrollView.showsHorizontalScrollIndicator = showsIndicators && axes.contains(.horizontal)
            scrollView.delegate = self
            
            self.scrollView = scrollView
            self.contentController = UIHostingController(rootView: content)
        }

        /// Update the UIKit views to reflect the current SwiftUI state.
        func update(showsIndicators: Bool, axes: Axis.Set) {
            if let scrollView = self.scrollView, let contentController = contentController {
                var size = contentController.view.intrinsicContentSize
                if !axes.contains(.horizontal) {
                    size.width = scrollView.frame.width
                }
                if !axes.contains(.vertical) {
                    size.height = scrollView.frame.height
                }

                scrollView.contentSize = size
                preferredContentSize = size
            }
        }
        
        /// Clean up the UIKit views before removal.
        func cleanup() {
            scrollView?.refreshControl = nil
        }

        /// Load the root UIScrollView.
        public override func loadView() {
            view = scrollView
        }

        /// Set up the scroll view layout contstraints and embed the UIHostingController's view.
        public override func viewDidLoad() {
            if let scrollView = self.scrollView, let contentController = contentController, let contentView = contentController.view {
                contentView.translatesAutoresizingMaskIntoConstraints = false
                scrollView.addSubview(contentController.view)

                NSLayoutConstraint.activate([
                    contentView.widthAnchor.constraint(equalTo: scrollView.widthAnchor),
                    contentView.centerXAnchor.constraint(equalTo: scrollView.centerXAnchor),
                    contentView.topAnchor.constraint(equalTo: scrollView.topAnchor),
                    contentView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
                    ])
            }
        }
        
        public override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
           super.traitCollectionDidChange(previousTraitCollection)

           contentController?.view.invalidateIntrinsicContentSize()
         }
    }

    /// Create a custom UIViewController and set it up.
    public func makeUIViewController(context: Context) -> Controller {
        let controller = Controller()
        controller.setup(for: content, refreshAction: refreshAction, showsIndicators: showsIndicators, axes: axes)
        controller.update(showsIndicators: showsIndicators, axes: axes)
        return controller
    }
    
    /// Update the custom UIViewController.
    public func updateUIViewController(_ controller: Controller, context: Context) {
        controller.update(showsIndicators: showsIndicators, axes: axes)
    }
    
    /// Clean up the custom UIViewController.
    public static func dismantleUIViewController(_ controller: Controller, coordinator: ()) {
        controller.cleanup()
    }
}
