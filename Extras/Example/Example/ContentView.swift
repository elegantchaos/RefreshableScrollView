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
            NormalExample()
                .tabItem {
                    Text("Normal")
                }
            
            NavigationExample()
                .tabItem {
                    Text("Navigation")
                }
                            
            ListExample()
                .tabItem {
                    Text("List")
                }
        }
        .padding()
    }
}

struct NormalExample: View {
    var body: some View {
        RefreshableScrollView() {
            LazyVStack {
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
    }
}

struct NavigationExample: View {
    @State var text = ""
    
    var body: some View {
        NavigationView {
            RefreshableScrollView(mode: .navigation) {
                LazyVStack {
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
            .foregroundColor(.primary)
            .navigationBarTitleDisplayMode(.large)
            .navigationViewStyle(.columns)
        }
    }
}
struct ListExample: View {
    var body: some View
    {
        List {
            ForEach(testItems) { item in
                Text("\(item.id)")
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
