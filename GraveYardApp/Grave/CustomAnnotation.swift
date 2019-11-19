
//
//  CustomAnnotation.swift
//  GraveYardApp
//
//  Created by Douglas Patterson on 11/11/19.
//  Copyright © 2019 Tyler Donohue. All rights reserved.
//
import Foundation
import MapKit

class GraveEntryAnnotation: NSObject, MKAnnotation {
    
    var annotation: MKAnnotation
    var coordinate: CLLocationCoordinate2D
    var title: String?
    var subtitle: String?
    
    init(annotation: MKAnnotation, coordinate: CLLocationCoordinate2D, title: String?, subtitle: String?) {
        self.annotation = annotation
        self.coordinate = coordinate
        self.title = title
        self.subtitle = subtitle
    }
}
