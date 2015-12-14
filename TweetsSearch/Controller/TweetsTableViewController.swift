//
//  TweetsTableViewController.swift
//  TweetsSearch
//
//  Created by Aadesh Maheshwari on 14/12/15.
//  Copyright © 2015 Aadesh Maheshwari. All rights reserved.
//

import UIKit
import STTwitter
import SwiftyJSON
import SDWebImage

class TweetsTableViewController: UITableViewController, UISearchBarDelegate {
    let searchController = UISearchController(searchResultsController: nil)
    private let twitterCellidentifier = "twitterIdentifier"
    private let busyCellidentifier = "busyIdentifierCell"
    private var searching = false
    
    var tweetList = [Tweet]()
    var hasTag = "#Quantico"
    var timerSet = false
    
    // initaite twitter instance with consumner Key and consumer secret key
    let twitter = STTwitterAPI(appOnlyWithConsumerKey: "5TJyOyMKNVF2mrx7vY9bc0Zgb", consumerSecret: "iLIiO97vOUc4mH67Yf6my3FrAI4LfJS6eYTFsuDc1FJTNAxzVf")
    
    override func viewDidLoad() {
        super.viewDidLoad()
        searchController.searchBar.delegate = self
        searchController.dimsBackgroundDuringPresentation = true
        searchController.searchBar.placeholder = hasTag
        definesPresentationContext = true
        tableView.tableHeaderView = searchController.searchBar
        
        fetchTweets()
    }
    
    func fetchTweets() {
        searching = true
        //remove elements from old list
        self.tweetList.removeAll()
        self.tableView.reloadData()
        
        queryTweets(true)
    }
    
    func queryTweets(new: Bool) {
        
        if !new {
            self.tweetList.removeAll()
        }
        
        // verify twitter credentials
        twitter.verifyCredentialsWithUserSuccessBlock({ (userName, userId) -> Void in
            //query with the particular string
            self.twitter.getSearchTweetsWithQuery(self.hasTag, successBlock: { (searchMetadata, results) -> Void in
                self.searching = false
                let json = JSON(results)
                print("json count each time \(json.count)")
                //iterate and insert into model
                for (_,subJson):(String, JSON) in json {
                    if let _ = subJson["text"].string {
                        let tweet = Tweet(json: subJson)
                        self.tweetList.append(tweet)
                    } else {
                        print("no text available")
                    }
                }
                
                //refresh or reload the table with the data fetched
                if self.tweetList.count > 0 {
                    dispatch_async(dispatch_get_main_queue(), { () -> Void in
                        self.tableView.reloadData()
                    })
                }
                
                self.setTimer()
                
                }, errorBlock: { (error) -> Void in
                    self.searching = false
                    print("error description while fetching tweets for particular hastag")
            })
            
            }) { (error) -> Void in
                self.searching = false
                print("error \(error.localizedDescription)")
        }
    }
    
    func setTimer() {
        if !timerSet {
            //start the timer of 2 seconds
            NSTimer.scheduledTimerWithTimeInterval(2, target: self, selector: "refreshTweets", userInfo: nil, repeats: true)
            timerSet = true
        }
    }
    
    func refreshTweets() {
//        print("called this function")
        queryTweets(false)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if searching {
            return 1
        } else {
            return tweetList.count
        }
    }

    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        if searching {
            let cell = tableView.dequeueReusableCellWithIdentifier(busyCellidentifier, forIndexPath: indexPath) as! SearchingViewCell
            cell.busyIndicator.startAnimating()
            return cell
        } else {
            let cell = tableView.dequeueReusableCellWithIdentifier(twitterCellidentifier, forIndexPath: indexPath) as! TweetViewCell
            if let tweet: Tweet = tweetList[indexPath.row] {
                if let name = tweet.name {
                    cell.nameLabel.text = name
                    let calculationView = UILabel()
                    calculationView.numberOfLines = 0
                    let attributes = [NSFontAttributeName : UIFont.systemFontOfSize(17), NSForegroundColorAttributeName : UIColor.blackColor()]
                    calculationView.attributedText = NSAttributedString(string: tweet.name!, attributes: attributes)
                    let size:CGSize = calculationView.sizeThatFits(CGSizeMake(900, 21))
                    var rect = cell.nameLabel.frame
                    rect.size.width = size.width
                    cell.nameLabel.frame = rect
                }
                if let handle = tweet.twitterHandle {
                    cell.twitterHandle.text = "@" + handle
                }
                if let URL = tweet.profileImageURL {
                    cell.profileImageView.sd_setImageWithURL(NSURL(string: URL))
                }
                if let text = tweet.text {
                    cell.descriptionText.text = text
                }
                cell.selectionStyle = .None
            }
            return cell
        }
    }
    
    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        if searching {
            return 45
        } else {
            return labelHeightForRowAtIndexPath(indexPath) + 67
        }
    }
    
    func labelHeightForRowAtIndexPath(indexPath: NSIndexPath) -> CGFloat {
        let tweet = tweetList[indexPath.row]
        let calculationTitleView = UILabel()
        calculationTitleView.numberOfLines = 0
        let labelAttributes = [NSFontAttributeName : UIFont.systemFontOfSize(14), NSForegroundColorAttributeName : UIColor.blackColor()]
        calculationTitleView.attributedText = NSAttributedString(string: tweet.text!, attributes: labelAttributes)
        let labelViewWidth:CGFloat = CGRectGetWidth(self.view.frame) - 48
        let titlesize:CGSize = calculationTitleView.sizeThatFits(CGSizeMake(labelViewWidth, 900))
        return titlesize.height
    }

    func searchBarTextDidEndEditing(searchBar: UISearchBar) {
        print("\(searchBar.text)")
        if let text = searchBar.text {
            hasTag = "#" + text
            searchBar.placeholder = hasTag
            fetchTweets()
            searchController.dismissViewControllerAnimated(true, completion: nil)
        }
    }
}
