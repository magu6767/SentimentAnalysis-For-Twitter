//
//  DescriptionView.swift
//  SentimentAnalysis
//
//  Created by 間口秀人 on 2023/01/11.
//

import SwiftUI

//説明画面
struct DescriptionView: View {
    var body: some View {
        ScrollView(showsIndicators: true){
            VStack{
                Group{
                    Text("""
当アプリをダウンロードいただき、ありがとうございます。
このアプリでは、ツイートに対する反応を分析し、ポジティブな反応とネガティブな反応がどのくらいあるのかを表示することができます。
""")
                    .multilineTextAlignment(.leading)
                        .padding()
                    Text("【使い方】")
                        .font(.title)
                    Text("【１】Twitterで分析したいツイートを開き、右下の共有ボタンをタップ")
                        .multilineTextAlignment(.center)
                        .padding(10)
                    Text("※分析できるツイートは投稿日から7日以内のものに限ります")
                        .padding(.horizontal, 10)
                    Image("ツイッター画像１")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 300, height: 400)
                    Text("【２】「リンクをコピー」をタップ")
                        .multilineTextAlignment(.center)
                        .padding()
                    Text("※ブラウザ版をご利用の方は、ツイート画面のURLをコピーしてもOKです")
                        .padding(.horizontal, 10)
                    Image("ツイッター画像２")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 300, height: 400)
                }
                Group{
                    Text("【３】コピーしたリンクをこのアプリに貼り付け、「分析スタート」をタップ")
                        .multilineTextAlignment(.center)
                    Image("アプリ画像１")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 300, height: 400)
                    Text("【４】分析が終わると、集計データが表示されます")
                        .multilineTextAlignment(.center)
                    Image("アプリ画像２")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 300, height: 400)
                    Text("【５】分析履歴は、右下の時計マークから見ることができます")
                        .multilineTextAlignment(.center)
                    Image("アプリ画像３")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 300, height: 400)
                    Text("【６】スライドして履歴を削除できます")
                        .multilineTextAlignment(.center)
                    Image("アプリ画像４")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 300, height: 400)
                }
            }
            
        }
    }
}

struct DescriptionView_Previews: PreviewProvider {
    static var previews: some View {
        DescriptionView()
    }
}
