//
//  Poligon.swift
//  MiddlePoint
//
//  Created by 장윤혁 on 2020/06/07.
//  Copyright © 2020 yoonhyuk. All rights reserved.
//

import UIKit
import CoreLocation

class PolygonArea {
    func signedPolygonArea(polygon: [CLLocationCoordinate2D]) -> Double {
        let count = polygon.count
        var area: Double = 0
        
        for i in 0 ..< count {
            let j = (i + 1) % count
            area = area + polygon[i].latitude * polygon[j].longitude
            area = area - polygon[i].longitude * polygon[j].latitude
        }
        
        area = area/2.0
        
        return area
    }
    
    func centerByTwoSpot(polygon: [CLLocationCoordinate2D]) -> CLLocationCoordinate2D {
        let centerX = (polygon[0].latitude + polygon[1].latitude) / 2
        let centerY = (polygon[0].longitude + polygon[1].longitude) / 2
        
        return CLLocationCoordinate2D(latitude: centerX, longitude: centerY)
    }
    
    func polygonCenterOfMass(polygon: [CLLocationCoordinate2D], completion: @escaping (Bool, CLLocationCoordinate2D?) -> Void) {
        if polygon.count < 2 {
            completion(false, nil)
        } else if polygon.count == 2 {
            completion(true, centerByTwoSpot(polygon: polygon))
        } else {
            let count = polygon.count
            var centerX: Double = 0
            var centerY: Double = 0
            var area = signedPolygonArea(polygon: polygon)
            
            for i in 0 ..< count {
                let j = (i + 1) % count
                let factor1 = polygon[i].latitude * polygon[j].longitude - polygon[j].latitude * polygon[i].longitude
                centerX = centerX + (polygon[i].latitude + polygon[j].latitude) * factor1
                centerY = centerY + (polygon[i].longitude + polygon[j].longitude) * factor1
            }
            
            area = area * 6.0
            
            let factor2 = 1.0/area
            centerX = centerX * factor2
            centerY = centerY * factor2
            
            if centerX.isNaN || centerY.isNaN {
                completion(false, nil)
            } else {
                let center = CLLocationCoordinate2D(latitude: centerX, longitude: centerY)
                
                completion(true, center)
            }
        }
    }
}
