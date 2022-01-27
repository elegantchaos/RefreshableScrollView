//
//  ContentView.swift
//  Example
//
//  Created by Sam Deane on 27/01/2022.
//

import RefreshableScrollView
import SwiftUI

struct ContentView: View {
    struct TestItem: Identifiable {
        let id = UUID().uuidString
    }
    
    let testItems = (1..<100).map({ _ in TestItem() })
    
    var body: some View {
        VStack {
            RefreshableScrollView {
                VStack {
                    ForEach(testItems) { item in
                        Text(item.id)
                    }
                }
            }
            .refreshable {
                print("refreshing")
                sleep(2)
                print("done")
            }

            List {
                ForEach(1..<100) { item in
                    Text("\(item)")
                }
            }
            .listStyle(.plain)
            .refreshable {
                print("refreshing")
                sleep(2)
                print("done")
            }
        }
            .padding()
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
