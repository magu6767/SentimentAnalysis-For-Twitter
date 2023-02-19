//
//  TweetModel.swift
//  SentimentAnalysis
//
//  Created by 間口秀人 on 2022/12/24.
//

import SwiftUI

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

struct ResultModel: Codable {
    var positiveCount: Int
    var negativeCount: Int
    var username: String
    var screen_name: String
    var originalText: String
}

struct ChartEntry: Identifiable {
    var title: String
    var value: Double
    var color: Color
    var id: String {
        return title + String(value)
    }
}
