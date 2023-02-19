//
//  Entity+CoreDataProperties.swift
//  
//
//  Created by 間口秀人 on 2022/12/28.
//
//

import Foundation
import CoreData


extension Entity {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Entity> {
        return NSFetchRequest<Entity>(entityName: "Entity")
    }

    @NSManaged public var username: String?
    @NSManaged public var screen_name: String?
    @NSManaged public var originalText: String?
    @NSManaged public var negativeCount: Int32
    @NSManaged public var positiveCount: Int32
    @NSManaged public var createdAt: Date?

}
extension Entity : Identifiable {
    
    public var stringcreatedAt: String { dateFomatter(date: createdAt ?? Date()) }
    public var stringnegativeCount: String(negativeCount)
    public var stringpositiveCount: String(positiveCount)

    
    func dateFomatter(date: Date) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy/MM/dd"
        dateFormatter.locale = Locale(identifier: "en_US_POSIX")
        dateFormatter.timeZone = TimeZone(identifier: "Asia/Tokyo")

        return dateFormatter.string(from: date)
    }
}
