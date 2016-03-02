//
//  ChildViewController.swift
//  YBRCharity
//
//  Created by 李冬 on 16/2/5.
//  Copyright © 2016年 李冬. All rights reserved.
//

import UIKit
import XLPagerTabStrip

class SeekHelpChildViewController : UIViewController, IndicatorInfoProvider {

    var tableView : UITableView!
    var calendarMenuView : JTCalendarMenuView!
    var calendarContentView : JTVerticalCalendarView!
    var calendarManager : JTCalendarManager!
    
    var _eventsByDate : [String : [NSDate]]!
    var _dateSelected : NSDate!
    
    var itemInfo: IndicatorInfo = "View"
    
    init(itemInfo: IndicatorInfo) {
        self.itemInfo = itemInfo
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        self.initCalendarView()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func initCalendarView() {
        
        self.calendarMenuView = JTCalendarMenuView(frame: CGRectMake(0, 0, UIScreen.mainScreen().bounds.size.width, 50))
        self.calendarContentView = JTVerticalCalendarView(frame: CGRectMake(0, 70, UIScreen.mainScreen().bounds.size.width, 300))
        self.calendarManager = JTCalendarManager()
        self.calendarManager.delegate = self
        self.createRandomEvents()
        self.view.addSubview(self.calendarMenuView)
        self.view.addSubview(self.calendarContentView)
        self.calendarManager.menuView = self.calendarMenuView
        self.calendarManager.contentView = self.calendarContentView
        self.calendarManager.setDate(NSDate())
        
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */
    
    // MARK: - IndicatorInfoProvider
    
    func indicatorInfoForPagerTabStrip(pagerTabStripController: PagerTabStripViewController) -> IndicatorInfo {
        return itemInfo
    }
    
    
    func haveEventForDay(date : NSDate) -> Bool{
        let key = self.dateFormatter().stringFromDate(date)
        if (_eventsByDate[key] != nil) && (_eventsByDate[key]?.count > 0) {
            return true
        }
        
        return false
    }
    
    func dateFormatter() -> NSDateFormatter {
        let dateFormatter = NSDateFormatter()
        dateFormatter.dateFormat = "dd-MM-yyyy"
        
        return dateFormatter
    }
    
    func createRandomEvents() {
        self._eventsByDate = [String : [NSDate]]()
        
        for _ in 0..<30 {
            let randomDate = NSDate(timeInterval: Double(Int(rand()) % (3600 * 24 * 60)), sinceDate: NSDate())
            let key = self.dateFormatter().stringFromDate(randomDate)
            if (_eventsByDate[key] == nil) {
                _eventsByDate[key] = [NSDate]()
            }
            
            _eventsByDate[key]?.append(randomDate)
        }
    }
}

extension SeekHelpChildViewController : JTCalendarDelegate {
    func calendar(calendar: JTCalendarManager!, prepareDayView dayView: UIView!) {
        
        let calendarDayView = (dayView as! JTCalendarDayView)
        calendarDayView.hidden = false
        
        if calendarDayView.isFromAnotherMonth {
            dayView.hidden = true
        } else if calendar.dateHelper.date(NSDate(), isTheSameDayThan: calendarDayView.date) {   // // Today
            calendarDayView.circleView.hidden = false
            calendarDayView.circleView.backgroundColor = UIColor(red: 0.208, green: 0.667, blue: 0.878, alpha: 1)
            calendarDayView.dotView.backgroundColor = UIColor.whiteColor()
            calendarDayView.textLabel.textColor = UIColor.whiteColor()
        } else if (self._dateSelected != nil) && calendar.dateHelper.date(self._dateSelected, isTheSameDayThan: calendarDayView.date) {  // // Selected date
            calendarDayView.circleView.hidden = false
            calendarDayView.circleView.backgroundColor = UIColor.redColor()
            calendarDayView.dotView.backgroundColor = UIColor.whiteColor()
            calendarDayView.textLabel.textColor = UIColor.whiteColor()
        } else {
            calendarDayView.circleView.hidden = true
            calendarDayView.dotView.backgroundColor = UIColor.redColor()
            calendarDayView.textLabel.textColor = UIColor.blackColor()
        }
        
        if self.haveEventForDay(calendarDayView.date) {
            calendarDayView.dotView.hidden = false
        } else {
            calendarDayView.dotView.hidden = true
        }
        
    }
    
    func calendar(calendar: JTCalendarManager!, didTouchDayView dayView: UIView!) {
        
        let calendarDayView = (dayView as! JTCalendarDayView)
        
        _dateSelected = calendarDayView.date
        
        // Animation for the circleView
        calendarDayView.circleView.transform = CGAffineTransformScale(CGAffineTransformIdentity, 0.1, 0.1);
        
        UIView.transitionWithView(calendarDayView, duration: 0.3, options: UIViewAnimationOptions.CurveEaseIn, animations: { () -> Void in
            calendarDayView.circleView.transform = CGAffineTransformIdentity
            calendar.reload()
            }, completion: nil)
        
        if !calendar.dateHelper.date(calendarContentView.date, isTheSameMonthThan: calendarDayView.date) {
            if calendarContentView.date.compare(calendarDayView.date) == NSComparisonResult.OrderedAscending {
                calendarContentView.loadNextPageWithAnimation()
            } else {
                calendarContentView.loadPreviousPageWithAnimation()
            }
        }
    }
    
    func calendarBuildMenuItemView(calendar: JTCalendarManager!) -> UIView! {
        let label = UILabel()
        label.textAlignment = NSTextAlignment.Center
        label.font = UIFont(name: "Avenir-Medium", size: 25)
        label.textColor = UIColor(red: 0.208, green: 0.667, blue: 0.878, alpha: 1)
        
        return label
    }
    
    func calendar(calendar: JTCalendarManager!, prepareMenuItemView menuItemView: UIView!, date: NSDate!) {
        let dateFormatter = NSDateFormatter()
        dateFormatter.dateFormat = "MMMM yyyy"
        dateFormatter.locale = calendar.dateHelper.calendar().locale
        dateFormatter.timeZone = calendar.dateHelper.calendar().timeZone
        
        (menuItemView as! UILabel).text = dateFormatter.stringFromDate(date)
    }
    
    func calendarBuildWeekDayView(calendar: JTCalendarManager!) -> UIView! {
        let view = JTCalendarWeekDayView()
        
        for label in view.dayViews {
            (label as! UILabel).textColor = UIColor.blackColor()
            (label as! UILabel).font = UIFont(name: "Avenir-Light", size: 14)
        }
        
        return view
    }
    
    func calendarBuildDayView(calendar: JTCalendarManager!) -> UIView! {
        let view = JTCalendarDayView()
        view.textLabel.font = UIFont(name: "Avenir-Light", size: 13)
        view.circleRatio = 0.8
        view.dotRatio = 1.0 / 0.9
        
        return view
    }
}
