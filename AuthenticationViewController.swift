//
//  AuthenticationViewController.swift
//  YBRCharity
//
//  Created by 李冬 on 16/2/24.
//  Copyright © 2016年 李冬. All rights reserved.
//

import UIKit
import SwiftyFORM

class AuthenticationViewController: FormViewController {

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
        builder.navigationTitle = "身份认证"
        builder.toolbarMode = .Simple
        
        builder += SectionHeaderTitleFormItem().title("身份证照片上传")
        let loaderItem0 = CustomFormItem()
        loaderItem0.createCell = {
            return try PhotoCell.createCell()
        }
        builder += loaderItem0
     
        let loaderItem1 = CustomFormItem()
        loaderItem1.createCell = {
            return try PhotoCell.createCell()
        }
        builder += loaderItem1
        
        builder += SectionHeaderTitleFormItem().title("个人基本信息")
        builder += realName
        builder += realId
        builder += phoneNum
    }
    
    lazy var realName : TextFieldFormItem = {
        let instance = TextFieldFormItem()
        instance.title("真实姓名").placeholder("请输入真实姓名")
        instance.keyboardType = .ASCIICapable
        instance.autocorrectionType = .No
        return instance
    }()
    
    lazy var realId : TextFieldFormItem = {
        let instance = TextFieldFormItem()
        instance.title("身份证号").placeholder("请输入身份证号")
        instance.keyboardType = .ASCIICapable
        instance.autocorrectionType = .No
        instance.validate(CountSpecification.exactly(13), message: "请输入13位身份证号")
        return instance
    }()
    
    lazy var phoneNum : TextFieldFormItem = {
        let instance = TextFieldFormItem()
        instance.title("联系方式").placeholder("请输入手机号码")
        instance.keyboardType = .ASCIICapable
        instance.autocorrectionType = .No
        instance.validate(CountSpecification.exactly(11), message: "请输入11位手机号码")
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
