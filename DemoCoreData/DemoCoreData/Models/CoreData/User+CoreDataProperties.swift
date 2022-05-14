//
//  User+CoreDataProperties.swift
//  DemoCoreData
//
//  Created by Nguyen Quang Huy on 11/05/2022.
//

import Foundation
import CoreData


extension User {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<User> {
        return NSFetchRequest<User>(entityName: "User")
    }

    @NSManaged public var age: Int16
    @NSManaged public var gender: Bool
    @NSManaged public var name: String?

}
