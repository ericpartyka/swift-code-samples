//
//  HEEventSearchController.swift
//  Homeaway Events
//
//  Created by Eric Partyka on 8/1/17.
//  Copyright © 2017 SocialSell LLC. All rights reserved.
//

import UIKit
import Alamofire
import SDWebImage

class HEEventSearchController: UIViewController, UITableViewDelegate, UITableViewDataSource, HEEventDetailControllerDelegate, UISearchBarDelegate {

    // MARK: Properties
    
    @IBOutlet var theSearchBar: UISearchBar!
    @IBOutlet var theTableView: UITableView!
    var theDataSourceArray = [] as NSArray
    
    
    // MARK: - View Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        self.configureView()
        self.configureNavBar()
        self.configureXIBs()
        self.configureSearchBar()
    }
    
    // MARK: - Memory Management

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - Private Methods
    
    func configureView() {
        
        self.theTableView.tableFooterView = UIView()
        self.theTableView.separatorInset = UIEdgeInsets.zero
        
    }
    
    func configureNavBar() {
        
        self.navigationController?.navigationBar.isTranslucent = false
        self.navigationItem.title = NSLocalizedString("Event Search", comment: "Event Search")
        self.navigationController?.navigationBar.barTintColor = UIColor(named: "BlueColor")
        self.navigationController?.navigationBar.tintColor = UIColor.white
        self.navigationController?.navigationBar.titleTextAttributes = [NSAttributedStringKey.foregroundColor: UIColor.white]
        
        
    }
    
    func configureXIBs() {

        self.theTableView.register(UINib(nibName: "HEEventItemTableViewCell", bundle: nil), forCellReuseIdentifier: "HEEventItemTableViewCell")
        
    }
    
    func configureSearchBar() {
        
        self.theSearchBar.placeholder = NSLocalizedString("Search event name...", comment: "Search event name...")
        self.theSearchBar.returnKeyType = UIReturnKeyType.done
        self.theSearchBar.enablesReturnKeyAutomatically = false
        self.theSearchBar.keyboardAppearance = UIKeyboardAppearance.dark
    }

    
    // MARK: - UITableViewDataSource
    
    func numberOfSections(in tableView: UITableView) -> Int {
        
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        if self.theDataSourceArray.count > 0
        {
            return self.theDataSourceArray.count
        }
        else
        {
            return 0
        }
        
    }
    
    // MARK: UITableViewDelegate
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        
        let cell = tableView.dequeueReusableCell(withIdentifier: "HEEventItemTableViewCell", for: indexPath) as! HEEventItemTableViewCell
        self.configureCell(cell: cell, theIndexPath: indexPath)
        
        return cell
    }
    
    func configureCell(cell: HEEventItemTableViewCell, theIndexPath: IndexPath) {
        
        let theEventItemDict = self.theDataSourceArray.object(at: theIndexPath.row) as! NSDictionary
        
        
        let theVenueDict = theEventItemDict.object(forKey: "venue") as? NSDictionary
        let thePerformsArray = theEventItemDict.object(forKey: "performers") as! NSArray
        let thePerformersObject = thePerformsArray.firstObject as! NSDictionary
        
        let theTitleString = String(format: "%@", theEventItemDict.object(forKey: "title") as! CVarArg)
        let theLocationString = String(format: "%@", theVenueDict?.object(forKey: "display_location") as! CVarArg)
     
        if let theImageString = thePerformersObject.object(forKey: "image") as? String
        {
            let theImageURL = URL(string: theImageString)
            cell.theImageView.sd_setImage(with: theImageURL, placeholderImage: UIImage(named: "EventPlaceholder"))
        }
        else
        {
            cell.theImageView.image = UIImage(named: "EventPlaceholder")
        }
    
        if let theTimestamp = theEventItemDict.object(forKey: "datetime_utc") as? String
        {
            cell.theEventTimestampLabel.text = theTimestamp
        }
        else
        {
            cell.theEventTimestampLabel.text = nil
        }
   
        cell.theEventTitleLabel.text = theTitleString
        cell.theEventLocationLabel.text = theLocationString
        
        let theIdString = String(format: "%@", theEventItemDict.object(forKey: "id") as! CVarArg)
        
        if HECacheUtil.doesCacheContainObjectForKey(theKey: theIdString)
        {
            cell.theFavoritedImageView.image = UIImage(named: "Heart")
        }
        else
        {
            cell.theFavoritedImageView.image = nil
        }
        
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        return 100
        
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        self.theTableView.deselectRow(at: indexPath, animated: true)
        
        let theItemDict = self.theDataSourceArray.object(at: indexPath.row) as! NSDictionary
        let theStoryboard = UIStoryboard(name: "Main", bundle: nil)
        let theEventDetailController = theStoryboard.instantiateViewController(withIdentifier: "HEEventDetailController") as! HEEventDetailController
        theEventDetailController.theEventItemDict = theItemDict
        theEventDetailController.theDelegate = self

        self.navigationController?.pushViewController(theEventDetailController, animated: true)
        
    }
    
    // MARK: HEEventDetailControllerDelegate
    
    func didFavoriteOrUnfavoriteEvent() {
        
        self.theTableView.reloadData()
    }
    
    // MARK: UISearchBarDelegate
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        
        self.view.endEditing(true)
        
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        
        self.isSearchingText(text: searchText)
        
    }
    
    func isSearchingText(text: String) {
        
        let theEncodedSearchText = text.addingPercentEncoding(withAllowedCharacters: CharacterSet.urlQueryAllowed)
        let theURLString = String(format: "https://api.seatgeek.com/2/events?client_id=NzYxNTE1fDE1MDE1OTYyODQuNTI&q=%@", (theEncodedSearchText)!) as URLConvertible
    
        Alamofire.request(theURLString).responseJSON { response in
            
            if let JSON = response.result.value {
                
                let theDictObject = JSON as! NSDictionary
                let theEventsArrary = theDictObject.object(forKey: "events") as! NSArray
                
                self.theDataSourceArray = theEventsArrary
                self.theTableView.reloadData()
                
            }
        }
        
    }
}
