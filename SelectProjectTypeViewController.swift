//
//  SelectProjectTypeViewController.swift
//  YBRCharity
//
//  Created by 李冬 on 16/1/29.
//  Copyright © 2016年 李冬. All rights reserved.
//

import UIKit
import SwiftyFORM

struct OptionRow {
    let title: String
    let identifier: Int
    
    init(_ title: String, _ identifier: Int) {
        self.title = title
        self.identifier = identifier
    }
}

class MyOptionForm {
    let optionRows: [OptionRow]
    
    init(optionRows: [OptionRow]) {
        self.optionRows = optionRows
    }
    
    func populate(builder: FormBuilder) {
        builder.navigationTitle = "选择"
        
        for optionRow: OptionRow in optionRows {
            let option = OptionRowFormItem()
            option.title(optionRow.title)
            builder.append(option)
        }
    }
}

class SelectProjectTypeViewController: FormViewController, SelectOptionDelegate {
    
    var xmyform: MyOptionForm?
    
    let dismissCommand: CommandProtocol
    
    init(dismissCommand: CommandProtocol) {
        self.dismissCommand = dismissCommand
        super.init()
    }

    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func populate(builder: FormBuilder) {
        let optionRows: [OptionRow] = [
            OptionRow("医疗", 0),
            OptionRow("支教", 1),
            OptionRow("贫困", 2),
            OptionRow("应急", 2),
        ]
        
        let myform = MyOptionForm(optionRows: optionRows)
        
        myform.populate(builder)
        xmyform = myform
    }
    
    func form_willSelectOption(option: OptionRowFormItem) {
        print("select option \(option)")
        dismissCommand.execute(self, returnObject: option)
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
