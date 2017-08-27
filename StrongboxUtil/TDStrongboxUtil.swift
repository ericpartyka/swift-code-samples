//
//  TDStrongboxUtil.swift
//  TweetDrop Today
//
//  Created by Eric Partyka on 8/8/17.
//  Copyright © 2017 SocialSell LLC. All rights reserved.
//

import UIKit
import Strongbox

class TDStrongboxUtil: NSObject {
    
    class func didStoreObjectForKey(theTokenString: String, theKey: String) -> Void {
        
        let theStronbox = Strongbox()
        theStronbox.archive(theTokenString, key: theKey)
    }
    
    class func didGetObjectForKey(theKey: String) -> Any {
     
        let theStronbox = Strongbox()
        let theObject = theStronbox.unarchive(objectForKey: theKey)
        
        return theObject
    }
    
    class func isObjectValidForKey(theKey: String) -> Bool {
        
        let theStrongbox = Strongbox()
        
        let theObject = theStrongbox.unarchive(objectForKey: theKey)
    
        if theObject != nil
        {
            return true
        }
        else
        {
            return false
        }
    }
    
    class func theAccessTokenString() -> String {
        
        if self.isObjectValidForKey(theKey: "access_token")
        {
            
            let theTokenString = self.didGetObjectForKey(theKey: "access_token") as! String
        
            return theTokenString
        }
        else
        {
            return ""
        }
        
    }
    
}
