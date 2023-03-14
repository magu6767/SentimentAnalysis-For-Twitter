//
//  ResultView.swift
//  SentimentAnalysis
//
//  Created by 間口秀人 on 2022/12/27.
//

import SwiftUI
import NaturalLanguage
import CoreML
import Charts

//グラフの型
struct ChartEntry: Identifiable {
    var title: String
    var value: Double
    var color: Color
    var id = UUID()
}
//リザルト画面
struct ResultView: View {
    @Environment(\.managedObjectContext) var moc
    @Binding var tweets: [String]
    @Binding var originalText: String
    @Binding var username: String
    @Binding var screen_name: String
    @State var positiveCount = 0
    @State var negativeCount = 0
    @State var neutralCount = 0
    @State var showingSheet = false

    
    
    var body: some View {
        //グラフの属性設定
        let data: [ChartEntry] = [
            .init(title: "ポジティブ", value: Double(positiveCount), color: .green),
            .init(title: "ネガティブ", value: Double(negativeCount), color: .red),
            .init(title: "中立", value: Double(neutralCount), color: .gray)
        ]
        
        VStack {
            Image("感情分析アイコン")
                .resizable()
                .frame(width: 50, height: 50)
            Text(username + "(@" + screen_name + ")さん")
                .padding()
            Text(originalText)
                .padding()
            Text(String(tweets.count) + "件の反応")
                .padding()
            Text("ポジティブ：" + String(positiveCount))
            Text("ネガティブ：" + String(negativeCount))
            Text("中立：" + String(neutralCount))
            Chart(data) { dataPoint in
                BarMark(
                    x: .value("Value", dataPoint.value),
                    y: .value("Category", dataPoint.title)
                )
                .foregroundStyle(dataPoint.color)
            }
            .frame(width: 300, height: 200)
            .padding()
            HStack {
                Image(systemName: "questionmark.circle")
                    .foregroundColor(.blue)
                Button("データ数が少ない場合"){
                    showingSheet = true
                }
                .sheet(isPresented: $showingSheet, content: {    LowDataView()})
            }
            .opacity(0.7)
            
        }
        .onAppear{
            //渡されたツイートを分析
            textClassifier(texts: tweets)
            //保存
            saveData()
        }
        
    }
    
    //テキストの分析
    func textClassifier(texts: [String])  {
        do {
            print(texts.count)
            let mlModel = try SentimentClassifier(configuration: MLModelConfiguration()).model
            let sentimentPredictor = try NLModel(mlModel: mlModel)
            for text in texts {
                let label: String =  sentimentPredictor.predictedLabel(for: text) ?? ""
                switch label {
                case "positive":
                    positiveCount += 1
                case "negative":
                    negativeCount += 1
                default:
                    neutralCount += 1
                }
            }
        } catch {
            return
        }
        
    }
    //データ保存
    func saveData()  {
        let data = SentimentAnalysis.AnalysisData(context: moc)
        data.id = UUID()
        data.name = username
        data.text = originalText
        data.screen_name = screen_name
        data.positiveCount = Int64(positiveCount)
        data.negativeCount = Int64(negativeCount)
        data.neutralCount = Int64(neutralCount)
        //日付作成
        let f = DateFormatter()
        f.timeStyle = .short
        f.dateStyle = .short
        f.locale = Locale(identifier: "ja_JP")
        data.createdAt = f.string(from: Date())
        try? moc.save()
    }
}

struct ResultView_Previews: PreviewProvider {
    static var previews: some View {
        ResultView(tweets : Binding.constant([""]),
                   originalText: Binding.constant(""),
                   username: Binding.constant(""),
                   screen_name: Binding.constant("")
        )
    }
}
