//
//  HEEventDetailController.swift
//  Homeaway Events
//
//  Created by Eric Partyka on 8/1/17.
//  Copyright © 2017 SocialSell LLC. All rights reserved.
//

import UIKit
import SDWebImage

protocol HEEventDetailControllerDelegate: class {

    func didFavoriteOrUnfavoriteEvent()
    
}


class HEEventDetailController: UIViewController {
    
    public var theEventItemDict = NSDictionary()
    weak var theDelegate: HEEventDetailControllerDelegate?
    
    @IBOutlet var theImageView: UIImageView!
    @IBOutlet var theEventTitleLabel: UILabel!
    @IBOutlet var theEventLocationLabel: UILabel!
    @IBOutlet var theEventTimestampLabel: UILabel!
    
    // MARK: - View Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        
        self.configureImageView()
        self.configureView()
        self.configureNavBar()
        self.configureNavBarItems()
    }
    
    // MARK: - Memory Management
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - Private Methods
    
    func configureImageView() {
        
        self.theImageView.layer.masksToBounds = true
        self.theImageView.layer.cornerRadius = 10
        
    }
    
    func configureView() {
        

        let thePerformsArray = self.theEventItemDict.object(forKey: "performers") as! NSArray
        let thePerformersObject = thePerformsArray.firstObject as! NSDictionary
        
        if let theImageString = thePerformersObject.object(forKey: "image") as? String
        {
            let theURL = URL(string: theImageString)
            
            self.theImageView.sd_setImage(with: theURL, placeholderImage: UIImage(named: "EventPlaceholder"))
        }
        else
        {
            self.theImageView.image = UIImage(named: "EventPlaceholder")
        }
        
        if let theTimestamp = theEventItemDict.object(forKey: "datetime_utc") as? String
        {
            self.theEventTimestampLabel.text = theTimestamp
        }
        else
        {
            self.theEventTimestampLabel.text = nil
        }
        
        let theTitleString = String(format: "%@", self.theEventItemDict.object(forKey: "title") as! CVarArg)
        let theVenueDict = theEventItemDict.object(forKey: "venue") as! NSDictionary
        let theLocationString = String(format: "%@", theVenueDict.object(forKey: "display_location") as! CVarArg)
        
        self.theEventTitleLabel.text = theTitleString
        self.theEventLocationLabel.text = theLocationString
        
    }
    
    func configureNavBar() {
        
        let theTitleString = String(format: "%@", self.theEventItemDict.object(forKey: "title") as! CVarArg)
        self.navigationItem.title = theTitleString
    
    }
    
    func configureNavBarItems() {
        
        let theIdString = String(format: "%@", self.theEventItemDict.object(forKey: "id") as! CVarArg)
        
        if HECacheUtil.doesCacheContainObjectForKey(theKey: theIdString)
        {
            self.navigationItem.rightBarButtonItem?.tintColor = UIColor.red
        }
        else
        {
            self.navigationItem.rightBarButtonItem?.tintColor = UIColor.white
        }
    }
    
    
    // MARK: - Actions
    
    @IBAction func didPressBackButton(_ sender: Any) {
        
        self.navigationController?.popViewController(animated: true)
        
    }
    
    @IBAction func didPressRightBarButtoItem(_ sender: Any) {
        
        let theIdString = String(format: "%@", self.theEventItemDict.object(forKey: "id") as! CVarArg)
        
        if HECacheUtil.doesCacheContainObjectForKey(theKey: theIdString)
        {
            HECacheUtil.didRemoveObjectForKey(theKey: theIdString)
        }
        else
        {
            HECacheUtil.didCacheObjectWithKey(theObject: self.theEventItemDict, theKey: theIdString)
        }
        
        self.configureNavBarItems()
        theDelegate?.didFavoriteOrUnfavoriteEvent()
    }
}
