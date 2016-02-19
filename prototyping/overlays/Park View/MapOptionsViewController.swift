//
//  MapOptionsViewController.swift
//  Park View
//
//  Created by Niv Yahel on 2014-10-30.
//  Copyright (c) 2014 Chris Wagner. All rights reserved.
//

import UIKit

enum MapOptionsType: Int {
  case MapBoundary = 0
  case MapOverlay
  case MapPins
  case MapCharacterLocation
  case MapRoute
}

class MapOptionsViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
  
  var selectedOptions = [MapOptionsType]()
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    // Do any additional setup after loading the view.
  }
  
  override func didReceiveMemoryWarning() {
    super.didReceiveMemoryWarning()
    // Dispose of any resources that can be recreated.
  }
  
  func numberOfSectionsInTableView(tableView: UITableView) -> Int {
    return 1
  }
  
  func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return 5
  }
  
  func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
    let cell = tableView.dequeueReusableCellWithIdentifier("OptionCell") as! UITableViewCell
    let mapOptionsType = MapOptionsType(rawValue: indexPath.row)
    switch (mapOptionsType!) {
    case .MapBoundary:
      cell.textLabel!.text = "Park Boundary"
    case .MapOverlay:
      cell.textLabel!.text = "Map Overlay"
    case .MapPins:
      cell.textLabel!.text = "Attraction Pins"
    case .MapCharacterLocation:
      cell.textLabel!.text = "Character Location"
    case .MapRoute:
      cell.textLabel!.text = "Route"
    }
    
    if contains(selectedOptions, mapOptionsType!) {
      cell.accessoryType = UITableViewCellAccessoryType.Checkmark
    } else {
      cell.accessoryType = UITableViewCellAccessoryType.None
    }
    
    return cell
  }
  
  func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
    let cell = tableView.cellForRowAtIndexPath(indexPath)
    let mapOptionsType = MapOptionsType(rawValue: indexPath.row)
    if (cell!.accessoryType == UITableViewCellAccessoryType.Checkmark) {
      cell!.accessoryType = UITableViewCellAccessoryType.None
      // delete object
      selectedOptions = selectedOptions.filter { (currentOption) in currentOption != mapOptionsType}
    } else {
      cell!.accessoryType = UITableViewCellAccessoryType.Checkmark
      selectedOptions += [mapOptionsType!]
    }
    
    tableView.deselectRowAtIndexPath(indexPath, animated: true)
  }
}