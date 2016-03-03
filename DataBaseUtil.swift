//
//  DataBaseUtil.swift
//  YBRCharity
//
//  Created by 李冬 on 16/3/1.
//  Copyright © 2016年 李冬. All rights reserved.
//

import Foundation
import CoreData

class DataBaseUtil: NSObject {

	/**
	 判断当前是否有用户登录

	 - returns: true－>已登录
	 */
	static func hasUserLogin() -> Bool {

		let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate

		let context = appDelegate.managedObjectContext

		let fetchRequest = NSFetchRequest(entityName: "User")
		var fetchResult: [AnyObject]!

		do {
			try fetchResult = context.executeFetchRequest(fetchRequest)
		} catch {
		}

		if fetchResult.count > 0 {
			return true
		} else {
			return false
		}
	}

	/**
	 判断当前登录的用户是否已经进行了身份认证

	 - returns: true->已认证
	 */
	static func hasUserAuthentication() -> Bool {
		var flag = false

		let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate

		let context = appDelegate.managedObjectContext

		let fetchRequest = NSFetchRequest(entityName: "User")
		var fetchResult: [AnyObject]!

		do {
			try fetchResult = context.executeFetchRequest(fetchRequest)
		} catch {
		}

		if fetchResult.count > 0 {
			let obj: NSManagedObject = fetchResult![0] as! NSManagedObject
			flag = obj.valueForKey("authentication") as! Bool
		}

		return flag
	}

	/**
	 更新登录用户信息

	 - parameter user: 用户
	 */
	static func updateLocalUser(user: MyUser) {
		// 首先判断是否已经登录了用户，如果有就删除
		deleteLocalData()

		// 插入新的数据
		insertNewData(user)
	}

	static func insertNewData(user: MyUser) {
		let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate // 获取appdel
		let context = appDelegate.managedObjectContext // 获取存储的上下文

		let entity = NSEntityDescription.entityForName("User", inManagedObjectContext: context)
		let userDB = NSManagedObject(entity: entity!, insertIntoManagedObjectContext: context) // 这里如果做了转型的话其实也可以直接类似类的属性进行赋值一样
		userDB.setValue(user.id, forKey: "id")
		userDB.setValue(user.account, forKey: "account")
		userDB.setValue(user.account_type, forKey: "account_type")
		userDB.setValue(user.nick, forKey: "nick")
		userDB.setValue(user.authentication, forKey: "authentication")
		userDB.setValue(user.real_name, forKey: "real_name")
		userDB.setValue(user.real_id, forKey: "real_id")
		userDB.setValue(user.phone_num, forKey: "phone_num")

		do {

			try context.save()
		} catch {
		}
	}

	static func deleteLocalData() {

		let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate // 获取appdel
		let context = appDelegate.managedObjectContext // 获取存储的上下文

		let description = NSEntityDescription.entityForName("User", inManagedObjectContext: context)

		let request = NSFetchRequest()

		request.includesPropertyValues = false
		request.entity = description

		var data: [AnyObject]!

		do {
			data = try context.executeFetchRequest(request)
		} catch {
		}

		if let result = data {

			for obj in result {
				context.deleteObject(obj as! NSManagedObject)

				do {

					try context.save()
				} catch {
				}
			}
		}
	}

	static func getCurrentUserId() -> Int {

		var userId = -1

		let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate

		let context = appDelegate.managedObjectContext

		let fetchRequest = NSFetchRequest(entityName: "User")
		var fetchResult: [AnyObject]!

		do {
			try fetchResult = context.executeFetchRequest(fetchRequest)
		} catch {
		}

		if fetchResult.count > 0 {
			let obj: NSManagedObject = fetchResult![0] as! NSManagedObject
			userId = obj.valueForKey("id") as! Int
			print("获取到的用户ID为：")
			print(userId)
		}

		return userId
	}

	static func getCurrentUser() -> MyUser {

		let user = MyUser()

		let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate

		let context = appDelegate.managedObjectContext

		let fetchRequest = NSFetchRequest(entityName: "User")
		var fetchResult: [AnyObject]!

		do {
			try fetchResult = context.executeFetchRequest(fetchRequest)
		} catch {
		}

		if fetchResult.count > 0 {
			let obj: NSManagedObject = fetchResult![0] as! NSManagedObject
			user.id = obj.valueForKey("id") as? Int
			user.account_type = obj.valueForKey("account_type") as? Int
			user.account = obj.valueForKey("account") as? String
			user.nick = obj.valueForKey("nick") as? String
			user.header = obj.valueForKey("header") as? String
			user.authentication = obj.valueForKey("authentication") as? Bool
			user.real_name = obj.valueForKey("real_name") as? String
			user.real_id = obj.valueForKey("real_id") as? String
		}

		return user
	}
}
