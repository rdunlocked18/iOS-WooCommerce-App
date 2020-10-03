//
//  MapsViewController.swift
//  Universal
//
//  Created by Mark on 13/02/2019.
//  Copyright © 2019 Sherdle. All rights reserved.
//

import Foundation
import GoogleMaps
import MapKit

class MapsViewController: UIViewController, GMSMapViewDelegate {
    @IBOutlet var mapView_: GMSMapView!
    var loadingIndicator: UIActivityIndicatorView?
    
    var params: NSArray!
    private var parser: GMUGeoJSONParser?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        mapView_.isMyLocationEnabled = true
        mapView_.settings.compassButton = true
        mapView_.delegate = self
        
        if !((params[0] as! String).hasPrefix("http")) {
            
            let path = Bundle.main.path(forResource: params[0] as? String, ofType: "geojson", inDirectory: "Local")
            let url = URL(fileURLWithPath: path ?? "")
            parser = GMUGeoJSONParser(url: url)
            parseAndDisplay()
        } else {
            let url = URL(string: params[0] as? String ?? "")
            print("Retrieving geojson from url: \(params[0])")
            
            loadingIndicator = UIActivityIndicatorView(style: .white)
            loadingIndicator?.startAnimating()
            navigationItem.titleView = loadingIndicator
            
            let session = URLSession.shared
            if let url = url {
                (session.dataTask(with: url, completionHandler: { data, response, error in
                    DispatchQueue.main.async(execute: {
                        self.navigationItem.titleView = nil
                        
                        if error != nil {
                            if let error = error {
                                print("Error retreiving geojson: \(error)")
                            }
                            
                            let alertController = UIAlertController(title: NSLocalizedString("error", comment: ""), message: AppDelegate.NO_CONNECTION_TEXT, preferredStyle: .alert)
                            
                            let ok = UIAlertAction(title: NSLocalizedString("ok", comment: ""), style: .default, handler: nil)
                            alertController.addAction(ok)
                            self.present(alertController, animated: true)
                        } else {
                            if let data = data {
                                self.parser = GMUGeoJSONParser(data: data)
                            }
                            self.parseAndDisplay()
                        }
                    })
                    
                })).resume()
            }
        }
    }
        
    func parseAndDisplay() {
        parser?.parse()
        let renderer = GMUGeometryRenderer(map: mapView_, geometries: parser!.features)
        renderer.render()
        
        //Copy the properties found in the parser to the GMS objects on the map
        let overlays = renderer.mapOverlays()
        
        for overlay: GMSOverlay in overlays {
            if let feature = parser!.features[(overlays as NSArray).index(of: overlay)] as? GMUFeature {
                if ((feature.geometry as? GMUPoint) == nil) { continue }
                if let properties = feature.properties {
                    overlay.userData = properties
                    if properties["name"] != nil {
                        overlay.title = properties["name"]
                    }
                }
            }
        }
        
        focusMapToShowAllMarkers()

    }
    
    func mapView(_ mapView: GMSMapView, didTapInfoWindowOf marker: GMSMarker) {
        if (marker.userData! as! [String: String])["url"] != nil {
            AppDelegate.openUrl(url: (marker.userData! as! [String: String])["url"], withNavigationController: navigationController)
        }
    }
    
    func mapView(_ mapView: GMSMapView, didCloseInfoWindowOf marker: GMSMarker) {
        navigationController?.navigationBar.topItem?.rightBarButtonItems = nil
    }
    
    func mapView(_ mapView: GMSMapView, didTap marker: GMSMarker) -> Bool {
        marker.appearAnimation = GMSMarkerAnimation.pop
        mapView_.selectedMarker = marker
        if let data = marker.userData as? [String: String]{
            if data["snippet"] != nil {
                marker.snippet = data["snippet"]
            } else if data["description"] != nil {
                marker.snippet = data["description"]
            } else if data["popupContent"] != nil {
                marker.snippet = data["popupContent"]
            }
        }
        mapView_.moveCamera(GMSCameraUpdate.setTarget(marker.position))
       // mapView_.animate(withCameraUpdate: GMSCameraUpdate.setTarget(marker.position))
        
        //Init navigationbar items
        let searchButton = UIBarButtonItem(image: UIImage(named: "btn_navigate"), style: .plain, target: self, action: #selector(MapsViewController.navigateTo))
        if (marker.userData! as! [String: String])["url"] != nil {
            let openButton = UIBarButtonItem(title: NSLocalizedString("open", comment: ""), style: .plain, target: self, action: #selector(MapsViewController.openUrl))
            navigationController?.navigationBar.topItem?.rightBarButtonItems = [searchButton, openButton]
        } else {
            navigationController?.navigationBar.topItem?.rightBarButtonItem = searchButton
        }
        
        
        return true
    }
    
    func mapView(_ mapView: GMSMapView, didTap overlay: GMSOverlay) {
        //NSLog(@"Tapped overlay %@", overlay);
    }
    
    func focusMapToShowAllMarkers() {
        var bounds = GMSCoordinateBounds()
        
        for feature in parser!.features  {
            if (feature.geometry is GMUPoint) {
                bounds = bounds.includingCoordinate(((feature.geometry as? GMUPoint)?.coordinate)!)
            }
        }
        mapView_.moveCamera(GMSCameraUpdate.fit(bounds, withPadding: 100.0))
        //mapView_.animate(withCameraUpdate: GMSCameraUpdate.fit(bounds, withPadding: 100.0))
    }

    @objc func openUrl() {
        AppDelegate.openUrl(url: (mapView_.selectedMarker!.userData as! [String: String])["url"], withNavigationController: navigationController)
    }

    @objc func navigateTo() {
        let coordinate = mapView_.selectedMarker?.position
        
        let mapItemClass = MKMapItem.self
        if mapItemClass.responds(to: #selector(MKMapItem.openMaps(with:launchOptions:))) {
            // Create an MKMapItem to pass to the Maps app
            let placemark = MKPlacemark(coordinate: coordinate!, addressDictionary: nil)
            let mapItem = MKMapItem(placemark: placemark)
            mapItem.name = mapView_.selectedMarker!.title
            // Pass the map item to the Maps app
            mapItem.openInMaps(launchOptions: nil)
        }
    }
}
