//
//  RecordViewController.swift
//  YBRCharity
//
//  Created by 李冬 on 16/2/4.
//  Copyright © 2016年 李冬. All rights reserved.
//

import UIKit
import XLPagerTabStrip

class RecordViewController: ButtonBarPagerTabStripViewController {

	let blueInstagramColor = UIColor(red: 37 / 255.0, green: 111 / 255.0, blue: 206 / 255.0, alpha: 1.0)

	override func viewDidLoad() {
		// change selected bar color
		settings.style.buttonBarBackgroundColor = .whiteColor()
		settings.style.buttonBarItemBackgroundColor = .whiteColor()
		settings.style.selectedBarBackgroundColor = blueInstagramColor
		settings.style.buttonBarItemFont = .boldSystemFontOfSize(14)
		settings.style.selectedBarHeight = 2.0
		settings.style.buttonBarMinimumLineSpacing = 0
		settings.style.buttonBarMinimumInteritemSpacing = 0
		settings.style.buttonBarItemTitleColor = .blackColor()
		settings.style.buttonBarItemsShouldFillAvailiableWidth = true
		settings.style.buttonBarLeftContentInset = 0
		settings.style.buttonBarRightContentInset = 0

		changeCurrentIndexProgressive = { [weak self](oldCell: ButtonBarViewCell?, newCell: ButtonBarViewCell?, progressPercentage: CGFloat, changeCurrentIndex: Bool, animated: Bool) -> Void in
			guard changeCurrentIndex == true else { return }
			oldCell?.label.textColor = .blackColor()
			newCell?.label.textColor = self?.blueInstagramColor
		}

		super.viewDidLoad()

		// Do any additional setup after loading the view.
		self.title = "我的记录"
	}

	// MARK: - PagerTabStripDataSource

	override func viewControllersForPagerTabStrip(pagerTabStripController: PagerTabStripViewController) -> [UIViewController] {
		let seekHelpRecord = SeekHelpChildViewController(itemInfo: "求助记录")
		let donationRecord = DonationChildViewController(itemInfo: "捐款记录")
		let withdrawRecord = WithdrawChildViewController(itemInfo: "提款记录")
		return [seekHelpRecord, donationRecord, withdrawRecord]
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
