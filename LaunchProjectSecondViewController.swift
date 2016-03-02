//
//  LaunchProjectSecondViewController.swift
//  YBRCharity
//
//  Created by 李冬 on 16/1/29.
//  Copyright © 2016年 李冬. All rights reserved.
//

import UIKit
import SwiftyFORM

class LaunchProjectSecondViewController: FormViewController {

	override func viewDidLoad() {
		super.viewDidLoad()

		// Do any additional setup after loading the view.
		self.installSubmitButton()
	}

	override func didReceiveMemoryWarning() {
		super.didReceiveMemoryWarning()
		// Dispose of any resources that can be recreated.
	}

	override func populate(builder: FormBuilder) {
		builder.navigationTitle = "发起求助"
		builder.toolbarMode = .Simple
		builder += SectionHeaderTitleFormItem().title("受助人资料")
		builder += userIdentyId
		builder += realName
		builder += livePlace
		builder.alignLeft([userIdentyId, realName, livePlace])

		builder += SectionHeaderTitleFormItem().title("求助信息")
		builder += projectType
		builder += wantedMoneyNum

		builder += SectionHeaderTitleFormItem().title("账户信息")
		builder += accountBank
		builder += accountNum
		builder.alignLeft([accountBank, accountNum])
	}

	lazy var userIdentyId : TextFieldFormItem = {
		let instance = TextFieldFormItem()
		instance.title("身份证号").placeholder("请输入受助人的身份证号")
		instance.keyboardType = .ASCIICapable
		instance.autocorrectionType = .No
		instance.validate(CountSpecification.exactly(13), message: "请输入13位身份证号")
		return instance
	}()

	lazy var realName : TextFieldFormItem = {
		let instance = TextFieldFormItem()
		instance.title("真实姓名").placeholder("请输入受助人的真实姓名")
		instance.keyboardType = .ASCIICapable
		instance.autocorrectionType = .No
		// instance.validate(CountSpecification.exactly(13), message: "请输入13位身份证号")
		return instance
	}()

	lazy var livePlace : TextFieldFormItem = {
		let instance = TextFieldFormItem()
		instance.title("现居地址").placeholder("请输入受助人的现居地址")
		instance.keyboardType = .ASCIICapable
		instance.autocorrectionType = .No
		return instance
	}()

	lazy var projectType : ViewControllerFormItem = {
		let instance = ViewControllerFormItem()
		instance.title("项目类型").placeholder("请选择")
		instance.createViewController = { (dismissCommand: CommandProtocol) in
			let vc = SelectProjectTypeViewController(dismissCommand: dismissCommand)
			return vc
		}
		instance.willPopViewController = { (context: ViewControllerFormItemPopContext) in
			if let x = context.returnedObject as? SwiftyFORM.OptionRowFormItem {
				context.cell.detailTextLabel?.text = x.title
			} else {
				context.cell.detailTextLabel?.text = nil
			}
		}
		return instance
	}()

	lazy var wantedMoneyNum : TextFieldFormItem = {
		let instance = TextFieldFormItem()
		instance.title("求助金额").placeholder("元")
		instance.keyboardType = .NumberPad
		instance.autocorrectionType = .No
		return instance
	}()

	lazy var accountBank : TextFieldFormItem = {
		let instance = TextFieldFormItem()
		instance.title("开户银行").placeholder("请输入开户银行")
		instance.keyboardType = .ASCIICapable
		instance.autocorrectionType = .No
		return instance
	}()

	lazy var accountNum : TextFieldFormItem = {
		let instance = TextFieldFormItem()
		instance.title("卡号").placeholder("请输入银行卡号")
		instance.keyboardType = .NumberPad
		instance.validate(CountSpecification.exactly(19), message: "请输入19位银行卡号")
		instance.autocorrectionType = .No
		return instance
	}()

	func installSubmitButton() {
		self.navigationItem.rightBarButtonItem = UIBarButtonItem(title: "提交", style: .Plain, target: self, action: "submitAction:")
		self.navigationItem.rightBarButtonItem?.tintColor = UIColor(red: 1, green: 1, blue: 1, alpha: 1)
	}

	func submitAction(sender : AnyObject) {
	}

	/*
	 // MARK: - Navigation

	 // In a storyboard-based application, you will often want to do a little preparation before navigation
	 override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
	 // Get the new view controller using segue.destinationViewController.
	 // Pass the selected object to the new view controller.
	 }
	 */
}
