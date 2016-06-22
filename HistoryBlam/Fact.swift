//
//  Fact.swift
//  HistoryBlam
//
//  Created by Brittany Shimshock on 4/18/16.
//  Copyright © 2016 Brittany Shimshock. All rights reserved.
//

import Foundation

class Fact {
    
    
    var info : String?
    var dateKey : String?
    var year : String?
    var numberOfResources : Int?

    //wikipedia searching
    //remember that these are 0 indexed! like ["photoSearchURL0" : URL]  ["resourceEndpoint0" : ""]
    var resourceEndpoints = [String : String]()
    var photoSearchURLs = [String : NSURL]()
    
    var photoURL : NSURL?
    var photoTag : String?
    var photoWikipediaURL : NSURL?


    
}

