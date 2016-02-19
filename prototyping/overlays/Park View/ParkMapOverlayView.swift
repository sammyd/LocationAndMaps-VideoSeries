//
//  ParkMapOverlayView.swift
//  Park View
//
//  Created by Niv Yahel on 2014-10-30.
//  Copyright (c) 2014 Chris Wagner. All rights reserved.
//

import UIKit
import MapKit

class ParkMapOverlayView: MKOverlayRenderer {
  var overlayImage: UIImage
  
  init(overlay:MKOverlay, overlayImage:UIImage) {
    self.overlayImage = overlayImage
    super.init(overlay: overlay)
  }
  
  override func drawMapRect(mapRect: MKMapRect, zoomScale: MKZoomScale, inContext context: CGContext!) {
    let imageReference = overlayImage.CGImage
    
    let theMapRect = overlay.boundingMapRect
    let theRect = self.rectForMapRect(theMapRect)
    
    CGContextScaleCTM(context, 1.0, -1.0)
    CGContextTranslateCTM(context, 0.0, -theRect.size.height)
    CGContextDrawImage(context, theRect, imageReference)
  }
}