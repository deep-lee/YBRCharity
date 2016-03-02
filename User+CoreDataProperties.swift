//
//  User+CoreDataProperties.swift
//  YBRCharity
//
//  Created by 李冬 on 16/3/1.
//  Copyright © 2016年 李冬. All rights reserved.
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

import Foundation
import CoreData

extension User {

    @NSManaged var id: NSNumber?
    @NSManaged var account_type: NSNumber?
    @NSManaged var account: String?
    @NSManaged var nick: String?
    @NSManaged var header: String?
    @NSManaged var authentication: NSNumber?
    @NSManaged var real_name: String?
    @NSManaged var real_id: String?
    @NSManaged var phone_num: String?

}
