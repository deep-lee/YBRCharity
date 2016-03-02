//
//  LoginViewController.swift
//  YBRCharity
//
//  Created by 李冬 on 16/2/29.
//  Copyright © 2016年 李冬. All rights reserved.
//

import UIKit

class LoginViewController: UIViewController {
    
    @IBOutlet var usernameTextFiels: UITextField!
    @IBOutlet var confirmCodeTextField: UITextField!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        print("DidLoad")
        // showProgressHHD()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
}

