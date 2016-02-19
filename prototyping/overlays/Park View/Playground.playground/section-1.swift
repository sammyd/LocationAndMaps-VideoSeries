import UIKit
import MapKit

/************************ Models ************************/
class PVPark {
  var boundary: [CLLocationCoordinate2D]
  var boundaryPointsCount: NSInteger
  
  var midCoordinate: CLLocationCoordinate2D
  var overlayTopLeftCoordinate: CLLocationCoordinate2D
  var overlayTopRightCoordinate: CLLocationCoordinate2D
  var overlayBottomLeftCoordinate: CLLocationCoordinate2D
  var overlayBottomRightCoordinate: CLLocationCoordinate2D {
    get {
      return CLLocationCoordinate2DMake(overlayBottomLeftCoordinate.latitude,
        overlayTopRightCoordinate.longitude)
    }
  }
  
  var overlayBoundingMapRect: MKMapRect {
    get {
      let topLeft = MKMapPointForCoordinate(overlayTopLeftCoordinate);
      let topRight = MKMapPointForCoordinate(overlayTopRightCoordinate);
      let bottomLeft = MKMapPointForCoordinate(overlayBottomLeftCoordinate);
      
      return MKMapRectMake(topLeft.x,
        topLeft.y,
        fabs(topLeft.x-topRight.x),
        fabs(topLeft.y - bottomLeft.y))
    }
  }
  
  var name: String?
  
  init(filename: String) {
    let filePath = NSBundle.mainBundle().pathForResource(filename, ofType: "plist")
    let properties = NSDictionary(contentsOfFile: filePath!)
    
    let midPoint = CGPointFromString(properties!["midCoord"] as String)
    midCoordinate = CLLocationCoordinate2DMake(CLLocationDegrees(midPoint.x), CLLocationDegrees(midPoint.y))
    
    let overlayTopLeftPoint = CGPointFromString(properties!["overlayTopLeftCoord"] as String)
    overlayTopLeftCoordinate = CLLocationCoordinate2DMake(CLLocationDegrees(overlayTopLeftPoint.x),
      CLLocationDegrees(overlayTopLeftPoint.y))
    
    let overlayTopRightPoint = CGPointFromString(properties!["overlayTopRightCoord"] as String)
    overlayTopRightCoordinate = CLLocationCoordinate2DMake(CLLocationDegrees(overlayTopRightPoint.x),
      CLLocationDegrees(overlayTopRightPoint.y))
    
    let overlayBottomLeftPoint = CGPointFromString(properties!["overlayBottomLeftCoord"] as String)
    overlayBottomLeftCoordinate = CLLocationCoordinate2DMake(CLLocationDegrees(overlayBottomLeftPoint.x),
      CLLocationDegrees(overlayBottomLeftPoint.y))
    
    let boundaryPoints = properties!["boundary"] as NSArray
    
    boundaryPointsCount = boundaryPoints.count
    
    boundary = []
    
    for i in 0...boundaryPointsCount-1 {
      let p = CGPointFromString(boundaryPoints[i] as String)
      boundary += [CLLocationCoordinate2DMake(CLLocationDegrees(p.x), CLLocationDegrees(p.y))]
    }
  }
}

let park = PVPark(filename: "MagicMountain")

class PVCharacter: MKCircle, MKOverlay {
  
  var name: String?
  var color: UIColor?
  
}
let filename = "hey"
let filePath = NSBundle.mainBundle().pathForResource(filename, ofType: "plist")


// Test MKOverlay instantiator and optional variables
let character = PVCharacter(centerCoordinate: CLLocationCoordinate2DMake(0, 0), radius: CLLocationDistance(50))
character.name = "Hey"
character.color = UIColor.blackColor()

/*********************** Overlays ***********************/
class PVMarkMapOverlay: NSObject, MKOverlay {
  
  var coordinate: CLLocationCoordinate2D
  var boundingMapRect: MKMapRect
  
  init(park: PVPark) {
    boundingMapRect = park.overlayBoundingMapRect
    coordinate = park.midCoordinate
  }
}

let pvParkMapOverlay = PVMarkMapOverlay(park: park)

class PVParkMapOverlayView: MKOverlayRenderer {
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

let magicMountainImage = UIImage(named: "overlay_park")
let pvParkMapOverlayView = PVParkMapOverlayView(overlay:pvParkMapOverlay, overlayImage: magicMountainImage!)

/********************** Annotations **********************/
enum PVAttractionType: Int {
  case PVAttractionDefault = 0
  case PVAttractionRide
  case PVAttractionFood
  case PVAttractionFirstAid
}

class PVAttractionAnnotation: NSObject, MKAnnotation {
  var coordinate: CLLocationCoordinate2D
  var title: String
  var subtitle: String
  var type: PVAttractionType
  
  init(coordinate: CLLocationCoordinate2D, title: String, subtitle: String, type: PVAttractionType) {
    self.coordinate = coordinate
    self.title = title
    self.subtitle = subtitle
    self.type = type
  }
}

let sampleCoord = CLLocationCoordinate2DMake(0, 0)
let sampleTitle = "Title"
let sampleSubtitle = "Subitle"
let sampleType = PVAttractionType.PVAttractionDefault
let pvAttractionAnnotation = PVAttractionAnnotation(coordinate: sampleCoord, title: sampleTitle, subtitle: sampleSubtitle, type: sampleType)

class PVAttractionAnnotationView: MKAnnotationView {
  
  // Required for MKAnnotationView
  required init(coder aDecoder: NSCoder) {
    super.init(coder: aDecoder)
  }
  
  // Called when drawing the PVAttractionAnnotationView
  override init(frame: CGRect) {
    super.init(frame: frame)
  }
  
  override init(annotation: MKAnnotation, reuseIdentifier: String) {
    super.init(annotation: annotation, reuseIdentifier: reuseIdentifier)
    let attractionAnnotation = self.annotation as PVAttractionAnnotation
    switch (attractionAnnotation.type) {
    case .PVAttractionFirstAid:
      image = UIImage(named: "firstaid")
    case .PVAttractionFood:
      image = UIImage(named: "food")
    case .PVAttractionRide:
      image = UIImage(named: "ride")
    default:
      image = UIImage(named: "star")
    }
  }
}
let pvAttractionAnnotationView = PVAttractionAnnotationView(annotation: pvAttractionAnnotation, reuseIdentifier: "Attraction")

/********************** Swift specaific method **********************/
// Verifying that filter will remove an option
let array1 = [1, 2]

let array2 = array1.filter {(currentOption) in currentOption != 2}
array2
