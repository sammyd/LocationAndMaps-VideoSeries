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
import CoreLocation

class DirectionsViewController: UIViewController {
  
  @IBOutlet weak var mapView: MKMapView!
  @IBOutlet weak var totalTimeLabel: UILabel!
  @IBOutlet weak var directionsTableView: DirectionsTableView!
  
  var activityIndicator: UIActivityIndicatorView?
  var locationArray: [(textField: UITextField!, mapItem: MKMapItem?)]!
  
  override func viewDidLoad() {
    super.viewDidLoad()
    directionsTableView.contentInset = UIEdgeInsetsMake(-36, 0, -20, 0)
    addActivityIndicator()
    calculateSegmentDirections(0, time: 0, routes: [])
  }
  
  func addActivityIndicator() {
    activityIndicator = UIActivityIndicatorView(frame: UIScreen.mainScreen().bounds)
    activityIndicator?.activityIndicatorViewStyle = .WhiteLarge
    activityIndicator?.backgroundColor = view.backgroundColor
    activityIndicator?.startAnimating()
    view.addSubview(activityIndicator!)
  }
  
  func hideActivityIndicator() {
    if activityIndicator != nil {
      activityIndicator?.removeFromSuperview()
      activityIndicator = nil
    }
  }
  
  override func viewWillAppear(animated: Bool) {
    navigationController?.navigationBarHidden = false
    automaticallyAdjustsScrollViewInsets = false
  }
  
  func calculateSegmentDirections(index: Int,
    var time: NSTimeInterval, var routes: [MKRoute]) {
      
      let request: MKDirectionsRequest = MKDirectionsRequest()
      request.source = locationArray[index].mapItem
      request.destination = locationArray[index+1].mapItem
      request.requestsAlternateRoutes = true
      request.transportType = .Automobile
      
      let directions = MKDirections(request: request)
      directions.calculateDirectionsWithCompletionHandler ({
        (response: MKDirectionsResponse?, error: NSError?) in
        if let routeResponse = response?.routes {
          let quickestRouteForSegment: MKRoute =
          routeResponse.sort({$0.expectedTravelTime <
            $1.expectedTravelTime})[0]
          routes.append(quickestRouteForSegment)
          time += quickestRouteForSegment.expectedTravelTime
          
          if index+2 < self.locationArray.count {
            self.calculateSegmentDirections(index+1, time: time, routes: routes)
          } else {
            self.showRoute(routes, time: time)
            self.hideActivityIndicator()
          }
        } else if let _ = error {
          let alert = UIAlertController(title: nil,
            message: "Directions not available.", preferredStyle: .Alert)
          let okButton = UIAlertAction(title: "OK",
            style: .Cancel) { (alert) -> Void in
              self.navigationController?.popViewControllerAnimated(true)
          }
          alert.addAction(okButton)
          self.presentViewController(alert, animated: true,
            completion: nil)
        }
      })
  }
  
  func showRoute(routes: [MKRoute], time: NSTimeInterval) {
    var directionsArray = [(startingAddress: String, endingAddress: String, route: MKRoute)]()
    for i in 0..<routes.count {
      plotPolyline(routes[i])
      directionsArray += [(locationArray[i].textField.text!,
        locationArray[i+1].textField.text!, routes[i])]
    }
    displayDirections(directionsArray)
    printTimeToLabel(time)
  }
  
  func plotPolyline(route: MKRoute) {
    
    mapView.addOverlay(route.polyline)
    
    if mapView.overlays.count == 1 {
      mapView.setVisibleMapRect(route.polyline.boundingMapRect,
        edgePadding: UIEdgeInsetsMake(10.0, 10.0, 10.0, 10.0),
        animated: false)
    } else {
      let polylineBoundingRect =  MKMapRectUnion(mapView.visibleMapRect,
        route.polyline.boundingMapRect)
      mapView.setVisibleMapRect(polylineBoundingRect,
        edgePadding: UIEdgeInsetsMake(10.0, 10.0, 10.0, 10.0),
        animated: false)
    }
  }
  
  func displayDirections(directionsArray: [(startingAddress: String, endingAddress: String, route: MKRoute)]) {
    directionsTableView.directionsArray = directionsArray
    directionsTableView.delegate = directionsTableView
    directionsTableView.dataSource = directionsTableView
    directionsTableView.reloadData()
  }
  
  func printTimeToLabel(time: NSTimeInterval) {
    let timeString = time.formatted()
    totalTimeLabel.text = "Total Time: \(timeString)"
  }
}

extension DirectionsViewController: MKMapViewDelegate {
  
  func mapView(mapView: MKMapView,
    rendererForOverlay overlay: MKOverlay) -> MKOverlayRenderer {
      let polylineRenderer = MKPolylineRenderer(overlay: overlay)
      if (overlay is MKPolyline) {
        if mapView.overlays.count == 1 {
          polylineRenderer.strokeColor =
            UIColor.blueColor().colorWithAlphaComponent(0.75)
        } else if mapView.overlays.count == 2 {
          polylineRenderer.strokeColor =
            UIColor.greenColor().colorWithAlphaComponent(0.75)
        } else if mapView.overlays.count == 3 {
          polylineRenderer.strokeColor =
            UIColor.redColor().colorWithAlphaComponent(0.75)
        }
        polylineRenderer.lineWidth = 5
      }
      return polylineRenderer
  }
}
