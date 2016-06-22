// The MIT License (MIT)
//
// Copyright (c) 2016 Alexander Grebenyuk (github.com/kean).

import UIKit

/// Signals the delegate that the preheat window changes.
public protocol PreheatControllerDelegate: class {
    /// Signals the delegate that the preheat window changes. Provides an array of index paths being added and being removed from the previously calculated preheat window.
    func preheatControllerDidUpdate(controller: PreheatController, addedIndexPaths: [NSIndexPath], removedIndexPaths: [NSIndexPath])
}

/**
 Automates precaching of content. Abstract class.
 
 After creating preheat controller you should enable it by settings enabled property to true.
*/
public class PreheatController: NSObject {
    /// The delegate of the receiver.
    public weak var delegate: PreheatControllerDelegate?

    /// The scroll view that the receiver was initialized with.
    public let scrollView: UIScrollView

    /// Current preheat index paths.
    public private(set) var preheatIndexPath = [NSIndexPath]()

    /// Default value is false. When preheat controller is enabled it immediately updates preheat index paths and starts reacting to user actions. When preheating controller is disabled it removes all current preheating index paths and signals its delegate.
    public var enabled = false
    
    /**
     Removes all index paths without signalling the delegate. Then updates preheat rect (if enabled).
     
     This method is useful when your model changes completely in which case you would first stop preheating all images and then reset the preheat controller.
     */
    public func reset() {
        preheatIndexPath.removeAll()
    }
    
    deinit {
        scrollView.removeObserver(self, forKeyPath: "contentOffset", context: nil)
    }

    /// Initializes the receiver with a given scroll view.
    public init(scrollView: UIScrollView) {
        self.scrollView = scrollView
        super.init()
        self.scrollView.addObserver(self, forKeyPath: "contentOffset", options: [.New], context: nil)
    }

    /// Calls `scrollViewDidScroll(_)` method when `contentOffset` of the scroll view changes.
    public override func observeValueForKeyPath(keyPath: String?, ofObject object: AnyObject?, change: [String : AnyObject]?, context: UnsafeMutablePointer<Void>) {
        if object === scrollView {
            scrollViewDidScroll()
        } else {
            super.observeValueForKeyPath(keyPath, ofObject: object, change: change, context: nil)
        }
    }
    
    // MARK: Subclassing Hooks

    /// Abstract method. Subclassing hook.
    public func scrollViewDidScroll() {
        assert(false)
    }

    /// Updates preheat index paths and signals delegate. Don't call this method directly, it should be used by subclasses.
    public func updatePreheatIndexPaths(indexPaths: [NSIndexPath]) {
        let addedIndexPaths = indexPaths.filter { return !preheatIndexPath.contains($0) }
        let removedIndexPaths = Set(preheatIndexPath).subtract(indexPaths)
        preheatIndexPath = indexPaths
        delegate?.preheatControllerDidUpdate(self, addedIndexPaths: addedIndexPaths, removedIndexPaths: Array(removedIndexPaths))
    }
}

// MARK: Internal

func distanceBetweenPoints(p1: CGPoint, _ p2: CGPoint) -> CGFloat {
    let dx = p2.x - p1.x, dy = p2.y - p1.y
    return sqrt((dx * dx) + (dy * dy))
}

enum ScrollDirection {
    case Forward, Backward
}

func sortIndexPaths<T: SequenceType where T.Generator.Element == NSIndexPath>(indexPaths: T, inScrollDirection scrollDirection: ScrollDirection) -> [NSIndexPath] {
    return indexPaths.sort {
        switch scrollDirection {
        case .Forward: return $0.section < $1.section || $0.item < $1.item
        case .Backward: return $0.section > $1.section || $0.item > $1.item
        }
    }
}
