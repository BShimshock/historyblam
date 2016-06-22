//
//  NetworkManager.swift
//  HistoryBlam
//
//  Created by Brittany Shimshock on 4/27/16.
//  Copyright © 2016 Brittany Shimshock. All rights reserved.
//

import UIKit
protocol NetworkManagerDelegate {
    func completeSortingAndTransition (facts : [Fact], date : NSDate)
    func showError ()
    
}


class NetworkManager {
    var currentDate : NSDate?
    var networkManagerDelegate : NetworkManagerDelegate?
    static let sharedManager = NetworkManager()
    var factKeeper = [String : [Fact]]()
    var possibleImageTags = [String : String]()
    var possibleWikipediaSearchURLs = [String : NSURL]()
    var dateFormatter = NSDateFormatter()
    
    func getFactsForDate(date: NSDate) {
        dateFormatter.dateFormat = "M/d"
        let dateKey = dateFormatter.stringFromDate(date)
        let muffinAPIBase = "http://history.muffinlabs.com/date/"
        let urlAsString = muffinAPIBase + dateKey
        if let url = NSURL(string: urlAsString) {
            factKeeper.removeAll()
            if factKeeper[dateKey] == nil {
                factKeeper[dateKey] = [Fact]()
            }
            
            let session = NSURLSession.sharedSession()
            let request = NSMutableURLRequest(URL: url)
            //request.setValue("gzip, deflate", forHTTPHeaderField: "Accept-Encoding")
            let task = session.dataTaskWithRequest(request) { [unowned self]
                (data, response, error)  -> Void in
                let httpResponse = response as? NSHTTPURLResponse
                if error == nil && httpResponse?.statusCode == 200 {
                    var json: AnyObject? = nil
                    do {
                        json = try NSJSONSerialization.JSONObjectWithData(data!, options: .AllowFragments)
                    } catch {
                        return
                    }
                    if let jsonDictionary = json as? NSDictionary {
                        if let data = jsonDictionary["data"] as? NSDictionary {
                            if let events = data["Events"] as? NSArray {
                                for eventIndex in 0..<events.count {
                                    
                                    if let currentEvent = events[eventIndex] as? NSDictionary {
                                        let newFact = Fact()
                                        newFact.dateKey = dateKey
                                        if let year = currentEvent["year"] as? String {
                                            newFact.year = year
                                        }
                                        if let text = currentEvent["text"] as? String {
                                            newFact.info = text
                                            //newFact.info = "Lorem ipsum dolor sit amet, consectetur adipisicing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat. Duis aute irure dolor in reprehenderit in voluptate velit esse cillum dolore eu fugiat nulla pariatur. Excepteur sint occaecat cupidatat non proident, sunt in culpa qui officia deserunt mollit anim id est laborum."
                                        }
                                        if let links = currentEvent["links"] as? NSArray {
                                            newFact.numberOfResources = links.count
                                            for linkIndex in 0..<links.count {
                                                if let currentLink = links[linkIndex] as? NSDictionary {
                                                    if let linkTitle = currentLink["title"] as? String {
                                                        
                                                        let endpointPrefix = "https://en.wikipedia.org/w/api.php?action=query&titles="
                                                        let endpointSuffix = "&prop=pageimages&format=json&pithumbsize=500"

                                                        let formattedTitle = linkTitle.stringByAddingPercentEncodingWithAllowedCharacters(.URLHostAllowedCharacterSet())
                                                        let resourceEndpoint = endpointPrefix + formattedTitle! + endpointSuffix
                                                        let resourceKey = "resourceEndpoint\(linkIndex)"
                                                        newFact.resourceEndpoints[resourceKey] = resourceEndpoint
                                                        self.possibleImageTags[resourceKey] = linkTitle
                                                        let wikipediaEndpointPrefix = "https://en.wikipedia.org/wiki/"
                                                        let wikipediaEndpoint = wikipediaEndpointPrefix + formattedTitle!
                                                        if let wikipediaURL = NSURL(string: wikipediaEndpoint) {
                                                            self.possibleWikipediaSearchURLs[linkTitle] = wikipediaURL
                                                        }
                                                    }
                                                }
                                            }
                                        }
                                        self.factKeeper[dateKey]?.append(newFact)
                                        
                                    }
                                }
                                self.getImageURLs(dateKey, completion: { (facts, date) in
                                    self.networkManagerDelegate?.completeSortingAndTransition(facts!, date: date!)
                                })
                            }
                        }
                    }
                }
                else {
                    
                   self.networkManagerDelegate?.showError()
                }
                
            }
            task.resume()
        }
    }
    
    
    
    
    func getImageURLs (dateKey: String, completion: (facts : [Fact]?, date : NSDate?) -> Void) {
        
        
        guard let nsDateKey = dateFormatter.dateFromString(dateKey) else {
            completion(facts: nil, date: nil)
            return
        }
        var factIndex = 0
        guard let factsToSearch = self.factKeeper[dateKey] else {
            completion(facts: nil, date: nil)
            return
        }
        for fact in factsToSearch {
            getImageURLForFact(fact, completion: { 
                factIndex += 1
                
                if factIndex == factsToSearch.count {
                    //print("got all the facts")
                    completion(facts: factsToSearch, date: nsDateKey)
                }
            })
        }
    }
    
    func getImageURLForFact (fact: Fact, completion: () -> Void) {
        var numberOfCheckedEndpoints = 0
        var lastReturnedIndex = 100
        var lastPhotoURL : NSURL?
        var lastPhotoTag : String?
        if fact.resourceEndpoints.count > 0 {
            for index in 0..<fact.resourceEndpoints.count {
                if let currentEndpoint = fact.resourceEndpoints["resourceEndpoint\(index)"] {
                    checkEndpointForImage(currentEndpoint, completion: { (photoURL, photoTag) in
                        numberOfCheckedEndpoints += 1
                        
                        
                        if photoURL != nil && photoTag != nil && lastReturnedIndex > index {
                            if Int(photoTag!) == nil && photoTag?.characters.count > 1 {
                                lastPhotoURL = photoURL
                                lastPhotoTag = photoTag
                                lastReturnedIndex = index
                            }
   
                        }
                        if (numberOfCheckedEndpoints == fact.resourceEndpoints.count) {
                            if lastPhotoURL != nil {
                                if lastPhotoTag != nil {
                                    fact.photoURL = lastPhotoURL
                                    fact.photoTag = lastPhotoTag
                                    if let url = self.possibleWikipediaSearchURLs[lastPhotoTag!] {
                                        fact.photoWikipediaURL = url
                                        
                                    }
                                    
                                }
                                
                            }
                            completion()
                        }
                    })
                } else {
                    numberOfCheckedEndpoints += 1
                    if (numberOfCheckedEndpoints == fact.resourceEndpoints.count) {
                        fact.photoURL = lastPhotoURL
                        fact.photoTag = lastPhotoTag
                        completion()
                    }
                }
                
            }
        } else {
            numberOfCheckedEndpoints += 1
            completion()
        }

        
    }
    
    func checkEndpointForImage (endpoint: String, completion: (photoURL : NSURL?, photoTag : String?) -> Void) {
        guard let searchURL = NSURL(string: endpoint) else {
            print("failed endpoint \(endpoint)")
            completion(photoURL: nil, photoTag: nil)
            return
        }
        let session = NSURLSession.sharedSession()
        let request = NSMutableURLRequest(URL: searchURL)
        request.setValue("gzip, deflate", forHTTPHeaderField: "Accept-Encoding")
        let task = session.dataTaskWithURL(searchURL) { (data, response, error) in
            if error == nil {
                var json : AnyObject? = nil
                do {
                    json = try NSJSONSerialization.JSONObjectWithData(data!, options: .AllowFragments)
                } catch {
                    completion(photoURL: nil, photoTag: nil)
                }
                
                if let jsonDictionary = json as? NSDictionary {
                    guard let queryDictionary = jsonDictionary["query"] as? NSDictionary else {
                        completion(photoURL: nil, photoTag: nil)
                        return
                    }
                    guard let pagesDictionary = queryDictionary["pages"] as? NSDictionary else {
                        completion(photoURL: nil, photoTag: nil)
                        return
                    }
                    guard let pagesFirstDefinition = pagesDictionary.allValues.first as? NSDictionary else {
                        completion(photoURL: nil, photoTag: nil)
                        return
                    }
                    guard let thumbnailDictionary = pagesFirstDefinition["thumbnail"] as? NSDictionary else {
                        completion(photoURL: nil, photoTag: nil)
                        return
                    }
                    
                    guard let imageURL = thumbnailDictionary["source"] as? String else {
                        completion(photoURL: nil, photoTag: nil)
                        return
                    }
                    if let photoURL = NSURL(string: imageURL) {
                        
                        if let imageTitle = pagesFirstDefinition["title"] as? String {
                            completion(photoURL: photoURL, photoTag: imageTitle)
                            return
                        }
                        completion(photoURL: nil, photoTag: nil)
                        return
                        
                    }
                }
            }
            else {
                completion(photoURL: nil, photoTag: nil)
            }
        }
        task.resume()
    }

}
