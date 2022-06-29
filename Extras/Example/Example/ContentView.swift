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
            NuExample()
                .tabItem {
                    Label("Nu", systemImage: "tag")
                }

            NormalExample()
                .tabItem {
                    Label("Normal", systemImage: "tag")
                }
            
            NavigationExample()
                .tabItem {
                    Label("Navigation", systemImage: "tag")
                }

            SearchableNavigationExample()
                .tabItem {
                    Label("Searchable", systemImage: "tag")
                }

            ListExample()
                .tabItem {
                    Label("List", systemImage: "tag")
                }
        }
        .padding()
    }
}

@Sendable func dummyRefreshTask() async {
    print("refreshing")
    try? await Task.sleep(nanoseconds: 5000000000)
    print("done")
}

struct NuExample: View {
    var body: some View {
        NativeRefreshableScrollView {
            LazyVStack(alignment: .center) {
                ForEach(testItems) { item in
                    Text(item.id)
                }
            }
            .frame(maxWidth: .infinity)
        }
        .refreshable(action: dummyRefreshTask)
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
        .refreshable(action: dummyRefreshTask)
    }
}

struct NavigationExample: View {
    var body: some View {
        NavigationView {
            NativeRefreshableScrollView {
                LazyVStack {
                    ForEach(testItems) { item in
                        Text(item.id)
                    }
                }
            }
            .refreshable(action: dummyRefreshTask)
            .navigationTitle("Custom View")
            .foregroundColor(.primary)
            .navigationBarTitleDisplayMode(.large)
            .navigationViewStyle(.columns)
        }
    }
}


struct SearchableNavigationExample: View {
    @State var text = ""
    
    var body: some View {
        NavigationView {
            RefreshableScrollView(mode: .searchableNavigation) {
                LazyVStack {
                    ForEach(testItems) { item in
                        Text(item.id)
                    }
                }
            }
            .refreshable(action: dummyRefreshTask)
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
        .refreshable(action: dummyRefreshTask)
    }
}
struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
