//
//  PhotoMapViewController.swift
//  Photo Map
//
//  Created by Nicholas Aiwazian on 10/15/15.
//  Copyright © 2015 Timothy Lee. All rights reserved.
//

import UIKit
import MapKit

class PhotoMapViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate, LocationViewControllerDelegate, MKMapViewDelegate {
    
    @IBOutlet weak var mapView: MKMapView!
    var imagePicker = UIImagePickerController()
    var editedImage = UIImage()

    override func viewDidLoad() {
        super.viewDidLoad()
        imagePicker.delegate = self
        imagePicker.allowsEditing = true
        mapView.delegate = self
        // Do any additional setup after loading the view.
        let sfRegion = MKCoordinateRegionMake(CLLocationCoordinate2DMake(37.783333, -122.4146667), MKCoordinateSpanMake(0.1, 0.1))
        mapView.setRegion(sfRegion, animated: true)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    @IBAction func takePhotoClicked(_ sender: Any) {
        if UIImagePickerController.isSourceTypeAvailable(.camera) {
            imagePicker.sourceType = .camera
        }
        else {
            imagePicker.sourceType = .photoLibrary
        }
        self.present(imagePicker, animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        let editedImg = info[UIImagePickerControllerEditedImage] as! UIImage
        editedImage = editedImg
        dismiss(animated: true) {
            self.performSegue(withIdentifier: "tagSegue", sender: self)
        }
    }
    
    func locationsPickedLocation(controller: LocationsViewController, latitude: NSNumber, logitude: NSNumber) {
        //add annotation with text
        let annotation = MKPointAnnotation()
        annotation.coordinate = CLLocationCoordinate2DMake(Double(latitude), Double(logitude))
        annotation.title = "Picture"
        mapView.addAnnotation(annotation)
        
        self.navigationController?.popToViewController(self, animated: true)
    }
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        // add image to annotation
        let reuseID = "myAnnotationView"
        var annotationView = mapView.dequeueReusableAnnotationView(withIdentifier: reuseID)
        if annotationView == nil {
//            annotationView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: reuseID)
            annotationView = MKAnnotationView(annotation: annotation, reuseIdentifier: reuseID)
            annotationView!.canShowCallout = true
            annotationView!.leftCalloutAccessoryView = UIImageView(frame: CGRect(x:0, y:0, width: 50, height:50))
            
        }
        let imageView = annotationView!.leftCalloutAccessoryView as! UIImageView
        
        let resizeRenderImageView = UIImageView(frame: CGRect(x: 0, y: 0, width: 45, height: 45))
        resizeRenderImageView.layer.borderColor = UIColor.white.cgColor
        resizeRenderImageView.layer.borderWidth = 3.0
        resizeRenderImageView.contentMode = .scaleAspectFit
        resizeRenderImageView.image = editedImage
        
        UIGraphicsBeginImageContext(resizeRenderImageView.frame.size)
        resizeRenderImageView.layer.render(in: UIGraphicsGetCurrentContext()!)
        let thumbnail = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        // add button on the right side
        let buttonDetailView = UIButton(type: .detailDisclosure)
        annotationView?.rightCalloutAccessoryView = buttonDetailView

        imageView.image = thumbnail
        annotationView?.image = thumbnail
        return annotationView
    }
    
    func mapView(_ mapView: MKMapView, annotationView view: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
        performSegue(withIdentifier: "fullImageSegue", sender: self)
    }
    
    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "tagSegue" {
            let vc = segue.destination as! LocationsViewController
            vc.delegate = self
        }
        else if segue.identifier == "fullImageSegue" {
            let vc = segue.destination as! FullImageViewController
            vc.image = editedImage
        }
    }
    

}

class PhotoAnnotation: NSObject, MKAnnotation {
    var coordinate: CLLocationCoordinate2D = CLLocationCoordinate2DMake(0, 0)
    var photo: UIImage!
    
    var title: String? {
        return "\(coordinate.latitude)"
    }
}


