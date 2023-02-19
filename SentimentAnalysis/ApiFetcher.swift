//
//  ApiFetcher.swift
//  SentimentAnalysis
//
//  Created by 間口秀人 on 2022/12/24.
//

import Foundation
import Alamofire

class ApiFetcher{
    let headers: HTTPHeaders = ["Authorization": "Bearer AAAAAAAAAAAAAAAAAAAAAMBRkAEAAAAAsdDiFAAifP0VmpsLJ6JIiIKbHhM%3DCXA2zj8gBTXhtI7AJTFRcktHepRHlSgGGQr3rXy26hShFCD5FV"]
    let count: Int = 100
    let range: Int = 100
    var cnt: Int = 0
    var reply_cnt: Int = 0
    var quote_cnt: Int = 0
    var max_id: Int64 = Int64.max
    var flag = true
    var user_id = String()
    var tweet_id = String()
    var originalText = String()
    var username = String()
    var screen_name = String()
    var tweets = [String]()

    
    func paramInit() {
        cnt = 0
        reply_cnt = 0
        quote_cnt = 0
        max_id = Int64.max
        flag = true
        tweets = [String]()
    }
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
    
    func search_tweet() {
        let user_idcopy = user_id
        user_id += "%20-RT%20conversation_id:" + tweet_id //URLに空欄があるとクラッシュするので%20で埋める
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
                            if tweet.in_reply_to_status_id_str == self.tweet_id {
                                DispatchQueue.main.async {
                                    self.tweets.append(self.formatText(text: tweet.text, user_id: user_idcopy))
                                    self.reply_cnt += 1
                                }
                            }
                        }
                        self.max_id = (jsonData.statuses.last?.id ?? 0) - 1
                    } catch {
                        print(error.localizedDescription)
                        return
                    }
                    semaphore.signal()
                }
            semaphore.wait()
        }
        
        max_id = Int64.max
        tweet_id += "%20-RT"
        flag = true
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
                            if tweet.is_quote_status == true {
                                DispatchQueue.main.async {
                                    self.tweets.append(self.formatText(text: tweet.text, user_id: user_idcopy))
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
    func formatText(text: String, user_id: String) -> String {
        var newtext = text.replacingOccurrences(of: "@" + user_id, with: "")
        let range = /(http.*)/ // https://swiftregex.com/
        let match = newtext.firstMatch(of: range)
        if let match {
            newtext = newtext.replacingOccurrences(of: match.0, with: "")
        }
        return newtext
    }
}
