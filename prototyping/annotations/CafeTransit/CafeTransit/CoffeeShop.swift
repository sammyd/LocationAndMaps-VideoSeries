/*
* Copyright (c) 2015 Razeware LLC
*
* Permission is hereby granted, free of charge, to any person obtaining a copy
* of this software and associated documentation files (the "Software"), to deal
* in the Software without restriction, including without limitation the rights
* to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
* copies of the Software, and to permit persons to whom the Software is
* furnished to do so, subject to the following conditions:
*
* The above copyright notice and this permission notice shall be included in
* all copies or substantial portions of the Software.
*
* THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
* IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
* FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
* AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
* LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
* OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
* THE SOFTWARE.
*/

import UIKit
import CoreLocation
import Contacts

struct CoffeeShop {
  let name: String
  let priceGuide: PriceGuide
  let location: CLLocationCoordinate2D
  let details: String
  let rating: CoffeeRating
  let yelpWebsite: String
  let openTime: NSDate
  let closeTime: NSDate
  let phone: String
  var addressDictionary: [String: AnyObject] {
    return [CNPostalAddressStreetKey: name]
  }
  
  static var timeZone = NSTimeZone(abbreviation: "PST")!
  
  /// Calculates whether a coffee shop is currently open for business
  var isOpenNow: Bool {
    let calendar = NSCalendar.currentCalendar()
    let nowComponents = calendar.componentsInTimeZone(CoffeeShop.timeZone, fromDate: NSDate())
    
    let openTimeComponents = calendar.components([.Hour, .Minute], fromDate: openTime)
    let closeTimeComponents = calendar.components([.Hour, .Minute], fromDate: closeTime)
    
    let isEarlier = nowComponents.hour < openTimeComponents.hour || (nowComponents.hour == openTimeComponents.hour && nowComponents.minute < openTimeComponents.minute)
    let isLater = nowComponents.hour > closeTimeComponents.hour || (nowComponents.hour == closeTimeComponents.hour && nowComponents.minute > closeTimeComponents.minute)
    
    return !(isEarlier || isLater)
  }
  
  init?(dictionary: [String : AnyObject]) {
    guard let name = dictionary["name"] as? String,
      let phone = dictionary["phone"] as? String,
      let yelpWebsite = dictionary["yelpWebsite"] as? String,
      let priceGuideRaw = dictionary["priceGuide"] as? Int,
      let priceGuide = PriceGuide(rawValue: priceGuideRaw),
      let details = dictionary["details"] as? String,
      let ratingRaw = dictionary["rating"] as? Int,
      let latitude = dictionary["latitude"] as? Double,
      let longitude = dictionary["longitude"] as? Double,
      let openTime = dictionary["openTime"] as? NSDate,
      let closeTime = dictionary["closeTime"] as? NSDate,
      let rating = CoffeeRating(value: ratingRaw) else {
        return nil
    }
    
    self.name = name
    self.phone = phone
    self.yelpWebsite = yelpWebsite
    self.priceGuide = priceGuide
    self.details = details
    self.rating = rating
    
    self.location = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
    
    self.openTime = openTime
    self.closeTime = closeTime
  }
  
  static func allCoffeeShops() -> [CoffeeShop] {
    guard let path = NSBundle.mainBundle().pathForResource("sanfrancisco_coffeeshops", ofType: "plist"),
      let array = NSArray(contentsOfFile: path) as? [[String : AnyObject]] else {
        return [CoffeeShop]()
    }
    
    // 1
    let shops = array.flatMap { CoffeeShop(dictionary: $0) }
      .sort { $0.name < $1.name }
    
    // 2
    let first = shops.first!
    let location = CLLocation(latitude: first.location.latitude,
      longitude: first.location.longitude)
    
    // 3
    let geocoder = CLGeocoder()
    geocoder.reverseGeocodeLocation(location) { (placemarks, _) -> Void in
      if let placemark = placemarks?.first, timeZone = placemark.timeZone {
        self.timeZone = timeZone
      }
    }
    
    return shops
  }
}

extension CoffeeShop : CustomStringConvertible {
  var description : String {
    return "\(name): \(details)"
  }
}

enum PriceGuide : Int {
  case Unknown
  case Low
  case Medium
  case High
}

enum CoffeeRating {
  case Unknown
  case Rating(Int)
  
  init?(value: Int) {
    if value > 0 && value <= 5 {
      self = .Rating(value)
    } else {
      self = .Unknown
    }
  }
  
  var value : Int {
    switch self {
    case .Unknown:
      return 0
    case .Rating(let value):
      return value
    }
  }
}
