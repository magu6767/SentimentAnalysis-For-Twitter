//
//  ApiFetcher.swift
//  SentimentAnalysis
//
//  Created by 間口秀人 on 2022/12/24.
//

import Foundation
import Alamofire

//API通信の管理
class ApiFetcher{
    let headers: HTTPHeaders = ["Authorization": "自分のBearer Token"] //トークン
    let count: Int = 100 //一度の通信で取得できるツイートの上限
    let range: Int = 100 //通信回数の上限
    var cnt: Int = 0 //通信回数
    var reply_cnt: Int = 0 //リプライの数
    var quote_cnt: Int = 0 //引用の数
    var max_id: Int64 = Int64.max //ツイートIDの上限
    var flag = true //ループフラグ
    var tweet_id = String() //ツイートID
    var user_id = String() //スクリーンネーム（"@"以降の文字）
    var screen_name = String() //スクリーンネーム（"@"以降の文字）
    var originalText = String() //本文
    var username = String() //名前
    var tweets = [String]() //取得したツイートを入れる配列

    //パラメータの初期化
    func paramInit() {
        cnt = 0
        reply_cnt = 0
        quote_cnt = 0
        max_id = Int64.max
        flag = true
        tweets = [String]()
    }
    //入力されたURLからツイート情報を取得
    func search_userInfo() {
        AF.request("https://api.twitter.com/1.1/statuses/show.json?id=" + tweet_id, method: .get, parameters: nil, encoding: JSONEncoding.default, headers: headers)
            .response{ response in
                do {
                    guard let data = response.data else {
                        return
                    }
                    let decoder: JSONDecoder = JSONDecoder()
                    let jsonData = try decoder.decode(userModel.self, from: data)
                    self.originalText = jsonData.text
                    self.username = jsonData.user.name
                    self.screen_name = jsonData.user.screen_name
                } catch {
                    print(error.localizedDescription)
                    return
                }
            }
    }
    //ツイートに対するリプライ、引用を取得
    func search_tweet() {
        let user_idCopy = user_id
        user_id += "%20-RT%20conversation_id:" + tweet_id //RTを除去、スレッドのIDを指定
        //リプライの取得
        while flag == true {
            let url = "https://api.twitter.com/1.1/search/tweets.json?q="+user_id+"&count="+String(count)+"&max_id="+String(max_id)
            guard let request_url = URL(
                string: url
                    ) else {
                        break
                    }
            //同期通信を行うための処理
            let semaphore = DispatchSemaphore(value: 0)
            let queue     = DispatchQueue.global(qos: .userInteractive)
            AF.request(request_url, method: .get, parameters: nil,encoding: JSONEncoding.default, headers: headers)
                .response(queue: queue){ response in
                    do {
                        guard let data = response.data else {
                            return
                        }
                        let decoder: JSONDecoder = JSONDecoder()
                        let jsonData = try decoder.decode(tweetModelArray.self, from: data)
                        self.cnt += 1
                        if jsonData.statuses.count == 0 || self.cnt > self.range {
                            self.flag = false
                        }
                        for tweet in jsonData.statuses {
                            //返信先が指定したツイートなら配列に加える（リプライへのリプライは含まない）
                            if tweet.in_reply_to_status_id_str == self.tweet_id {
                                DispatchQueue.main.async {
                                    self.tweets.append(self.formatText(text: tweet.text, user_id: user_idCopy))
                                    self.reply_cnt += 1
                                }
                            }
                        }
                        //max_idを最後に取得したツイートのidに設定
                        self.max_id = (jsonData.statuses.last?.id ?? 0) - 1
                    } catch {
                        print(error.localizedDescription)
                        return
                    }
                    semaphore.signal()
                }
            semaphore.wait()
        }
        
        max_id = Int64.max // maxidを初期化
        tweet_id += "%20-RT" //リツイートを除く
        flag = true
        //引用の取得
        while flag == true {
            let url = "https://api.twitter.com/1.1/search/tweets.json?q="+tweet_id+"&count="+String(count)+"&max_id="+String(max_id)
            guard let request_url = URL(
                string: url
                    ) else {
                        break
                    }
            //同期通信を行うための処理
            let semaphore = DispatchSemaphore(value: 0)
            let queue     = DispatchQueue.global(qos: .userInteractive)
            AF.request(request_url, method: .get, parameters: nil,encoding: JSONEncoding.default, headers: headers)
                .response(queue: queue){ response in
                    do {
                        guard let data = response.data else {
                            return
                        }
                        let decoder: JSONDecoder = JSONDecoder()
                        let jsonData = try decoder.decode(tweetModelArray.self, from: data)
                        self.cnt += 1
                        if jsonData.statuses.count == 0 || self.cnt > self.range {
                            self.flag = false
                        }
                        for tweet in jsonData.statuses {
                            //引用ステータスがtrueなら配列に加える
                            if tweet.is_quote_status == true {
                                DispatchQueue.main.async {
                                    self.tweets.append(self.formatText(text: tweet.text, user_id: user_idCopy))
                                    self.quote_cnt += 1
                                }
                            }
                        }
                        self.max_id = (jsonData.statuses.last?.id ?? 0) - 1
                    } catch {
                        print(error.localizedDescription)
                    }
                    semaphore.signal()
                }
            semaphore.wait()
        }
        return
    }
    //テキスト中のスクリーンネームとURLを削除
    func formatText(text: String, user_id: String) -> String {
        var newtext = text.replacingOccurrences(of: "@" + user_id, with: "")
        let range = /(http.*)/
        let match = newtext.firstMatch(of: range)
        if let match {
            newtext = newtext.replacingOccurrences(of: match.0, with: "")
        }
        return newtext
    }
}
