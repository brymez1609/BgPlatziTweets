//
//  MapaViewController.swift
//  BgPlatziTweets
//
//  Created by Bryan Andres Gomez Hernandez on 8/26/20.
//  Copyright © 2020 Bryan Andres Gomez Hernandez. All rights reserved.
//

import UIKit
import MapKit
class MapaViewController: UIViewController {
    // MARK: - IBOutlets
    @IBOutlet weak var mapContainter: UIView!
    
    
    //MARK: Properties
    var posts = [Post]()
    private var map: MKMapView?
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
    }
    override func viewDidAppear(_ animated: Bool) {
        setupMap()
    }
    
    private func setupMap(){
        map = MKMapView(frame: mapContainter.bounds)
        mapContainter.addSubview(map ?? UIView())
        setupMarkers()
    }
    
    private func setupMarkers(){
        posts.forEach { (post) in
            let marker = MKPointAnnotation()
            marker.coordinate = CLLocationCoordinate2D(latitude: post.location.latitude, longitude: post.location.longitude)
            marker.title = post.text
            marker.subtitle = post.author.names
            map?.addAnnotation(marker)
        }
        
        guard let lastPost = posts.last else {
            return
        }
        guard let heading = CLLocationDirection(exactly: 12) else {
            return
        }
        let lastPostLocation = CLLocationCoordinate2D(latitude: lastPost.location.latitude, longitude: lastPost.location.longitude)
        map?.camera = MKMapCamera(lookingAtCenter: lastPostLocation, fromDistance: 30, pitch: .zero, heading: heading)
    }
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
