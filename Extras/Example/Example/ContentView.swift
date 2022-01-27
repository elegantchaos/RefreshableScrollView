//
//  ContentView.swift
//  Example
//
//  Created by Sam Deane on 27/01/2022.
//

import RefreshableScrollView
import SwiftUI

struct TestItem: Identifiable {
    let id = UUID().uuidString
}

let testItems = (1..<100).map({ _ in TestItem() })

struct ContentView: View {
    
    
    var body: some View {
        TabView {
            RefreshableExample()
                .tabItem {
                    Text("Custom")
                }
            
            ListExample()
                .tabItem {
                    Text("List")
                }
        }
        .padding()
    }
}

struct RefreshableExample: View {
    @State var text = ""
    
    var body: some View {
        NavigationView {
            RefreshableScrollView(travelHeight: 80, activityOffset: 240) {
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
            .searchable(text: $text)
            .navigationTitle("Custom View")
        }
    }
}

struct ListExample: View {
    var body: some View
    {
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
}
struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
