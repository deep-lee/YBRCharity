//
//  MoreInfoViewController.swift
//  YBRCharity
//
//  Created by 李冬 on 16/3/4.
//  Copyright © 2016年 李冬. All rights reserved.
//

import UIKit
import SwiftyFORM

class MoreInfoViewController: FormViewController {

	var project: Project?

	let donateButton = ButtonFormItem()

	override func viewDidLoad() {
		super.viewDidLoad()

		// Do any additional setup after loading the view.
	}

	override func populate(builder: FormBuilder) {
		self.configureButton()
		builder.navigationTitle = "更多信息"
		builder.toolbarMode = .Simple

		builder += donateButton

		builder += SectionHeaderTitleFormItem().title("受助人信息")
		builder += recipientName()
		builder += recipientId()
		builder += recipientAddress()

		builder += SectionHeaderTitleFormItem().title("项目进展信息")
		builder += amountForHelp()
		builder += amountHasDonated()
	}

	func configureButton() {
		donateButton.title("我要帮助")
		donateButton.action = { [weak self] in
		}
	}

	func recipientName() -> StaticTextFormItem {
		let string = self.project?.recipient_real_name
		return StaticTextFormItem().title("受助人姓名").value(string!)
	}

	func recipientId() -> StaticTextFormItem {
		let string = self.project?.recipient_real_id
		return StaticTextFormItem().title("受助人身份证号").value(string!)
	}

	func recipientAddress() -> StaticTextFormItem {
		let string = self.project?.recipient_address
		return StaticTextFormItem().title("受助人地址").value(string!)
	}

	func amountForHelp() -> StaticTextFormItem {
		let string = String(self.project!.amount_for_help!)
		return StaticTextFormItem().title("求助金融").value(string)
	}

	func amountHasDonated() -> StaticTextFormItem {
		let string = String(self.project!.has_donated_amount!)
		return StaticTextFormItem().title("已募集金融").value(string)
	}

	override func didReceiveMemoryWarning() {
		super.didReceiveMemoryWarning()
		// Dispose of any resources that can be recreated.
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
