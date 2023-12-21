//
//  Pointer.swift
//  BreweriesList
//
//  Created by DimMac on 20.12.2023.
//

import Foundation
import MapKit

class MapPointer: NSObject, MKAnnotation {
  let title: String?
  let coordinate: CLLocationCoordinate2D

  init(
    title: String?,
    coordinate: CLLocationCoordinate2D
  ) {
    self.title = title
    self.coordinate = coordinate
    super.init()
  }
}
