//
//  Tweet.swift
//  TweetsSearch
//
//  Created by Aadesh Maheshwari on 14/12/15.
//  Copyright © 2015 Aadesh Maheshwari. All rights reserved.
//

import UIKit
import SwiftyJSON

class Tweet: NSObject {

    var text: String?
    var name: String?
    var profileImageURL: String?
    var twitterHandle: String?
    
    init(json: JSON) {
        super.init()
        self.text = json["text"].string
        self.name = json["name"].string
        self.profileImageURL = json["profile_image_url_https"].string
        self.twitterHandle = json["screen_name"].string
    }
}
