//
//  AttractionAnnotation.swift
//  Park View
//
//  Created by Niv Yahel on 2014-10-30.
//  Copyright (c) 2014 Chris Wagner. All rights reserved.
//

import UIKit
import MapKit

enum AttractionType: Int {
  case AttractionDefault = 0
  case AttractionRide
  case AttractionFood
  case AttractionFirstAid
}

class AttractionAnnotation: NSObject, MKAnnotation {
  var coordinate: CLLocationCoordinate2D
  var title: String
  var subtitle: String
  var type: AttractionType
  
  init(coordinate: CLLocationCoordinate2D, title: String, subtitle: String, type: AttractionType) {
    self.coordinate = coordinate
    self.title = title
    self.subtitle = subtitle
    self.type = type
  }
}