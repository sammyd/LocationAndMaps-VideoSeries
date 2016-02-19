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
import MapKit

class ViewController: UIViewController {
  
  lazy var locationManager = CLLocationManager()
  var currentUserLocation: CLLocationCoordinate2D?
  
  @IBOutlet var mapView: MKMapView!
    
  override func viewDidLoad() {
    super.viewDidLoad()
    
    setupMap()
    addMapData()

    locationManager.delegate = self
    locationManager.desiredAccuracy = kCLLocationAccuracyHundredMeters
  }
  
  override func viewDidAppear(animated: Bool) {
    super.viewDidAppear(animated)
    requestUserLocation()
  }
  
  private func setupMap() {
    mapView.showsScale = true
    
    let sanFrancisco = CLLocationCoordinate2D(latitude: 37.7833, longitude: -122.4167)
    centerMap(mapView, atPosition: sanFrancisco)
  }
  
  private func addMapData() {
    for coffeeshop in CoffeeShop.allCoffeeShops() {
      let annotation = CoffeeShopPin(coffeeshop: coffeeshop)
      mapView.addAnnotation(annotation)
    }
  }
  
  private func centerMap(map: MKMapView?, atPosition position: CLLocationCoordinate2D?) {
    guard let map = map, let position = position else {
      return
    }
    
    map.setCenterCoordinate(position, animated: true)
    
    let zoomRegion = MKCoordinateRegionMakeWithDistance(position, 10000, 10000)
    map.setRegion(zoomRegion, animated: true)
  }
  
  private func requestUserLocation() {
    mapView.showsUserLocation = true //1
    if CLLocationManager.authorizationStatus() ==
      .AuthorizedWhenInUse { // 2
        locationManager.requestLocation()   // 3
    } else {
      locationManager.requestWhenInUseAuthorization()   // 4
    }
  }
}

// MARK:- MKMapViewDelegate
extension ViewController: MKMapViewDelegate {
  func mapView(mapView: MKMapView, viewForAnnotation annotation: MKAnnotation) -> MKAnnotationView? {
    guard let annotation = annotation as? CoffeeShopPin else {
      return nil
    }
    
    let identifier = "CoffeeShopPinDetailView"
    
    var annotationView = mapView.dequeueReusableAnnotationViewWithIdentifier(identifier) as? MKPinAnnotationView
    
    if annotationView == nil {
      annotationView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: identifier)
      annotationView!.canShowCallout = true
    }
    
    annotationView!.annotation = annotation
    
    if annotation.coffeeshop.rating.value == 5 {
      annotationView!.pinTintColor =
        UIColor(red:1, green:0.79, blue:0, alpha:1)
    } else {
      annotationView!.pinTintColor =
        UIColor(red:0.419, green:0.266, blue:0.215, alpha:1)
    }
    
    let detailView =
    UIView.loadFromNibNamed(identifier) as! CoffeeShopPinDetailView
    detailView.coffeeShop = annotation.coffeeshop
    annotationView!.detailCalloutAccessoryView = detailView
    
    return annotationView
  }
  
  func mapView(mapView: MKMapView,
    didSelectAnnotationView view: MKAnnotationView) {
      if let detailView =
        view.detailCalloutAccessoryView as? CoffeeShopPinDetailView {
          detailView.currentUserLocation = currentUserLocation
      }
  }
}

// MARK:- CLLocationManagerDelegate
extension ViewController: CLLocationManagerDelegate {
  
  func locationManager(manager: CLLocationManager, didChangeAuthorizationStatus status: CLAuthorizationStatus) {
    if (status == CLAuthorizationStatus.AuthorizedAlways || status == CLAuthorizationStatus.AuthorizedWhenInUse) {
      locationManager.requestLocation()
    }
  }
  
  func locationManager(manager: CLLocationManager,
    didUpdateLocations locations: [CLLocation]) {
      currentUserLocation = locations.first?.coordinate
  }
  
  func locationManager(manager: CLLocationManager,
    didFailWithError error: NSError) {
      print("Error finding location: \(error.localizedDescription)")
  }
}

