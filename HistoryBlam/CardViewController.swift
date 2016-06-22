//
//  CardViewController.swift
//  HistoryBlam
//
//  Created by Brittany Shimshock on 4/27/16.
//  Copyright © 2016 Brittany Shimshock. All rights reserved.
//

import UIKit
import Nuke
import SafariServices
import ReachabilitySwift

class CardViewController: UIViewController, UICollectionViewDelegateFlowLayout, UICollectionViewDataSource, UIGestureRecognizerDelegate, MyCollectionViewCellDelegate, SFSafariViewControllerDelegate {
    var reachability : Reachability?
    
    
    var monthWidth : CGFloat?
    var monthHeight : CGFloat?
    var bothContainerOriginalHeight : CGFloat?
    var dayWidth : CGFloat?
    var dayHeight : CGFloat?
    
    var currentDateKey : String?
    var dateFormatter = NSDateFormatter()
    
    var displayedDate : NSDate?
    var currentFact : Fact?
    var currentFacts : [Fact]?
    
    let tapGestureRecognizer = UITapGestureRecognizer()
    

    @IBOutlet weak var flowLayout: UICollectionViewFlowLayout!

    @IBOutlet weak var collectionOutlet: UICollectionView!
    var isPresenting = false {
        didSet {
            if isPresenting == true {
                collectionOutlet.userInteractionEnabled = false
            } else {
                collectionOutlet.userInteractionEnabled = true
            }
        }
    }
    
    
    @IBOutlet weak var widgetBorderView: UIView!
    @IBOutlet weak var widgetHeightConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var widgetContainerView: UIView!
    
    @IBOutlet weak var poweredByWikipediaButton: UIButton!
    
    
    @IBOutlet weak var datePickerContainer: UIView!
    
    @IBOutlet weak var datePickerContainerCenterYConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var datePickerContainerHeightConstraint: NSLayoutConstraint!
    
    
    @IBOutlet weak var monthUpView: UIView!
    @IBOutlet weak var monthDownView: UIView!
    @IBOutlet weak var dayUpView: UIView!
    @IBOutlet weak var dayDownView: UIView!
    
    
    @IBOutlet weak var bothDateContainer: UIView!
    
    @IBOutlet weak var monthContainer: UIView!
    @IBOutlet weak var dayContainer: ShadowView!
    @IBOutlet weak var monthColorView: UIView!
    @IBOutlet weak var dayColorView: UIView!
    @IBOutlet weak var monthLabel: UILabel!
    @IBOutlet weak var dayLabel: UILabel!
    
    @IBOutlet weak var monthUpButton: UIButton!
    @IBOutlet weak var monthDownButton: UIButton!
    
    @IBOutlet weak var dayUpButton: UIButton!
    @IBOutlet weak var dayDownButton: UIButton!

    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        flowLayout.scrollDirection = .Horizontal
        flowLayout.minimumLineSpacing = 0
        
        self.collectionOutlet.clipsToBounds = false
        
        
        self.setButtonValues()
        self.hideButtons()
        
        monthUpButton.tag = 1
        monthDownButton.tag = 2
        dayUpButton.tag = 1
        dayDownButton.tag = 2
        
        self.view.setNeedsLayout()
        self.widgetHeightConstraint.constant = 95
        self.datePickerContainerCenterYConstraint.constant = 1.25
        //self.datePickerContainerCenterYConstraint.constant = 0
        self.datePickerContainerHeightConstraint.constant = 60
        self.view.layoutIfNeeded()
        
        //blue
        self.poweredByWikipediaButton.backgroundColor = UIColor(red:0.42, green:0.65, blue:0.91, alpha:1.0)
        self.poweredByWikipediaButton.hidden = true
    
        //purple
        self.widgetBorderView.backgroundColor = UIColor(red:0.75, green:0.33, blue:1.00, alpha:1.0)
        self.widgetBorderView.layer.borderWidth = 5
        
        monthColorView.layer.masksToBounds = true
        //blue
        monthColorView.layer.backgroundColor = UIColor(red:0.42, green:0.65, blue:0.91, alpha:1.0).CGColor
        monthColorView.layer.cornerRadius = 8
        monthColorView.layer.borderColor = UIColor.blackColor().CGColor
        monthColorView.layer.borderWidth = 3
        
        monthLabel.adjustsFontSizeToFitWidth = true

        
        dayColorView.layer.masksToBounds = true
        dayLabel.adjustsFontSizeToFitWidth = true
        dayColorView.layer.cornerRadius = 8
        dayColorView.layer.borderWidth = 3
        //blue
        dayColorView.layer.backgroundColor = UIColor(red:0.42, green:0.65, blue:0.91, alpha:1.0).CGColor
        
        
        
        
        tapGestureRecognizer.delegate = self
        tapGestureRecognizer.addTarget(self, action: #selector(CardViewController.tapped(_:)))
        self.view.addGestureRecognizer(tapGestureRecognizer)
        
        
        do {
            reachability = try Reachability.reachabilityForInternetConnection()
        } catch {
            print("Unable to create Reachability")
            return
        }
        
        do {
            try reachability?.startNotifier()
        } catch {
            print("Unable to start notifier")
        }
        

    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    deinit {
        reachability?.stopNotifier()
    }
    
    
    
    @IBAction func poweredByWIkipediaButtonWasPressed(sender: AnyObject) {
        dateFormatter.dateFormat = "MMMM d"
        let currentDate = dateFormatter.stringFromDate(displayedDate!)
        let formattedDate = currentDate.stringByReplacingOccurrencesOfString(" ", withString: "_")
        let endpoint = "https://en.wikipedia.org/wiki/"
        let urlString = endpoint + formattedDate
        let url = NSURL(string: urlString)
        let safari = SFSafariViewController(URL: url!)
        self.presentViewController(safari, animated: true, completion: nil)
        
        
    }

    
    @IBAction func changeMonth(sender: AnyObject) {
        
        if let currentMonthString = monthLabel.text {
            dateFormatter.dateFormat = "MMMM"
            if let currentMonthDate = dateFormatter.dateFromString(currentMonthString) {
                dateFormatter.dateFormat = "M"
                let currentMonthIntString = dateFormatter.stringFromDate(currentMonthDate)
                
                
                if sender.tag == 1 {
                    if currentMonthIntString == "12" {
                        let newMonthToDisplay = "1"
                        let displayMonthstep = dateFormatter.dateFromString(newMonthToDisplay)
                        dateFormatter.dateFormat = "MMMM"
                        let displayMonth = dateFormatter.stringFromDate(displayMonthstep!)
                        
                        dispatch_async(dispatch_get_main_queue(), {
                            self.monthLabel.text = displayMonth
                            self.checkMonth(displayMonthstep!)
                        })
                    } else {
                        if let currentMonthInt = Int(currentMonthIntString) {
                            let previousMonth = currentMonthInt + 1
                            let previousMonthString = String(previousMonth)
                            dateFormatter.dateFormat = "M"
                            if let previousMonthDate = dateFormatter.dateFromString(previousMonthString) {
                                dateFormatter.dateFormat = "MMMM"
                                let previousMonthFormattedString = dateFormatter.stringFromDate(previousMonthDate)
                                dispatch_async(dispatch_get_main_queue(), {
                                    self.monthLabel.text = previousMonthFormattedString
                                    self.checkMonth(previousMonthDate)
                                })
                            }
                        }
                    }
                    
                } else if sender.tag == 2 {
                    if currentMonthIntString == "1" {
                        let newMonthToDisplay = "12"
                        
                        let displayMonthstep = dateFormatter.dateFromString(newMonthToDisplay)
                        dateFormatter.dateFormat = "MMMM"
                        let displayMonth = dateFormatter.stringFromDate(displayMonthstep!)
                        
                        dispatch_async(dispatch_get_main_queue(), {
                            self.monthLabel.text = displayMonth
                            self.checkMonth(displayMonthstep!)
                            
                        })
                    } else {
                        if let currentMonthInt = Int(currentMonthIntString) {
                            let nextMonth = currentMonthInt - 1
                            let nextMonthString = String(nextMonth)
                            dateFormatter.dateFormat = "M"
                            if let nextMonthDate = dateFormatter.dateFromString(nextMonthString) {
                                dateFormatter.dateFormat = "MMMM"
                                let nextMonthFormattedString = dateFormatter.stringFromDate(nextMonthDate)
                                dispatch_async(dispatch_get_main_queue(), {
                                    self.monthLabel.text = nextMonthFormattedString
                                    self.checkMonth(nextMonthDate)
                                })
                                
                            }
                            
                        }
                        
                    }
                    
                }
                
            }
            
            
        }

    }
    
    
    @IBAction func changeDay(sender: AnyObject) {
        if let currentMonthStringWord = self.monthLabel.text {
            dateFormatter.dateFormat = "MMMM"
            if let currentMonthDate = dateFormatter.dateFromString(currentMonthStringWord) {
                let formattedDate = NSDateToCalendarComponents(currentMonthDate)
                let calendar = NSCalendar(calendarIdentifier: NSCalendarIdentifierGregorian)
                if let numberOfDaysPackage = calendar?.rangeOfUnit(.Day, inUnit: .Month, forDate: formattedDate) {
                    
                    let numberOfDays = numberOfDaysPackage.length
                    if let currentDateString = dayLabel.text {
                        
                        if let currentDateInt = Int(currentDateString) {
                            
                            if sender.tag == 1 {
                                if currentDateInt == numberOfDays {
                                    let nextDate = String(1)
                                    self.dayLabel.text = nextDate
                                } else {
                                    let nextDateInt = currentDateInt + 1
                                    let nextDate = String(nextDateInt)
                                    self.dayLabel.text = nextDate
                                }
                                
                            } else if sender.tag == 2 {
                                if currentDateInt == 1 {
                                    let nextDate = String(numberOfDays)
                                    self.dayLabel.text = nextDate
                                } else {
                                    let nextDateInt = currentDateInt - 1
                                    let nextDate = String(nextDateInt)
                                    self.dayLabel.text = nextDate
                                }
                            }
                        }
                    }
                }
            }
        }

    }
    
    
    
    
    
    func populateLabels (dateToDisplay: NSDate) {
        
        
        dateFormatter.dateFormat = "MMMM"
        let displayMonth = dateFormatter.stringFromDate(dateToDisplay)
        dateFormatter.dateFormat = "d"
        let displayDay = dateFormatter.stringFromDate(dateToDisplay)
        self.monthLabel.text = displayMonth
        self.dayLabel.text = displayDay
        
        
    }
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if currentFacts != nil {
            return currentFacts!.count
            
        }
        return 1
        
        
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let myCell = collectionView.dequeueReusableCellWithReuseIdentifier("cell", forIndexPath: indexPath) as! MyCollectionViewCell
        if currentFacts != nil {
            myCell.delegate = self
            myCell.imageView.image = UIImage(named: "loadingImage500x500")
            let fact = currentFacts![indexPath.row]
            self.currentFact = fact
            myCell.cellFact = fact
            myCell.clipsToBounds = false
            if let photoURL = fact.photoURL {
                myCell.tagColorView.hidden = false
                do {
                    reachability = try Reachability.reachabilityForInternetConnection()
                } catch {
                    print("Unable to create Reachability")
                }
                
                
                reachability?.whenReachable = { reachability in
                    dispatch_async(dispatch_get_main_queue()) {
                        myCell.imageView.nk_setImageWith(photoURL) 
                        
                    }
                }
                do {
                    try reachability?.startNotifier()
                } catch {
                    //print("Unable to start notifier")
                }

            } else {
                myCell.tagColorView.hidden = true
                myCell.imageView.image = UIImage(named: "noImage3")
            }
     
            //blue
            myCell.imageViewColorView.backgroundColor = UIColor(red:0.42, green:0.65, blue:0.91, alpha:1.0)
            
            //green
            myCell.contentView.backgroundColor = UIColor(red:0.25, green:1.00, blue:0.56, alpha:1.0)
            self.view.backgroundColor = UIColor(red:0.25, green:1.00, blue:0.56, alpha:1.0)
            
            //orange
            myCell.factColorView.backgroundColor = UIColor(red:1.00, green:0.69, blue:0.19, alpha:1.0)
            
            //yellow
            myCell.yearColorView.backgroundColor = UIColor(red:0.86, green:0.91, blue:0.34, alpha:1.0)
            myCell.tagColorView.backgroundColor = UIColor(red:0.86, green:0.91, blue:0.34, alpha:1.0)
            
            
            myCell.factTextView.text = fact.info
            dispatch_async(dispatch_get_main_queue(), {
                myCell.factTextView.contentOffset = CGPointZero
                myCell.factTextView.textContainerInset = UIEdgeInsetsZero
            })
            myCell.yearLabel.text = fact.year
            myCell.tagLabel.text = fact.photoTag
            
            myCell.factColorView.layer.masksToBounds = true
            myCell.factColorView.layer.cornerRadius = 8
            myCell.factColorView.layer.borderColor = UIColor.blackColor().CGColor
            myCell.factColorView.layer.borderWidth = 3
            
            myCell.yearColorView.layer.masksToBounds = true
            myCell.yearColorView.layer.cornerRadius = 8
            myCell.yearColorView.layer.borderWidth = 3
            
            myCell.imageViewColorView.layer.masksToBounds = true
            myCell.imageViewColorView.layer.borderWidth = 3
            myCell.imageViewColorView.layer.cornerRadius = 8
            
            myCell.tagColorView.layer.masksToBounds = true
            myCell.tagColorView.layer.cornerRadius = 8
            myCell.tagColorView.layer.borderWidth = 3
 
        }
        
        return myCell
    }
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
        let height = CGRectGetHeight(self.collectionOutlet.frame)
        let width = CGRectGetWidth(self.collectionOutlet.frame)
        return CGSize(width: width, height: height)
    }
    
    func didTapImage(cell: MyCollectionViewCell, url: NSURL) {
        let safari = SFSafariViewController(URL: url)
        self.presentViewController(safari, animated: true, completion: {
            cell.closeImage()
        })
    }

    
    func tapped (sender: UITapGestureRecognizer) {
        let tapLocation = sender.locationOfTouch(0, inView: sender.view)
        let tappedView = sender.view?.hitTest(tapLocation, withEvent: nil)
        
        
        
        if isPresenting {
            if tappedView != widgetContainerView && tappedView != monthLabel && tappedView != dayLabel && tappedView != bothDateContainer {

                dispatch_async(dispatch_get_main_queue(), {

                    self.isPresenting = false
                    self.hideButtons()
                    self.view.layoutIfNeeded()

                    UIView.animateWithDuration(0.33, delay: 0, usingSpringWithDamping: 0.5, initialSpringVelocity: 0.5, options: .BeginFromCurrentState, animations: { 
                        self.hideButtons()
                        self.poweredByWikipediaButton.hidden = true
                        self.widgetHeightConstraint.constant = 95
                        self.datePickerContainerCenterYConstraint.constant = 1.25
                        self.datePickerContainerHeightConstraint.constant = 60

                        self.view.layoutIfNeeded()
                        }, completion: { (finished) in
                            let previousDisplayedDate = self.displayedDate
                            self.setNewDisplayedDateFromCurrentButtonValues()
                            self.dateFormatter.dateFormat = "M/d"
                            let dateKey = self.dateFormatter.stringFromDate(self.displayedDate!)
                            if previousDisplayedDate != self.displayedDate {
                                if let presentingVC = self.presentingViewController as? LoadingViewController {
                                    self.dismissViewControllerAnimated(true, completion: {
                                        
                                        
                                        if NetworkManager.sharedManager.factKeeper[dateKey] != nil {
                                            let displayedDateFacts = NetworkManager.sharedManager.factKeeper[dateKey]
                                            presentingVC.completeSortingAndTransition(displayedDateFacts!, date: self.displayedDate!)
                                        } else {
                                            let formattedDate = self.NSDateToCalendarComponents(self.displayedDate!)
                                            //print(formattedDate)
                                            presentingVC.getFacts(formattedDate)
                                        }
                                        
                                    })
                                }
                                
                            }
                    })

                })
            }
            
        } else {
            if tappedView == widgetContainerView || tappedView == monthColorView || tappedView == dayColorView || tappedView == bothDateContainer {
                if reachability?.isReachable() == false {
                    self.wiggleDate()
                    return
                }
                dispatch_async(dispatch_get_main_queue(), {
                    
                    self.isPresenting = true
                    self.view.bringSubviewToFront(self.widgetBorderView)
                    self.view.layoutIfNeeded()
                    UIView.animateWithDuration(0.33, delay: 0, usingSpringWithDamping: 0.5, initialSpringVelocity: 0.5, options: .BeginFromCurrentState, animations: {
                        self.poweredByWikipediaButton.hidden = false
                        self.widgetHeightConstraint.constant = 200
                        self.datePickerContainerCenterYConstraint.constant = -10
                        self.datePickerContainerHeightConstraint.constant = 175
                        self.showButtons()
                        self.view.layoutIfNeeded()
                        }, completion: { (finished) in
                            //self.showButtons()
                    })
                })
                
            }
        }
        
    }
    
    
    func setButtonValues () {
        if displayedDate != nil {
            dateFormatter.dateFormat = "MMMM"
            let currentMonth = dateFormatter.stringFromDate(displayedDate!)
            monthLabel.text = currentMonth
            
            dateFormatter.dateFormat = "d"
            let currentDay = dateFormatter.stringFromDate(displayedDate!)
            dayLabel.text = currentDay
        }
    }
    
    
    func hideButtons () {
        self.monthUpButton.hidden = true
        self.monthDownButton.hidden = true
        self.dayDownButton.hidden = true
        self.dayUpButton.hidden = true
    }
    
    func showButtons () {
        self.monthUpButton.hidden = false
        self.monthDownButton.hidden = false
        self.dayDownButton.hidden = false
        self.dayUpButton.hidden = false
        
    }
    
    func wiggleDate () {
        UIView.animateWithDuration(0.11, delay: 0.0, usingSpringWithDamping: 0.5, initialSpringVelocity: 0.5, options: .BeginFromCurrentState, animations: {
            self.bothDateContainer.center.y -= 5
            }, completion: nil)
        UIView.animateWithDuration(0.11, delay: 0.11, usingSpringWithDamping: 0.5, initialSpringVelocity: 0.5, options: .BeginFromCurrentState, animations: {
            self.bothDateContainer.center.y += 5
            }, completion: nil)
    }
    

    
    
    func setNewDisplayedDateFromCurrentButtonValues () {
        if let month = self.monthLabel.text {
            if let day = self.dayLabel.text {
                let dateString = "\(month) \(day)"
                self.dateFormatter.dateFormat = "MMMM d"
                let newDate = self.dateFormatter.dateFromString(dateString)
                self.displayedDate = newDate
                
            }
        }
    }
    
    func getNewDateFromValues () -> NSDate {
        if let month = self.monthLabel.text {
            if let day = self.dayLabel.text {
                let dateString = "\(month) \(day)"
                self.dateFormatter.dateFormat = "MMMM d"
                let newDate = self.dateFormatter.dateFromString(dateString)
                return newDate!
                
            }
        }
        return NSDate()
        
    }
    
    func NSDateToCalendarComponents (date: NSDate) -> NSDate {
        let calendar = NSCalendar(identifier: NSCalendarIdentifierGregorian)
        dateFormatter.dateFormat = "MM"
        let stringInt = dateFormatter.stringFromDate(date)
        let monthInt = Int(stringInt)
        dateFormatter.dateFormat = "d"
        let dayStringInt = dateFormatter.stringFromDate(date)
        let dayInt = Int(dayStringInt)
        let components = NSDateComponents()
        components.year = 2016
        components.month = monthInt!
        components.day = dayInt!
        
        if let yearCorrectedDate = calendar?.dateFromComponents(components) {
            return yearCorrectedDate
        }
        return date
    }
    
    
    func checkMonth (currentMonth: NSDate) {
        if let calendar = NSCalendar(identifier: NSCalendarIdentifierGregorian) {
            let daysOfMonth = calendar.rangeOfUnit(.Day, inUnit: .Month, forDate: currentMonth)
            dateFormatter.dateFormat = "MMMM"
            //let month = dateFormatter.stringFromDate(currentMonth)
            if let dayString = self.dayLabel.text {
                if let dayInt = Int(dayString) {
                    if dayInt > daysOfMonth.length {
                        let newDay = String(daysOfMonth.length)
                        dispatch_async(dispatch_get_main_queue(), {
                            self.dayLabel.text = newDay
                        })
                    }
                }
            }
        }
    }
   


    


}
