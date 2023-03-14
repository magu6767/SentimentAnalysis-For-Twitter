//
//  ResultHistoryView.swift
//  SentimentAnalysis
//
//  Created by 間口秀人 on 2023/01/03.
//

import SwiftUI
import Charts

//履歴の各データ
struct ResultHistoryView: View {
    @ObservedObject var data: AnalysisData
    
    var body: some View {
        VStack {
            Image("感情分析アイコン")
                .resizable()
                .frame(width: 50, height: 50)
            Text(data.name! + "(@" + data.screen_name! + ")さん")
                .padding()
            Text(data.text!)
                .padding()
            Text(String(data.positiveCount + data.negativeCount + data.neutralCount) + "件の反応")
                .padding()
            Text("ポジティブ：" + String(data.positiveCount))
            Text("ネガティブ：" + String(data.negativeCount))
            Text("中立：" + String(data.neutralCount))
            //Viewを分割
            ChartView(positiveCount: Double(data.positiveCount), negativeCount: Double(data.negativeCount), neutralCount: Double(data.neutralCount))
        }
    }
}

struct ChartView: View {
    @State var positiveCount: Double
    @State var negativeCount: Double
    @State var neutralCount: Double

    var body: some View {
        let data: [ChartEntry] = [
            .init(title: "ポジティブ", value: positiveCount, color: .green),
            .init(title: "ネガティブ", value: negativeCount, color: .red),
            .init(title: "中立", value: neutralCount, color: .gray)
        ]
        Chart(data) { dataPoint in
            BarMark(
                x: .value("Value", dataPoint.value),
                y: .value("Category", dataPoint.title)
            )
            .foregroundStyle(dataPoint.color)
        }
        .frame(width: 300, height: 200)
        .padding()
    }
}

struct ResultHistoryView_Previews: PreviewProvider {
    static var previews: some View {
        ResultHistoryView(data: AnalysisData())
    }
}
