//
//  CollectionViewCell.swift
//  HistoryBlam
//
//  Created by Brittany Shimshock on 4/27/16.
//  Copyright © 2016 Brittany Shimshock. All rights reserved.
//

import Foundation
import UIKit
import ReachabilitySwift

protocol MyCollectionViewCellDelegate: class {
    func didTapImage(cell: MyCollectionViewCell, url: NSURL)
}

class MyCollectionViewCell: UICollectionViewCell, UIGestureRecognizerDelegate  {
    weak var delegate: MyCollectionViewCellDelegate?
    var reachability : Reachability?
    var isExpanded = false {
        didSet {
            if isExpanded == true {
                if reachability?.isReachable() == true {
                    self.wikipediaButton.alpha = 1
                } else {
                    self.wikipediaButton.alpha = 0
                }
            } else {
                self.wikipediaButton.alpha = 0
            }
        }
    }
    var cellFact : Fact?
    var tapGestureRecognizer = UITapGestureRecognizer()
    
    var previousRandomNumber : Int?
    var timer : NSTimer?

    @IBOutlet weak var loadingLabel: UILabel!
    
    @IBOutlet weak var factTextView: UITextView!
    @IBOutlet weak var factColorView: UIView!
    
    @IBOutlet weak var yearLabel: UILabel!
    @IBOutlet weak var yearColorView: UIView!
    
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var imageViewColorView: UIView!
    
    @IBOutlet weak var tagLabel: UILabel!
    @IBOutlet weak var tagColorView: UIView!
    
    //image shadow view constraints
    
    @IBOutlet weak var topView: UIView!
    
    @IBOutlet weak var imageShadowView: ShadowView!

    @IBOutlet var smallHeight: NSLayoutConstraint!
    @IBOutlet weak var smallWidth: NSLayoutConstraint!
    @IBOutlet var largeHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var largeWidthConstraint: NSLayoutConstraint!
    

    @IBOutlet weak var wikipediaButton: UIButton!

    @IBAction func wikipediaButtonWasPressed(sender: AnyObject) {
        if let currentFact = self.cellFact {
            if let currentURL = currentFact.photoWikipediaURL {
                delegate?.didTapImage(self, url: currentURL)
            }
        }
    }
    
    
    func initialize () {
        wikipediaButton.alpha = 0
        tapGestureRecognizer.delegate = self
        tapGestureRecognizer.addTarget(self, action:#selector(MyCollectionViewCell.tapped(_:)))
        self.imageShadowView.addGestureRecognizer(tapGestureRecognizer)
        do {
            reachability = try Reachability.reachabilityForInternetConnection()
        } catch {
            print("Unable to create Reachability")
            return
        }
        
        
        reachability?.whenReachable = { reachability in
            // this is called on a background thread, but UI updates must
            // be on the main thread, like this:
            dispatch_async(dispatch_get_main_queue()) {
                
                self.isExpanded = self.isExpanded
                
            }
        }
        reachability?.whenUnreachable = { reachability in
            // this is called on a background thread, but UI updates must
            // be on the main thread, like this:
            dispatch_async(dispatch_get_main_queue()) {
                self.isExpanded = self.isExpanded
                
            }
        }
        
        do {
            try reachability?.startNotifier()
        } catch {
            print("Unable to start notifier")
        }

        
    }
    
    deinit {
        reachability?.stopNotifier()
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        initialize()
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        self.closeImage()
        self.imageView.image = nil
    }

    func closeImage () {
        isExpanded = false
        self.largeWidthConstraint.active = false
        self.largeHeightConstraint.active = false
        self.smallWidth.active = true
        self.smallHeight.active = true
        self.tagColorView.hidden = false
    }

    
    func tapped(sender: UITapGestureRecognizer) {
        self.contentView.bringSubviewToFront(topView)
        if self.imageView.image != UIImage(named: "noImage3") {
            if isExpanded {
                
                self.largeWidthConstraint.active = false
                self.largeHeightConstraint.active = false
                self.smallWidth.active = true
                self.smallHeight.active = true
                self.isExpanded = false
                self.tagColorView.hidden = false
                
                
                self.setNeedsLayout()
                
                UIView.animateWithDuration(0.33, delay: 0, usingSpringWithDamping: 0.5, initialSpringVelocity: 0.5, options: .BeginFromCurrentState, animations: {
                    self.layoutIfNeeded()
                    }, completion:nil)
                
            } else {
                self.smallWidth.active = false
                self.smallHeight.active = false
                self.largeWidthConstraint.active = true
                self.largeHeightConstraint.active = true

                self.tagColorView.hidden = true
                self.isExpanded = true
                
                
                self.setNeedsLayout()
                
                UIView.animateWithDuration(0.33, delay: 0, usingSpringWithDamping: 0.5, initialSpringVelocity: 0.5, options: .BeginFromCurrentState, animations: {
                    
                    
                    self.layoutIfNeeded()
                    }, completion:nil)

                
            }
            
        }

        
    }
}
