//
//  LoadingViewController.swift
//  HistoryBlam
//
//  Created by Brittany Shimshock on 5/1/16.
//  Copyright © 2016 Brittany Shimshock. All rights reserved.
//

import UIKit
import ReachabilitySwift

class LoadingViewController: UIViewController, NetworkManagerDelegate {
    var datetoDisplay : NSDate?
    var currentFacts : [Fact]?
    var timer : NSTimer?
  
    var dateSentToGetFacts : NSDate?
    var previousRandomNumber : Int?

    @IBOutlet weak var label: UILabel!

    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        NetworkManager.sharedManager.networkManagerDelegate = self
        
        let calendar = NSCalendar(identifier: NSCalendarIdentifierGregorian)
        let today = NSDate()
        let formatter = NSDateFormatter()
        formatter.dateFormat = "MM"
        let stringInt = formatter.stringFromDate(today)
        let monthInt = Int(stringInt)
        formatter.dateFormat = "d"
        let dayStringInt = formatter.stringFromDate(today)
        let dayInt = Int(dayStringInt)
        let components = NSDateComponents()
        components.year = 2016
        components.month = monthInt!
        components.day = dayInt!
        
        let date = calendar?.dateFromComponents(components)
        getFacts(date!)
        let myString = "Loading..."
        let font = UIFont.systemFontOfSize(61)
        let myAttributes = [
            NSFontAttributeName : font,
            NSStrokeWidthAttributeName : -2.0,
            NSStrokeColorAttributeName : UIColor.blackColor(),
            NSForegroundColorAttributeName : UIColor(red:0.42, green:0.65, blue:0.91, alpha:1.0)
            
        ]
        let myRandomNumber = Int (arc4random_uniform(UInt32(7)))
        previousRandomNumber = myRandomNumber
        let myAttributedString = NSMutableAttributedString(string: myString, attributes: myAttributes)
        let oneLetterRange = NSMakeRange(myRandomNumber, 1)
        myAttributedString.addAttribute(NSForegroundColorAttributeName, value: UIColor(red:1.00, green:0.69, blue:0.19, alpha:1.0), range: oneLetterRange)
        
        self.label.attributedText = myAttributedString
        
    }
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        timer = NSTimer.scheduledTimerWithTimeInterval(1, target: self, selector: #selector(LoadingViewController.animateLoading), userInfo: nil, repeats: true)
        
        
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    
    
    func animateLoading () {
        let myString = "Loading..."
        let font = UIFont.systemFontOfSize(61)
        let myAttributes = [
            NSFontAttributeName : font,
            NSStrokeWidthAttributeName : -2.0,
            NSStrokeColorAttributeName : UIColor.blackColor(),
            NSForegroundColorAttributeName : UIColor(red:0.42, green:0.65, blue:0.91, alpha:1.0)
                
         ]
        let randomNumber = Int (arc4random_uniform(UInt32(7)))
 
        if previousRandomNumber == randomNumber {
            animateLoading()
        } else {
            previousRandomNumber = randomNumber
            let title = NSMutableAttributedString(string: myString, attributes: myAttributes)
            let oneLetterRange = NSMakeRange(randomNumber, 1)
            title.addAttribute(NSForegroundColorAttributeName, value: UIColor(red:1.00, green:0.69, blue:0.19, alpha:1.0), range: oneLetterRange)
            
            self.label.attributedText = title
        }
        
            
        
        
    }
    
    
    
    func getFacts (date: NSDate) {
        self.dateSentToGetFacts = date
        NetworkManager.sharedManager.getFactsForDate(date)
    }
    
    func completeSortingAndTransition (facts : [Fact], date : NSDate) {
        datetoDisplay = date
        currentFacts = facts
        for (index, fact) in facts.enumerate() {
            if fact.info == nil {
                currentFacts?.removeAtIndex(index)
            }
        }
        
        dispatch_async(dispatch_get_main_queue()) {
            self.performSegueWithIdentifier("showFacts", sender: self)
        }
        
    }
    
    func showError () {
        let alertController = UIAlertController(title: "An Error Has Occurred!", message: nil, preferredStyle: .Alert)
        
        let retryAction = UIAlertAction(title: "Retry", style: .Default, handler: {(alert: UIAlertAction!) -> Void in
            self.getFacts(self.dateSentToGetFacts!)
        })

        alertController.addAction(retryAction)
        dispatch_async(dispatch_get_main_queue()) { 
            self.presentViewController(alertController, animated: true, completion: nil)
        }
        

        
    }
    
    
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "showFacts" {
            self.previousRandomNumber = nil
            if let destinationVC = segue.destinationViewController as? CardViewController {
                timer?.invalidate()
                destinationVC.displayedDate = datetoDisplay
                destinationVC.currentFacts = currentFacts
            }
        }
    }
 

}
