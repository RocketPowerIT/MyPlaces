//
//  MapViewController.swift
//  MyPlaces
//
//  Created by wolfyteze on 17/10/2020.
//  Copyright © 2020 wolfyteze. All rights reserved.
//

import UIKit
import MapKit
import CoreLocation

class MapViewController: UIViewController {

    var place = Place()
    let annotashionIdentifier = "annotashionIdentifier"
    let locationManager = CLLocationManager()
    let regionInMeters = 10_000.00
    var incomeSegueIdentifier = ""
    
    @IBOutlet var adressLabel: UILabel!
    @IBOutlet var mapView: MKMapView!
    @IBOutlet var doneButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        mapView.delegate = self
        setupMapView()
        checkLocationAutorization()
    }
    
    @IBOutlet var mapPinImage: UIImageView!
    
    @IBAction func centerViewInUserLocation() {
        
       showUserLoacation()
    }
    
    @IBAction func doneButtonPressed() {
        
        
    }
    @IBAction func closeVC() {
        dismiss(animated: true)
    }
    
    private func setupMapView(){
        
        if incomeSegueIdentifier == "showMap" {
            setupPlaceMark()
            mapPinImage.isHidden = true
            adressLabel.isHidden = true
            doneButton.isHidden = true
        }
    }
    
    private func setupPlaceMark(){
        guard let location = place.location else { return }
        let geocoder = CLGeocoder()
        geocoder.geocodeAddressString(location) { (placemarks, error) in
            if let error=error {
                print(error)
                return
            }
            
            guard let placemarks = placemarks else { return }
            
            let placemark = placemarks.first
            
            let anotation = MKPointAnnotation()
            anotation.title = self.place.name
            anotation.subtitle = self.place.type
            
            guard let placemarkLocation = placemark?.location else { return }
            anotation.coordinate = placemarkLocation.coordinate
            
            self.mapView.showAnnotations([anotation], animated: true)
            self.mapView.selectAnnotation(anotation, animated: true)
        }
        
    }
    
    private func checkLocationServices() {
        
        if CLLocationManager.locationServicesEnabled() {
            setupLocationManager()
            checkLocationAutorization()
            
        } else {
            //Show alert Controller
        }
    }
    
    private func setupLocationManager() {
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
    }
    
    private func checkLocationAutorization() {
        switch CLLocationManager.authorizationStatus() {
        case .authorizedWhenInUse:
            mapView.showsUserLocation = true
            if incomeSegueIdentifier == "getAdress" {
                showUserLoacation()
            }
            break
        case .denied:
            //Show Alert Controller
            break
        case .notDetermined:
            locationManager.requestWhenInUseAuthorization()
            break
        case .restricted:
             //Show Alert Controller
            break
        case .authorizedAlways:
            break
        @unknown default:
            print("New Case is Availible")
        }
    }
    
    private func showUserLoacation() {
        
        if let location = locationManager.location?.coordinate {
                   let region = MKCoordinateRegion(center: location,
                                                   latitudinalMeters: regionInMeters,
                                                   longitudinalMeters: regionInMeters)
                   mapView.setRegion(region, animated: true)
               }
    }
}

extension MapViewController: MKMapViewDelegate{
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        guard !(annotation is MKUserLocation) else { return nil }
        
        var annotationView = mapView.dequeueReusableAnnotationView(withIdentifier: annotashionIdentifier) as? MKPinAnnotationView
        
        if annotationView == nil {
            annotationView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: annotashionIdentifier)
            annotationView?.canShowCallout = true
        }
        
        if let imageData = place.imageData {
            let imageView = UIImageView(frame: CGRect(x: 0, y: 0, width: 50, height: 50))
            imageView.layer.cornerRadius = 10
            imageView.clipsToBounds = true
            imageView.image = UIImage(data: imageData)
            annotationView?.rightCalloutAccessoryView = imageView
        }
        
        return annotationView
    }
}

extension MapViewController: CLLocationManagerDelegate {
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        checkLocationAutorization()
    }
}
