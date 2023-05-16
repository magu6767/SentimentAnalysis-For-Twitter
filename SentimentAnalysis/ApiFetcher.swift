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
    let obtainedTweetsNumber: Int = 100 //一度の通信で取得できるツイートの上限
    let maxCommunicationCount: Int = 100 //通信回数の上限
    var communicationCount: Int = 0 //通信回数
    var replyCount: Int = 0 //リプライの数
    var quoteCount: Int = 0 //引用の数
    var maxTweetId: Int64 = Int64.max //ツイートIDの上限
    var tweetId = String() //ツイートID
    var userId = String() //スクリーンネーム（"@"以降の文字）
    var screenName = String() //スクリーンネーム（"@"以降の文字）
    var originalText = String() //本文
    var userName = String() //名前
    var tweets = [String]() //取得したツイートを入れる配列
    var loopFlag = true //ループフラグ

    //パラメータの初期化
    func paramInit() {
        communicationCount = 0
        replyCount = 0
        quoteCount = 0
        maxTweetId = Int64.max
        loopFlag = true
        tweets = [String]()
    }
    //入力されたURLからツイート情報を取得
    func searchUserInfo() {
        AF.request("https://api.twitter.com/1.1/statuses/show.json?id=" + tweetId, method: .get, parameters: nil, encoding: JSONEncoding.default, headers: headers)
            .response{ response in
                do {
                    guard let data = response.data else {
                        return
                    }
                    let decoder: JSONDecoder = JSONDecoder()
                    let jsonData = try decoder.decode(userModel.self, from: data)
                    self.originalText = jsonData.text
                    self.userName = jsonData.user.name
                    self.screenName = jsonData.user.screen_name
                } catch {
                    print(error.localizedDescription)
                    return
                }
            }
    }
    //ツイートに対するリプライ、引用を取得
    func searchTweet() {
        let user_idCopy = userId
        userId += "%20-RT%20conversation_id:" + tweetId //RTを除去、スレッドのIDを指定
        //リプライの取得
        while loopFlag == true {
            let url = "https://api.twitter.com/1.1/search/tweets.json?q="+userId+"&count="+String(obtainedTweetsNumber)+"&max_id="+String(maxTweetId)
            guard let request_url = URL(
                string: url
                    ) else {
                        break
                    }
            //同期通信を行うための処理
            let semaphore = DispatchSemaphore(value: 0)
            let queue = DispatchQueue.global(qos: .userInteractive)
            AF.request(request_url, method: .get, parameters: nil,encoding: JSONEncoding.default, headers: headers)
                .response(queue: queue){ response in
                    do {
                        guard let data = response.data else {
                            return
                        }
                        let decoder: JSONDecoder = JSONDecoder()
                        let jsonData = try decoder.decode(tweetModelArray.self, from: data)
                        self.communicationCount += 1
                        if jsonData.statuses.count == 0 || self.communicationCount > self.maxCommunicationCount {
                            self.loopFlag = false
                        }
                        for tweet in jsonData.statuses {
                            //返信先が指定したツイートなら配列に加える（リプライへのリプライは含まない）
                            if tweet.in_reply_to_status_id_str == self.tweetId {
                                DispatchQueue.main.async {
                                    self.tweets.append(self.formatTweetText(text: tweet.text, user_id: user_idCopy))
                                    self.replyCount += 1
                                }
                            }
                        }
                        //max_idを最後に取得したツイートのidに設定
                        self.maxTweetId = (jsonData.statuses.last?.id ?? 0) - 1
                    } catch {
                        print(error.localizedDescription)
                        return
                    }
                    semaphore.signal()
                }
            semaphore.wait()
        }
        
        maxTweetId = Int64.max // maxidを初期化
        tweetId += "%20-RT" //リツイートを除く
        loopFlag = true
        //引用の取得
        while loopFlag == true {
            let url = "https://api.twitter.com/1.1/search/tweets.json?q="+tweetId+" is:quote"+"&count="+String(obtainedTweetsNumber)+"&max_id="+String(maxTweetId)
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
                        self.communicationCount += 1
                        if jsonData.statuses.count == 0 || self.communicationCount > self.maxCommunicationCount {
                            self.loopFlag = false
                        }
                        for tweet in jsonData.statuses {
                                DispatchQueue.main.async {
                                    self.tweets.append(self.formatTweetText(text: tweet.text, user_id: user_idCopy))
                                    self.quoteCount += 1
                                }
                            }
                        self.maxTweetId = (jsonData.statuses.last?.id ?? 0) - 1
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
    func formatTweetText(text: String, user_id: String) -> String {
        var newtext = text.replacingOccurrences(of: "@" + user_id, with: "")
        let range = /(http.*)/
        let match = newtext.firstMatch(of: range)
        if let match {
            newtext = newtext.replacingOccurrences(of: match.0, with: "")
        }
        return newtext
    }
}
