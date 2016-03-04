//
//  TrelloData.swift
//  TrelloNavigation
//
//  Created by 宋宋 on 15/11/12.
//  Copyright © 2015年 Qing. All rights reserved.
//

import UIKit
import TrelloNavigation

struct TrelloData {
	static let data: [[TrelloListCellItem]] = [
		[
			TrelloListCellItem(image: nil, content: "Login and Register function", type: .Green, projectId: 1, launcherId: 1),
			TrelloListCellItem(image: nil, content: "Upload and downLoad pictures", type: .Yellow, projectId: 1, launcherId: 1),
			TrelloListCellItem(image: UIImage(named: "testImage3"), content: "Have a pleasant afternoon", type: .Red, projectId: 1, launcherId: 1)
		],
		[
			TrelloListCellItem(image: nil, content: "This is a Trello Navigation Demo", type: .Green, projectId: 1, launcherId: 1),
			TrelloListCellItem(image: nil, content: "Some of it have been organized", type: .Yellow, projectId: 1, launcherId: 1),
			TrelloListCellItem(image: nil, content: "Use it as a Library", type: .Red, projectId: 1, launcherId: 1),
			TrelloListCellItem(image: UIImage(named: "testImage3"), content: "Displayed content is random created", type: .Orange, projectId: 1, launcherId: 1)
		],
		[
			TrelloListCellItem(image: nil, content: "Make the interface more beautiful", type: .Green, projectId: 1, launcherId: 1),
			TrelloListCellItem(image: UIImage(named: "testImage2"), content: "This feels awesome", type: .Yellow, projectId: 1, launcherId: 1)
		],
		[
			TrelloListCellItem(image: nil, content: "Test this first demo", type: .Green, projectId: 1, launcherId: 1),
			TrelloListCellItem(image: nil, content: "Push project to github", type: .Yellow, projectId: 1, launcherId: 1),
			TrelloListCellItem(image: UIImage(named: "testImage1"), content: "Have a pleasant afternoon", type: .Red, projectId: 1, launcherId: 1)
		],
		[
			TrelloListCellItem(image: UIImage(named: "testImage3"), content: "Have a pleasant afternoon", type: .Red, projectId: 1, launcherId: 1),
			TrelloListCellItem(image: nil, content: "Login and Register function", type: .Green, projectId: 1, launcherId: 1),
			TrelloListCellItem(image: nil, content: "Upload and downLoad pictures", type: .Yellow, projectId: 1, launcherId: 1)
		]
	]
}