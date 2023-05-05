//
//  HistoryView.swift
//  SentimentAnalysis
//
//  Created by 間口秀人 on 2022/12/28.
//

import SwiftUI

//履歴画面
struct HistoryTableView: View {
    @FetchRequest(sortDescriptors: [NSSortDescriptor(key: "createdAt", ascending: false)]) var AnalysisData: FetchedResults<AnalysisData>
    @Environment(\.managedObjectContext) var moc
    @State var count = 0
   
    var body: some View {
        VStack {
            List{
                ForEach(AnalysisData, id: \.self) { data in
                    NavigationLink(destination: ResultHistoryView(data: data)) {
                        VStack(alignment: .leading) {
                            Text(data.createdAt ?? "Unknown")
                            Text(data.name ?? "Unknown")
                        }
                    }
                }
                .onDelete(perform: rowRemove)
            }
            
        }
    }
    func rowRemove(offsets: IndexSet) {
        for index in offsets {
            let putRow = AnalysisData[index]
            moc.delete(putRow)
        }
        do {
            try moc.save()
        } catch {
            let nsError = error as NSError
            fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
        }
    }
}
struct HistoryView_Previews: PreviewProvider {
    static var previews: some View {
        HistoryTableView()
    }
}
