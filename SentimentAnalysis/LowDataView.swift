//
//  LowDataView.swift
//  SentimentAnalysis
//
//  Created by 間口秀人 on 2023/02/02.
//

import SwiftUI

//得られたツイートがが少なかった場合の案内
struct LowDataView: View {
    var body: some View {
        VStack {
            Image("感情分析アイコン")
                .resizable()
                .frame(width: 100, height: 100)
                .padding()
            VStack(alignment: .leading){
                Text("データ数が少ない場合、以下のような原因が考えられます。")
                    .padding(10)
                Group{
                    Text("・ツイートに対する反応が少ない")
                        .font(.title2)
                        .fontWeight(.bold)
                    Text("集計対象となるのは、ツイートに対するリプライと引用ツイートです。鍵アカウントからの反応は集計されません。")
                }
                .padding(.horizontal, 10)
                .padding(.bottom, 10)

                Group{
                    Text("・投稿日から7日以上経過しているツイート")
                        .font(.title2)
                        .fontWeight(.bold)
                    Text("分析対象のツイートが投稿日から7日以上経過している場合、集計されるのは7日以内にあった反応のみになります。")
                }
                .padding(.horizontal, 10)
                .padding(.bottom, 10)
                  
            }
        }
    }
}

struct LowDataView_Previews: PreviewProvider {
    static var previews: some View {
        LowDataView()
    }
}
