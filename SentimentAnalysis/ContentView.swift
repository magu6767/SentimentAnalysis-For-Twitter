//
//  ContentView.swift
//  SentimentAnalysis
//
//  Created by 間口秀人 on 2022/12/24.
//

import SwiftUI

struct ContentView: View {
    @State private var isActive = false
    @State private var url = ""
    @State var isShowingSheet = false
    
    @Environment(\.managedObjectContext) var moc
    
    var body: some View {
        TabView{
            HomeView()
                .tabItem{
                    Image(systemName: "house")
                }
            HistoryTableView()
                .tabItem{
                    Image(systemName: "clock")
                }
        }
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                Button {
                    isShowingSheet = true
                } label: {
                    Image(systemName: "questionmark.circle")
                        .resizable()
                        .frame(width: 30, height: 30)
                }
                .foregroundColor(Color("imageColor"))
                .sheet(isPresented: $isShowingSheet, content: { DescriptionView() })
            }
        }
        .accentColor(Color("imageColor"))
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
