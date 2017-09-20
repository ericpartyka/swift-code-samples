//
//  ADSearchViewController.swift
//  Drafthouse
//
//  Created by Eric Partyka on 9/11/17.
//  Copyright © 2017 SocialSell LLC. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON

class ADSearchViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UISearchBarDelegate {

    // MARK: Properties
    
    @IBOutlet var theSearchBar: UISearchBar!
    @IBOutlet var theTableView: UITableView!
    var theDatasourceArray: NSArray!
    
    // MARK: View Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        self.configureView()
        self.configureNavBar()
        self.configureXIBs()
        self.configureSearchBar()
    }
    
    // MARK: Memory Management

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: Private Methods
    
    // set any view display properties, colors, or custom interactions here
    
    func configureView() {
        
        self.theTableView.tableFooterView = UIView()
        self.theTableView.separatorInset = UIEdgeInsets.zero
    }
    
    // set any navigation bar display properties, titles, or custom interactions here
    
    func configureNavBar() {
        
        self.navigationItem.title = NSLocalizedString("Drathouse Search", comment: "Search controller nav bar title")
        self.navigationController?.navigationBar.isTranslucent = false
        let theColor = UIColor(colorLiteralRed: 149.0/255.0, green: 22.0/255.0, blue: 1.0/255.0, alpha: 1)
        self.navigationController?.navigationBar.barTintColor = theColor
        
        let theTitleAttrDict = [NSForegroundColorAttributeName: UIColor.white]
        self.navigationController?.navigationBar.titleTextAttributes = theTitleAttrDict
        
    }
    
    // register any uitableviewcell classes & xibs needed for the search table view
    
    func configureXIBs() {
        
        self.theTableView.register(UITableViewCell.self, forCellReuseIdentifier: "UITableViewCell")
    }
    
    // set any search bar display properties, titles, or custom interactions here
    
    func configureSearchBar() {
        
        self.theSearchBar.placeholder = NSLocalizedString("Search place by name...", comment: "Search bar placeholder text")
        self.theSearchBar.keyboardAppearance = UIKeyboardAppearance.dark
        self.theSearchBar.enablesReturnKeyAutomatically = false
        self.theSearchBar.returnKeyType = UIReturnKeyType.done
        
    }
    
    // retrieve results from network manager by taking in the searched text from the search bar
    // if results exsist, set the deta source and reload the table view
    
    func configureDatasource(urlStringPath: String, query: String) {
    
        let paramaeters: [String: String] = ["q": query]
        
        ADNetworkManager.get(urlStringPath, parameters: paramaeters as [String : AnyObject], success: {(result: NSDictionary) -> Void in
        
            let myJSON = JSON(result)
            
            if let results = myJSON["results"].arrayObject {
                
                self.theDatasourceArray = results as NSArray
                
                DispatchQueue.main.async {
                    
                    self.theTableView.reloadData()
                }
            }
            
        }, failure: {(error: NSDictionary?) -> Void in
            
        })
    
    }
    
    // MARK: UITableViewDataSource
    
    func numberOfSections(in tableView: UITableView) -> Int {
        
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        if (self.theDatasourceArray != nil) && self.theDatasourceArray.count > 0 {
            
            return self.theDatasourceArray.count
        }
        else
        {
            return 0
        }
    }
    
    // MARK: UITableViewDelegate
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "UITableViewCell", for: indexPath)
        self.configureCell(cell: cell, indexPath: indexPath)
        
        return cell

    }
    
    func configureCell(cell: UITableViewCell, indexPath: IndexPath) {
        
        cell.textLabel?.font = UIFont.systemFont(ofSize: 12)
        cell.textLabel?.textColor = UIColor.darkGray
        
        let theJSONObject = JSON(self.theDatasourceArray.object(at: indexPath.row))
        
        if let formatted = theJSONObject["formatted"].string {
            
            cell.textLabel?.text = formatted
        }
        else
        {
            cell.textLabel?.text = ""
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        tableView.deselectRow(at: indexPath, animated: true)
        
        let theJSONObject = JSON(self.theDatasourceArray.object(at: indexPath.row))
        let storyboard = UIStoryboard(name: "Main", bundle: Bundle.main)
        let detailController = storyboard.instantiateViewController(withIdentifier: "ADDetailViewController") as! ADDetailViewController
        detailController.resultsModel = theJSONObject
        self.navigationController?.pushViewController(detailController, animated: true)
        
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        return 60
    }
    
    // MARK: UISearchBarDelegate

    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        
        self.view.endEditing(true)
    }
    
    // searching should be throttled in this method
    // searches should not excede 1 query per second
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        
        NSObject.cancelPreviousPerformRequests(withTarget: self, selector: #selector(self.didFetchResultsWithQuery(queryString:)), object: nil)
        self.perform(#selector(self.didFetchResultsWithQuery(queryString:)), with: searchText, afterDelay: 1.0)
    }
    
    // this function is a helper function that will start to retreive results from the API when searching
    
    func didFetchResultsWithQuery(queryString: String) {

        self.configureDatasource(urlStringPath: "", query: queryString)
    }

}
