//
//  HomeView.swift
//  SentimentAnalysis
//
//  Created by 間口秀人 on 2022/12/28.
//

import SwiftUI
import Alamofire
import CoreData


struct HomeView: View {
    @Environment(\.managedObjectContext) var moc
    @State var tweetText = ApiFetcher()
    @State private var isActive = false
    @State private var url = ""
    @State private var isLoding = false
    @State private var showingAlert = false
    @State private var showingResultView = false
    @FocusState var focus:Bool

    // 画面遷移フラグ
    @State var animationFlag = false
    
    var body: some View {
        VStack {
            if isLoding == false {
                VStack {
                    Image("感情分析アイコン")
                        .resizable()
                        .frame(width: 200, height: 200)
                        .padding(.bottom, 20)
                        .shadow(radius: 3)
                    ZStack(alignment: .topLeading) {
                        TextEditor(text: $url)
                            .padding(.horizontal, -4)
                            .frame(width: 300, height: 200)
                            .padding(.leading ,5)
                            .overlay(RoundedRectangle(cornerRadius: 5).stroke(.gray, lineWidth: 1))
                            .focused(self.$focus)
                        
                        
                        if url.isEmpty {
                            Text("URLを入力") .foregroundColor(Color(uiColor: .placeholderText))
                                .allowsHitTesting(false)
                                .padding(5)
                        }
                    }
                    Button("分析スタート") {
                        withAnimation{
                            let url = url
                            //URLが有効か検査
                            guard formatURL(url: url).count == 3 else{
                                showingAlert = true
                                return
                            }
                            
                            var tweet_id = String(formatURL(url: url)[2])
                            tweet_id = formatID(id: tweet_id)
                            tweetText.tweet_id = tweet_id
                            isLoding = true
                            Task.detached{
                                do {
                                    try await tweetTextFunc(tweetText: tweetText)
                                } catch {
                                    print(error.localizedDescription)
                                    return
                                }
                            }
                        }
                    }
                    
                    .buttonStyle(AnimationButtonStyle())
                    .padding(.top, 5)
                    Spacer()
                }
                .onTapGesture {
                            self.focus = false
                        }
                .alert("""
                        URLが正しく入力されて
                        いません
                        """, isPresented: $showingAlert, actions: {},message: {
                    Text("")
                })
                
                
            } else {
                VStack{
                    ProgressView()
                    Text("大量のリプライや引用があるツイートの場合、分析に時間がかかることがあります。")
                        .multilineTextAlignment(.center)
                        .opacity(0.7)
                        .padding(50)
                }
            }
        }
        .navigationDestination(isPresented: $showingResultView){
            ResultView(
                tweets: $tweetText.tweets,
                originalText: $tweetText.originalText,
                username: $tweetText.username,
                screen_name: $tweetText.screen_name)
            .environment(\.managedObjectContext, self.moc)
        }
    }
    //URLを分割
    func formatURL(url: String) -> [String.SubSequence] {
        guard let url = URL(string: url) else{
            showingAlert = true
            return [""]
        }
        let urlData = url.path.split(separator: "/")
        return urlData
    }
    //?以降の文字列を削除
    func formatID(id: String) -> String {
        var id = id
        let range = /(\?.*)/
        let match = id.firstMatch(of: range)
        if let match {
            id = id.replacingOccurrences(of: match.0, with: "")
        }
        return id
    }
    func tweetTextFunc(tweetText: ApiFetcher) async throws {
        //引数は定数となっているので変数に変換
        tweetText.paramInit()
        tweetText.user_id = String(formatURL(url: url)[0])
        tweetText.search_userInfo()
        tweetText.search_tweet()
        isLoding = false
        showingResultView = true //ここで画面遷移
    }
}
struct AnimationButtonStyle : ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .padding(5)
            .foregroundColor(.white)
            .background(Color("imageColor"))
            .overlay(
                RoundedRectangle(cornerRadius: 5)
                    .stroke(Color("imageColor"), lineWidth: 4)
            )
            .compositingGroup()
            .shadow(radius: 3, x: 5, y: 5)
            .scaleEffect(configuration.isPressed ? 0.9 : 1.0)
            .animation(.linear, value: configuration.isPressed)
    }
}

struct HomeView_Previews: PreviewProvider {
    static var previews: some View {
        HomeView()
        
    }
}
