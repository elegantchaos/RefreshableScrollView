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
        var refreshAction: RefreshAction?
        var contentController: UIHostingController<Content>?
        var refreshControl: UIRefreshControl?
        
        func setup(for content: Content, refreshAction: RefreshAction?) {
            let refreshControl = UIRefreshControl()
            refreshControl.addAction(UIAction(handler: handleRefresh), for: .primaryActionTriggered)
            
            let scrollView = UIScrollView()
            scrollView.refreshControl = refreshControl
 
            let contentController = UIHostingController(rootView: content)
            if let contentView = contentController.view {
                contentView.translatesAutoresizingMaskIntoConstraints = false
                NSLayoutConstraint.activate([
                    contentView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
                    contentView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
                    contentView.topAnchor.constraint(equalTo: scrollView.topAnchor),
                    contentView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
                    ])
            }
            
            addChild(contentController)
            scrollView.addSubview(contentController.view)

            self.view = scrollView
            self.refreshAction = refreshAction
            self.refreshControl = refreshControl
            self.contentController = contentController
        }

        public override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
           super.traitCollectionDidChange(previousTraitCollection)

           contentController?.view.invalidateIntrinsicContentSize()
         }

        func handleRefresh(_ action: UIAction) {
            Task {
                refreshControl?.beginRefreshing()
                await refreshAction?()
                refreshControl?.endRefreshing()
            }
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
