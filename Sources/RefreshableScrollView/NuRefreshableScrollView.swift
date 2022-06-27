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
        
        func setup(for content: Content, refreshAction: RefreshAction?) {
            
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
            scrollView.delegate = self
            
            self.scrollView = scrollView
            self.contentController = UIHostingController(rootView: content)
        }

        public override func loadView() {
            view = scrollView
        }

        public override func viewDidLoad() {
            if let scrollView = self.scrollView, let contentController = contentController, let contentView = contentController.view {
                scrollView.addSubview(contentController.view)

                contentView.translatesAutoresizingMaskIntoConstraints = false
                NSLayoutConstraint.activate([
                    contentView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
                    contentView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
                    contentView.topAnchor.constraint(equalTo: scrollView.topAnchor),
                    contentView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
                    ])

//                addChild(contentController)
            }
        }
        
        public override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
           super.traitCollectionDidChange(previousTraitCollection)

           contentController?.view.invalidateIntrinsicContentSize()
         }
    }

    public func makeUIViewController(context: Context) -> Controller {
        let controller = Controller()
        controller.setup(for: content, refreshAction: refreshAction)
        return controller
    }
    
    public func updateUIViewController(_ uiViewController: Controller, context: Context) {
        
    }
    
    
}
