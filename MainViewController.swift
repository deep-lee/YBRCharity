//
//  MainViewController.swift
//  YBRCharity
//
//  Created by 李冬 on 16/1/28.
//  Copyright © 2016年 李冬. All rights reserved.
//

import UIKit
import TrelloNavigation
import SwiftyDrop
import Alamofire
import SwiftyJSON
import CircleMenu
import SDWebImage

extension UIColor {
	static func color(red: Int, green: Int, blue: Int, alpha: Float) -> UIColor {
		return UIColor(
			colorLiteralRed: Float(1.0) / Float(255.0) * Float(red),
			green: Float(1.0) / Float(255.0) * Float(green),
			blue: Float(1.0) / Float(255.0) * Float(blue),
			alpha: alpha)
	}
}

class MainViewController: UIViewController {

	var trelloView: TrelloView?

	private let reuseIdentifier = "TrelloListCell"

	let ScreenWidth = UIScreen.mainScreen().bounds.size.width

	let ScreenHeight = UIScreen.mainScreen().bounds.size.height

	var profileViewController: ProfileViewController!

	// 登录弹出视图
	var popup: AFPopupView!

	var button: CircleMenu!

	let items: [(icon: String, color: UIColor)] = [
		("icon-home", UIColor(red: 0.19, green: 0.57, blue: 1, alpha: 1)),
		("icon-search", UIColor(red: 0.22, green: 0.74, blue: 0, alpha: 1)),
	]

	override func viewDidLoad() {
		super.viewDidLoad()

		// Do any additional setup after loading the view.

		NSNotificationCenter.defaultCenter().addObserver(self, selector: "hidePopup:", name: "HideAFPopup", object: nil)

		// 发送验证码
		NSNotificationCenter.defaultCenter().addObserver(self, selector: "sendConfirmCode:", name: "SendConfirmCode", object: nil)

		// 验证验证码
		NSNotificationCenter.defaultCenter().addObserver(self, selector: "checkConfirmCode:", name: "ConfirmCode", object: nil)
		NSNotificationCenter.defaultCenter().addObserver(self, selector: "showTipMessage:", name: "DropMessage", object: nil)

		view.backgroundColor = TrelloDeepBlue
		self.trelloView = TrelloView(frame: CGRectMake(0, 0, ScreenWidth, ScreenHeight), tabCount: 4, trelloTabCells: { () -> [UIView] in
			return [
				TrelloListTabViewModel.tabView("医疗", level: 3),
				TrelloListTabViewModel.tabView("支教", level: 4),
				TrelloListTabViewModel.tabView("贫困", level: 2),
				TrelloListTabViewModel.tabView("应急", level: 1),
			]
		})

		if let trelloView = trelloView {
			view.addSubviews(trelloView)
			trelloView.delegate = self
			trelloView.dataSource = self

			var i = 0
			for tableView in trelloView.tableViews {
				guard let tableView = tableView as? TrelloListTableView<TrelloListCellItem> else { return }
				tableView.registerClass(TrelloListTableViewCell.self, forCellReuseIdentifier: reuseIdentifier)
				tableView.tab = trelloView.tabs[i]
				tableView.listItems = [TrelloListCellItem]()
				i++
			}
		}

		self.profileViewController = ProfileViewController()
		self.view.addSubview(profileViewController.view)
		self.profileViewController.setBgRGB(0x000000)
		self.profileViewController.view.frame = self.view.bounds
		self.profileViewController.delegate = self

		self.button = CircleMenu(
			frame: CGRect(x: UIScreen.mainScreen().bounds.size.width - 60, y: UIScreen.mainScreen().bounds.size.height - 180, width: 40, height: 40),
			normalIcon: "icon-menu",
			selectedIcon: "icon-close",
			buttonsCount: 2,
			duration: 0.5,
			distance: 80)
		button.backgroundColor = UIColor.lightGrayColor()
		button.delegate = self
		button.layer.cornerRadius = button.frame.size.width / 2.0
		view.addSubview(button)

		// 请求项目数据
		self.initTrelloViewTableViewDataArray()
	}

	var didSetupConstraints = false

	override func viewWillAppear(animated: Bool) {
		super.viewWillAppear(animated)
		navigationController?.navigationBar.translucent = false
		navigationController?.navigationBar.barTintColor = TrelloBlue
		_ = navigationController?.navigationBar.subviews.first?.subviews.map { view in
			if view is UIImageView {
				view.hidden = true
			}
		}
	}

	override func didReceiveMemoryWarning() {
		super.didReceiveMemoryWarning()
		// Dispose of any resources that can be recreated.
	}

	@IBAction func showProfileView(sender: AnyObject) {

		// 判断用户是否已经登录了
		if DataBaseUtil.hasUserLogin() {
			// 动画弹出
			self.profileViewController.showHideSidebar()
			self.profileViewController.playShowInAnimation()

			// 是否现实了
			if self.profileViewController.isSidebarShown {
				// 执行圆圈菜单显示动画
				self.hideCircleMenu()
			} else {
				self.showCircleMenu()
			}

			return
		}

		// 没有用户登录的话就弹出登录视图
		let loginViewController = self.storyboard?.instantiateViewControllerWithIdentifier("LoginViewController") as! LoginViewController
		self.popup = AFPopupView.popupWithView(loginViewController.view)
		self.popup.show()
	}

	/**
	 显示圆圈菜单按钮
	 */
	func showCircleMenu() {
		UIView.animateWithDuration(1.0, animations: { () -> Void in
			self.button.alpha = 1
			}, completion: nil)
	}

	/**
	 隐藏圆圈菜单按钮
	 */
	func hideCircleMenu() {
		UIView.animateWithDuration(1.0, animations: { () -> Void in
			self.button.alpha = 0
			}, completion: nil)
	}

// 隐藏
	func hidePopup(notification: NSNotification) {
		self.popup.hide()
	}

// 显示提醒
	func showTipMessage(notification: NSNotification) {
		let message = notification.userInfo!["message"] as! String
		Drop.down(message, state: DropState.Default)
	}

	func showTipMessageWithString(message: String) {
		Drop.down(message, state: DropState.Default)
	}

// 发送验证码
	func sendConfirmCode(notification: NSNotification) {
		let phoneNum = notification.userInfo!["phoneNum"] as! String
		SMSSDK.getVerificationCodeByMethod(SMSGetCodeMethodSMS, phoneNumber: phoneNum, zone: "86", customIdentifier: nil) { (error) -> Void in
			if let error = error {
				print(error)
				self.showTipMessageWithString("获取验证码失败，请重试")
			} else {
				self.showTipMessageWithString("获取验证码成功")
				self.popup.updateLoginBtnTitle("登录")
			}
		}
	}

// 对验证码进行验证
	func checkConfirmCode(notification: NSNotification) {
		SVProgressHUD.show()
		let phoneNum = notification.userInfo!["phoneNum"] as! String
		let confirmCode = notification.userInfo!["confirmCode"] as! String
		SMSSDK.commitVerificationCode(confirmCode, phoneNumber: phoneNum, zone: "86") { (error) -> Void in
			if let error = error {
				print(error)
				self.showTipMessageWithString("验证失败，请重试")
				SVProgressHUD.dismiss()
			} else {
				self.showTipMessageWithString("验证成功")
				// self.popup.updateLoginBtnTitle("登录")
				// self.popup.hide()

				// 请求Login.php
				self.requestLogin(phoneNum, account_type: 0)
			}
		}
	}

	func requestLogin(account: String, account_type: Int) {
		let paras = [
			"account": account,
			"account_type": account_type,
			"nick": account,
			"header": AppDelegate.DEFAULT_HEADER
		]
		Alamofire.request(.GET, AppDelegate.URL_PREFEX + "login.php", parameters: paras as? [String: AnyObject])
			.responseJSON { response in

				// 返回的不为空
				if let value = response.result.value {
					// 解析json
					let json = JSON(value)
					let code = json["code"].intValue

					print(json)

					// 获取成功
					if code == 200 {
						// 解析信息
						let data = json["data"]
						let user = MyUser()
						user.id = data["id"].intValue
						user.account_type = data["account_type"].intValue
						user.account = data["account"].stringValue
						user.nick = data["nick"].stringValue
						user.header = data["header"].stringValue
						user.authentication = data["authentication"].boolValue
						user.real_name = data["real_name"].stringValue
						user.real_id = data["real_id"].stringValue
						user.phone_num = data["phone_num"].stringValue

						// 插入本地数据库
						DataBaseUtil.updateLocalUser(user)
						self.showTipMessageWithString("登录成功")
						self.popup.hide()
					} else { // 数据库操作失败
						Drop.down("登录失败，请重试", state: DropState.Error)
					}
				} else {
					Drop.down("登录失败，请检查网络连接", state: DropState.Error)
				}
				SVProgressHUD.dismiss()
		}
	}
}

extension MainViewController: UITableViewDelegate, UITableViewDataSource, ProfileViewControllerDelegate, CircleMenuDelegate {
	func numberOfSectionsInTableView(tableView: UITableView) -> Int {
		return 1
	}

	func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		guard let tableView = tableView as? TrelloListTableView<TrelloListCellItem>,
			count = tableView.listItems?.count
		else { return 0 }
		return count
	}

	func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
		return 60.0
	}

	func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
		guard let tableView = tableView as? TrelloListTableView<TrelloListCellItem> else { fatalError("TableView False") }
		guard let item = tableView.listItems?[indexPath.row] else { fatalError("No Data") }

		return (item.image != nil) ? 220.0 : 80.0
	}

	func tableView(tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
		let view = TrelloListSectionView(frame: CGRect(x: 0, y: 0, width: tableView.bounds.width, height: 60.0))
		guard let tableView = tableView as? TrelloListTableView<TrelloListCellItem> else { return view }
		view.title = tableView.tab ?? ""
		return view
	}

	func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
		guard let tableView = tableView as? TrelloListTableView<TrelloListCellItem> else { fatalError("TableView False") }
		guard let item = tableView.listItems?[indexPath.row] else { fatalError("No Data") }
		print("更新")
		guard let cell = tableView.dequeueReusableCellWithIdentifier(reuseIdentifier, forIndexPath: indexPath) as? TrelloListTableViewCell else {
			let trelloListCell = TrelloListCellViewModel.initCell(item, reuseIdentifier: reuseIdentifier) as! TrelloListTableViewCell
			trelloListCell.detailImageView.sd_setImageWithURL(NSURL(string: item.cover_image_url!)) { (image, error, type, url) -> Void in
				trelloListCell.detailImageView.image = image
			}
			return trelloListCell
		}
		let trelloListCell = TrelloListCellViewModel.updateCell(item, cell: cell) as! TrelloListTableViewCell
		trelloListCell.detailImageView.sd_setImageWithURL(NSURL(string: item.cover_image_url!)) { (image, error, type, url) -> Void in
			trelloListCell.detailImageView.image = image
		}
		return trelloListCell
	}

	// 点击事件
	func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
		var trelloListItem: TrelloListCellItem?
		for index in 0 ..< self.trelloView!.tableViews.count {
			if tableView == self.trelloView!.tableViews[index] {
				trelloListItem = (tableView as? TrelloListTableView<TrelloListCellItem>)?.listItems![indexPath.row]
			}
		}

		// 进入到对应的界面
		let projectDetailsViewController = self.storyboard?.instantiateViewControllerWithIdentifier("ProjectDetailsViewController") as! ProjectDetailsViewController
		projectDetailsViewController.projectId = trelloListItem?.projectId
		self.navigationController?.pushViewController(projectDetailsViewController, animated: true)
		tableView.deselectRowAtIndexPath(indexPath, animated: true)
	}

	func profileViewContrllerHeaderTaped() {
		let selfViewController = self.storyboard?.instantiateViewControllerWithIdentifier("SelfViewController") as! SelfViewController
		self.navigationController?.pushViewController(selfViewController, animated: true)
	}

	func recordBtnClicked() {
		let recordViewController = self.storyboard?.instantiateViewControllerWithIdentifier("RecordViewController") as! RecordViewController
		self.navigationController?.pushViewController(recordViewController, animated: true)
	}

	func circleMenu(circleMenu: CircleMenu, willDisplay button: CircleMenuButton, atIndex: Int) {
		button.backgroundColor = items[atIndex].color
		button.setImage(UIImage(imageLiteral: items[atIndex].icon), forState: .Normal)

		// set highlited image
		let highlightedImage = UIImage(imageLiteral: items[atIndex].icon).imageWithRenderingMode(.AlwaysTemplate)
		button.setImage(highlightedImage, forState: .Highlighted)
		button.tintColor = UIColor.init(colorLiteralRed: 0, green: 0, blue: 0, alpha: 0.3)
	}

	func circleMenu(circleMenu: CircleMenu, buttonWillSelected button: CircleMenuButton, atIndex: Int) {
		print("button will selected: \(atIndex)")
	}

	/**
	 点击了菜单按钮

	 - parameter circleMenu:
	 - parameter button:
	 - parameter atIndex:
	 */
	func circleMenu(circleMenu: CircleMenu, buttonDidSelected button: CircleMenuButton, atIndex: Int) {
		if atIndex == 0 { // 发起项目
			let launchProjectViewController = self.storyboard?.instantiateViewControllerWithIdentifier("LaunchProjectViewController") as! LaunchProjectViewController
			self.navigationController?.pushViewController(launchProjectViewController, animated: true)
		}
	}

	/**
	 请求数据，更新tableview的dataarray

	 - returns: 无
	 */
	func initTrelloViewTableViewDataArray() {
		// 发起请求
		Alamofire.request(.GET, AppDelegate.URL_PREFEX + "query_all_project.php")
			.responseJSON { response in

				// 返回的不为空
				if let value = response.result.value {
					// 解析json
					let json = JSON(value)
					let code = json["code"].intValue

					print(json)

					// 获取成功
					if code == 200 {
						// 分析数据
						let data = json["data"].arrayValue
						for dataItem in data { // 遍历
							print("李冬")
							// let image = UIImage(data: NSData(contentsOfURL: NSURL(string: dataItem["cover_image"].stringValue)!)!) // 封面照片
							let gifLoading = UIImage.gifWithName("icon-loading")
							let content = dataItem["project_title"].stringValue // 项目标题
							var type: TrelloCellItemType?
							switch (rand() % 3) {
							case 0:
								type = TrelloCellItemType.Green
							case 1:
								type = TrelloCellItemType.Orange
							case 2:
								type = TrelloCellItemType.Red
							case 3:
								type = TrelloCellItemType.Yellow
							default:
								break
							}
							let projectId = dataItem["id"].intValue
							let launcherId = dataItem["launcher_id"].intValue

							let projectType = dataItem["project_type"].intValue

							var trelloListItem = TrelloListCellItem(image: gifLoading, content: content, type: type!, projectId: projectId, launcherId: launcherId)
							trelloListItem.cover_image_url = dataItem["cover_image"].stringValue

							// 加入到数据数组中
							(self.trelloView?.tableViews[projectType] as? TrelloListTableView<TrelloListCellItem>)?.listItems?.append(trelloListItem)
						}

						// 刷新TableView
						for tableview in(self.trelloView?.tableViews)! {
							tableview.reloadData()
						}
					} else { // 数据库操作失败
						Drop.down("获取数据失败，请重试", state: DropState.Error)
					}
				} else { // 网络连接问题
					Drop.down("获取数据失败，请检查网络连接", state: DropState.Error)
				}
		}
	}
}
