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

struct NuExample: View {
    var body: some View {
        HStack {
            Spacer()

            NuRefreshableScrollView() {
                LazyVStack {
                    ForEach(testItems) { item in
                        Text(item.id)
                    }
                }
            }
            .refreshable {
                print("refreshing")
                try? await Task.sleep(nanoseconds: 2000000000)
                print("done")
            }

            Spacer()
        }
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
            try? await Task.sleep(nanoseconds: 2000000000)
            print("done")
        }
    }
}

struct NavigationExample: View {
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
