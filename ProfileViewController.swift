//
//  ProfileViewController.swift
//  YBRCharity
//
//  Created by 李冬 on 16/1/30.
//  Copyright © 2016年 李冬. All rights reserved.
//

import UIKit

protocol ProfileViewControllerDelegate {
    func profileViewContrllerHeaderTaped()
    func recordBtnClicked()
}

class ProfileViewController: LLBlurSidebar {
    
    var headerImageView : UIImageView!
    var nameLabel : UILabel!
    var msgBtn : UIButton!
    var foucsBtn : UIButton!
    var recordBtn : UIButton!
    var settingBtn : UIButton!
    
    let duration : NSTimeInterval = 1
    
    var delegate : ProfileViewControllerDelegate?

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        let nib = NSBundle.mainBundle().loadNibNamed("SlideView", owner: self, options: nil)
        let slideView = nib[0] as! UIView
        slideView.frame = CGRectMake(0, 0, UIScreen.mainScreen().bounds.size.width, UIScreen.mainScreen().bounds.size.height)
        self.contentView.addSubview(slideView)
        
        headerImageView = slideView.viewWithTag(1) as! UIImageView
        nameLabel = slideView.viewWithTag(2) as! UILabel
        msgBtn = slideView.viewWithTag(3) as! UIButton
        foucsBtn = slideView.viewWithTag(4) as! UIButton
        recordBtn = slideView.viewWithTag(5) as! UIButton
        settingBtn = slideView.viewWithTag(6) as! UIButton
        
        msgBtn.alpha = 0
        foucsBtn.alpha = 0
        recordBtn.alpha = 0
        settingBtn.alpha = 0
        settingBtn.transform = CGAffineTransformMakeScale(0.1, 0.1)
        
        let headerTap = UITapGestureRecognizer(target: self, action: "headerTaped:")
        self.headerImageView.userInteractionEnabled = true
        self.headerImageView.addGestureRecognizer(headerTap)
        
        recordBtn.addTarget(self, action: "recordBtnAction:", forControlEvents: UIControlEvents.TouchUpInside)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        msgBtn.center.x += (UIScreen.mainScreen().bounds.width + msgBtn.frame.size.width) / 2
        foucsBtn.center.x += (UIScreen.mainScreen().bounds.width + msgBtn.frame.size.width) / 2
        recordBtn.center.x += (UIScreen.mainScreen().bounds.width + msgBtn.frame.size.width) / 2
    }
    
    func playShowInAnimation() {
        
        if !self.isSidebarShown {
            UIView.animateWithDuration(self.duration / 2, delay: 0, options: [], animations: { () -> Void in
                // self.msgBtn.center.x += (UIScreen.mainScreen().bounds.width + self.msgBtn.frame.size.width) / 2
                self.msgBtn.alpha = 0
                }, completion: nil)
            
            UIView.animateWithDuration(self.duration / 2, delay: 0.1, options: [], animations: { () -> Void in
                // self.foucsBtn.center.x += (UIScreen.mainScreen().bounds.width + self.msgBtn.frame.size.width) / 2
                self.foucsBtn.alpha = 0
                }, completion: nil)
            
            UIView.animateWithDuration(self.duration / 2, delay: 0.2, options: [], animations: { () -> Void in
                // self.recordBtn.center.x += (UIScreen.mainScreen().bounds.width + self.msgBtn.frame.size.width) / 2
                self.recordBtn.alpha = 0
                }, completion: nil)
            
            UIView.animateWithDuration(self.duration, delay: 0, options: [], animations: { () -> Void in
                self.settingBtn.transform = CGAffineTransformMakeScale(0.1, 0.1)
                self.settingBtn.alpha = 0
                }, completion: nil)
            
        } else {
            UIView.animateWithDuration(self.duration, delay: 0, options: [], animations: { () -> Void in
                self.msgBtn.center.x -= (UIScreen.mainScreen().bounds.width + self.msgBtn.frame.size.width) / 2
                self.msgBtn.alpha = 1
                }, completion: nil)
            
            UIView.animateWithDuration(self.duration, delay: 0.5, options: [], animations: { () -> Void in
                self.foucsBtn.center.x -= (UIScreen.mainScreen().bounds.width + self.msgBtn.frame.size.width) / 2
                self.foucsBtn.alpha = 1
                }, completion: nil)
            
            UIView.animateWithDuration(self.duration, delay: 1, options: [], animations: { () -> Void in
                self.recordBtn.center.x -= (UIScreen.mainScreen().bounds.width + self.msgBtn.frame.size.width) / 2
                self.recordBtn.alpha = 1
                }, completion: nil)
            
            UIView.animateWithDuration(self.duration, delay: 0.8, options: [], animations: { () -> Void in
                self.settingBtn.transform = CGAffineTransformIdentity
                self.settingBtn.alpha = 1
                }, completion: nil)
        }
        
    }
    
    func headerTaped(tap : UITapGestureRecognizer) {
        delegate?.profileViewContrllerHeaderTaped()
    }
    
    func recordBtnAction(sender : AnyObject) {
        delegate?.recordBtnClicked()
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
