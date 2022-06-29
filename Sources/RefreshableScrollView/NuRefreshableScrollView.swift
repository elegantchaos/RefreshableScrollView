// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
//  Created by Sam Deane on 27/06/22.
//  All code (c) 2022 - present day, Elegant Chaos Limited.
// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-

import SwiftUI
import UIKit

public struct NuRefreshableScrollView<Content: View>: UIViewControllerRepresentable {
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
    
    public class Controller: UIViewController, UIScrollViewDelegate {
        var contentController: UIHostingController<Content>?
        var scrollView: UIScrollView?
        
        override public var preferredContentSize: CGSize {
            get { contentController?.view?.intrinsicContentSize ?? super.preferredContentSize }
            set { super.preferredContentSize = newValue }
        }

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
                print("intrinsic \(contentController.view.intrinsicContentSize), frame \(scrollView.frame.size), used \(size)")
            }
        }
        
        func cleanup() {
            scrollView?.refreshControl = nil
        }
        
        public override func loadView() {
            view = scrollView
        }

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

    public func makeUIViewController(context: Context) -> Controller {
        let controller = Controller()
        controller.setup(for: content, refreshAction: refreshAction, showsIndicators: showsIndicators, axes: axes)
        controller.update(showsIndicators: showsIndicators, axes: axes)
        return controller
    }
    
    public func updateUIViewController(_ controller: Controller, context: Context) {
        controller.update(showsIndicators: showsIndicators, axes: axes)
    }
    
    public static func dismantleUIViewController(_ controller: Controller, coordinator: ()) {
        controller.cleanup()
    }
}
