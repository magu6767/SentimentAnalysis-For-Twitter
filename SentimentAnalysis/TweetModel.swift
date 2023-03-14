//
//  TweetModel.swift
//  SentimentAnalysis
//
//  Created by 間口秀人 on 2022/12/24.
//

import SwiftUI

//JSON<->クラス変換用のモデル
struct tweetModel: Codable {
    var id: Int64
    var text: String
    var in_reply_to_status_id_str: String?
    var is_quote_status: Bool
}

struct tweetModelArray: Codable {
    var statuses: [tweetModel]
}

struct userModel: Codable {
    var text: String
    var user: User
}
struct User: Codable {
    var name: String
    var screen_name: String
}
