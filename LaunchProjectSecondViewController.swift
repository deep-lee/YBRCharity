//
//  LaunchProjectSecondViewController.swift
//  YBRCharity
//
//  Created by 李冬 on 16/1/29.
//  Copyright © 2016年 李冬. All rights reserved.
//

import UIKit
import SwiftyFORM
import SwiftyDrop
import Alamofire
import SwiftyJSON

class LaunchProjectSecondViewController: FormViewController {

	var projectTitle: String?
	var projectDetails: String?

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

	lazy var userIdentyId: TextFieldFormItem = {
		let instance = TextFieldFormItem()
		instance.title("身份证号").placeholder("请输入受助人的身份证号")
		instance.keyboardType = .ASCIICapable
		instance.autocorrectionType = .No
		// instance.validate(CountSpecification.exactly(13), message: "请输入13位身份证号")
		return instance
	}()

	lazy var realName: TextFieldFormItem = {
		let instance = TextFieldFormItem()
		instance.title("真实姓名").placeholder("请输入受助人的真实姓名")
		instance.keyboardType = .ASCIICapable
		instance.autocorrectionType = .No
		// instance.validate(CountSpecification.exactly(13), message: "请输入13位身份证号")
		return instance
	}()

	lazy var livePlace: TextFieldFormItem = {
		let instance = TextFieldFormItem()
		instance.title("现居地址").placeholder("请输入受助人的现居地址")
		instance.keyboardType = .ASCIICapable
		instance.autocorrectionType = .No
		return instance
	}()

	lazy var projectType: OptionPickerFormItem = {
		let instance = OptionPickerFormItem()
		instance.title("项目类型").placeholder("请选择")
		instance.append("医疗", identifier: "0").append("支教", identifier: "1").append("贫困", identifier: "2").append("应急", identifier: "3'")
		instance.selectOptionWithTitle("医疗")
		return instance
	}()

	lazy var wantedMoneyNum: TextFieldFormItem = {
		let instance = TextFieldFormItem()
		instance.title("求助金额").placeholder("元")
		instance.keyboardType = .NumberPad
		instance.autocorrectionType = .No
		return instance
	}()

	lazy var accountBank: TextFieldFormItem = {
		let instance = TextFieldFormItem()
		instance.title("开户银行").placeholder("请输入开户银行")
		instance.keyboardType = .ASCIICapable
		instance.autocorrectionType = .No
		return instance
	}()

	lazy var accountNum: TextFieldFormItem = {
		let instance = TextFieldFormItem()
		instance.title("卡号").placeholder("请输入银行卡号")
		instance.keyboardType = .NumberPad
		// instance.validate(CountSpecification.exactly(19), message: "请输入19位银行卡号")
		instance.autocorrectionType = .No
		return instance
	}()

	func installSubmitButton() {
		self.navigationItem.rightBarButtonItem = UIBarButtonItem(title: "提交", style: .Plain, target: self, action: "submitAction:")
		self.navigationItem.rightBarButtonItem?.tintColor = UIColor(red: 1, green: 1, blue: 1, alpha: 1)
	}

	func submitAction(sender: AnyObject) {
		if userIdentyId.value.isEmpty || realName.value.isEmpty || livePlace.value.isEmpty || wantedMoneyNum.value.isEmpty || accountBank.value.isEmpty || accountNum.value.isEmpty {
			Drop.down("请将信息填写完成", state: DropState.Warning)
			return
		}

		SVProgressHUD.show()

		// 请求页面，发起项目
		let paras: [String: NSObject] = [
			"launcher_id": DataBaseUtil.getCurrentUserId(),
			"launch_time": NSDate(),
			"project_title": self.projectTitle!,
			"details_page": self.projectDetails!,
			"recipient_real_id": userIdentyId.value,
			"recipient_real_name": realName.value,
			"recipient_address": livePlace.value,
			"project_type": (projectType.selected?.identifier)!,
			"amount_for_help": wantedMoneyNum.value,
			"depositary_bank": accountBank.value,
			"bank_account": accountNum.value
		]
        
        print(paras)

		// 发起请求
		Alamofire.request(.GET, AppDelegate.URL_PREFEX + "launch_project.php", parameters: paras)
			.responseJSON { response in

				// 返回的不为空
				if let value = response.result.value {
					// 解析json
					let json = JSON(value)
					let code = json["code"].intValue

					print(json)

					// 获取成功
					if code == 200 {
						// 发起成功
						Drop.down("发起项目成功", state: DropState.Success)
						// 返回到根
						self.navigationController?.popToRootViewControllerAnimated(true)
					} else { // 发起失败，数据库问题
						Drop.down("发起项目失败，请重试", state: DropState.Error)
					}
				} else { // 发起失败
					Drop.down("发起项目失败，请检查网络连接", state: DropState.Error)
				}

				SVProgressHUD.dismiss()
		}
	}
}
