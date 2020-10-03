//
//  ConfigParser.swift
//  Universal
//
//  Created by Mark on 26/09/2019.
//  Copyright © 2019 Sherdle. All rights reserved.
//

import Foundation
import SwiftyJSON
import Alamofire

class ConfigParser : NSObject {

    let CACHE_TIME = 60 * 60 * 24
    var delegate:ConfigParserDelegate!

    func parseConfig(file:String!) {
        if !file.hasPrefix("http") {
            let localFileUrl =
                NSURL(fileURLWithPath: Bundle.main.path(forResource: ((file == "") ? "config" : file), ofType: "json", inDirectory:"Local")!)
            self.parseConfigJSON(json: try? Data(contentsOf: localFileUrl as URL))
        } else {
            let cacheConfig = self.loadArrayFromCache()
            if cacheConfig == nil {
                NSLog("Retrieving configuration from url: %@", file)
            
                Alamofire.request(file).responseData { (response) in
                    DispatchQueue.main.async {
                        if let data = response.data {
                            self.parseConfigJSON(json: data)
                        } else if let error = response.error {
                            self.delegate.parseFailed(error: error)
                        }
                    }
                }
            } else {
                self.delegate.parseSuccess(result: cacheConfig)
            }
        }
    }

    func parseConfigJSON(json:Data!) {
        var jsonMenu:JSON?
        do {
            jsonMenu = try JSON(data: json)
        } catch {
            self.delegate.parseFailed(error: error as NSError)
        }

        var sections = [Section]()
        var section: Section?

        for jsonMenuItem in jsonMenu!.arrayValue {
            let menuItem:Item! = Item()

            menuItem.name = jsonMenuItem["title"].stringValue

            var menuTabs = [Tab]()
            for jsonTab in jsonMenuItem["tabs"].arrayValue {
                menuTabs.append(ConfigParser.navItemFromJSON(jsonTab: jsonTab))
             }
            menuItem.tabs = menuTabs

            if jsonMenuItem["drawable"].string != nil
                && !(jsonMenuItem["drawable"].string == "")
                && !(jsonMenuItem["drawable"].string == "0") {
                menuItem.icon = jsonMenuItem["drawable"].stringValue
            }

            var requiresIap:Bool = false
            if jsonMenuItem["iap"].bool != nil
            {requiresIap = jsonMenuItem["iap"].boolValue}
            menuItem.iap = requiresIap

            //Determine the section
            var subMenu = ""
            if jsonMenuItem["submenu"].string != nil
                && !(jsonMenuItem["submenu"].string == "") {
                subMenu = jsonMenuItem["submenu"].stringValue
            }
            //If this is a different section than the previous
            if section == nil || subMenu != section?.name {
                //Clean up previous section
                if section != nil {
                    sections.append(section!)
                }
                //Create the new section
                section = Section()
                section!.name = subMenu
                section!.items = [Item]()
            }
            //Add the item to the section
            section!.items.append(menuItem)
         }

        sections.append(section!)

        self.saveArrayToCache(array: sections)
        self.delegate.parseSuccess(result: sections)
    }

    // Overview
    func parseOverview(fileName:String!) {
        var file = fileName!
        if !file.hasPrefix("http") {

            if file.hasSuffix(".json") {
                file = file.replacingOccurrences(of: ".json", with: "")
            }
            
            let localFileUrl =
            NSURL(fileURLWithPath: Bundle.main.path(forResource: file, ofType: "json", inDirectory:"Local")!)
            self.parseOverviewJSON(json: try? Data(contentsOf: localFileUrl as URL))
        } else {
            NSLog("Retrieving overview from url: %@", file)

            Alamofire.request(file).responseData { (response) in
                DispatchQueue.main.async {
                    if let data = response.data {
                        self.parseOverviewJSON(json: data)
                    } else if let error = response.error {
                        self.delegate.parseFailed(error: error)
                    }
                }
            }
        }
    }

    func parseOverviewJSON(json:Data!) {
        var jsonOverview:JSON?
        do {
            jsonOverview = try JSON(data: json)
        } catch {
            self.delegate.parseFailed(error: error as NSError)
        }

        var overview = [Tab]()
        for jsonOverviewItem in jsonOverview!.arrayValue {
            overview.append(ConfigParser.navItemFromJSON(jsonTab: jsonOverviewItem))
         }

        self.delegate.parseOverviewSuccess(result: overview)
    }

    // Items
    class func navItemFromJSON(jsonTab:JSON!) -> Tab! {
        let item:Tab! = Tab()

        item.name = jsonTab["title"].stringValue
        item.type = jsonTab["provider"].stringValue
        item.params = jsonTab["arguments"].arrayValue.map { $0.stringValue}

        if let image = jsonTab["image"].string {

            item.icon = image

        }

        return item
    }

    func loadArrayFromCache() -> [Section]! {
        guard let documentDirectoryUrl = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first else { return  nil}
        let fileUrl = documentDirectoryUrl.appendingPathComponent("cache.json")

        let attr = try? FileManager.default.attributesOfItem(atPath: fileUrl.path)
        let fileDate = attr?[FileAttributeKey.modificationDate] as? Date
    
        if let fileDate = fileDate, fileDate.addingTimeInterval(TimeInterval(CACHE_TIME)) > Date()
            {
            // Read data from .json file and transform data into an array
            do {
                let data = try Data(contentsOf: fileUrl, options: [])
                let personArray = try JSONDecoder().decode([Section].self, from: data)
                
                return personArray
            } catch {
                print(error)
            }
        }
        
        return nil
    }

    func saveArrayToCache(array:[Section]!) {
        // Get the url of Persons.json in document directory
        guard let documentDirectoryUrl = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first else { return }
        let fileUrl = documentDirectoryUrl.appendingPathComponent("cache.json")

        // Transform array into data and save it into file
        do {
            let data = try JSONEncoder().encode(array)
            try data.write(to: fileUrl, options: [])
        } catch {
            print(error)
        }
    }
}
