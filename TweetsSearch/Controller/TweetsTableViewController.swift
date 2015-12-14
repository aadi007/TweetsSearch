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

class TweetsTableViewController: UITableViewController, UISearchResultsUpdating {
    let searchController = UISearchController(searchResultsController: nil)
    private let twitterCellidentifier = "twitterIdentifier"
    
    var tweetList = [Tweet]()
    var hasTag = "#SalmaanFree"
    
    override func viewDidLoad() {
        super.viewDidLoad()

        searchController.searchResultsUpdater = self
        searchController.dimsBackgroundDuringPresentation = false
        searchController.searchBar.placeholder = hasTag
        definesPresentationContext = true
        tableView.tableHeaderView = searchController.searchBar
        
        fetchTweets()
    }
    
    func fetchTweets() {
        // initaite twitter instance with consumner Key and consumer secret key
        let twitter = STTwitterAPI(appOnlyWithConsumerKey: "5TJyOyMKNVF2mrx7vY9bc0Zgb", consumerSecret: "iLIiO97vOUc4mH67Yf6my3FrAI4LfJS6eYTFsuDc1FJTNAxzVf")
        
        // verify twitter credentials
        twitter.verifyCredentialsWithUserSuccessBlock({ (userName, userId) -> Void in
            //query with the particular string
            twitter.getSearchTweetsWithQuery(self.hasTag, successBlock: { (searchMetadata, results) -> Void in
                print("results meta data \(searchMetadata)")
                
                //remove elements from old list 
                self.tweetList.removeAll()
                
                let json = JSON(results)
                print("json Obj \(json)")
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
                
                }, errorBlock: { (error) -> Void in
                    print("error description while fetching tweets for particular hastag")
            })
            
            }) { (error) -> Void in
                print("error \(error.localizedDescription)")
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tweetList.count
    }

    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier(twitterCellidentifier, forIndexPath: indexPath) as! TweetViewCell
        if let tweet: Tweet = tweetList[indexPath.row] {
            if let name = tweet.name {
                cell.nameLabel.text = name
            }
            if let handle = tweet.twitterHandle {
                cell.twitterHandle.text = handle
            }
            if let URL = tweet.profileImageURL {
                cell.profileImageView.sd_setImageWithURL(NSURL(string: URL))
            }
            if let text = tweet.text {
                cell.descriptionText.text = text
            }
        }
        return cell
    }

    /*
    // Override to support conditional editing of the table view.
    override func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */
    
    func updateSearchResultsForSearchController(searchController: UISearchController) {
        print("search text: \(searchController.searchBar.text)")
    }
    
    /*
    // Override to support editing the table view.
    override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if editingStyle == .Delete {
            // Delete the row from the data source
            tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
        } else if editingStyle == .Insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(tableView: UITableView, moveRowAtIndexPath fromIndexPath: NSIndexPath, toIndexPath: NSIndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(tableView: UITableView, canMoveRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
