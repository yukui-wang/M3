//
//  CMPLBSHelper.swift
//  M3
//
//  Created by Kaku Songu on 9/19/22.
//

import Foundation
import CoreLocation

class CMPLBSHelper:CMPObject{
    @objc public class func isInCircleScope(_ cusLocation:CLLocation?,_ relatedByLocation:CLLocation?,_ distance:Double) -> Bool {
        if cusLocation == nil || relatedByLocation == nil {
            return false
        }
        if distance < 0 {
            return false
        }
        let aDis:CLLocationDistance = cusLocation!.distance(from: relatedByLocation!)
        return aDis <= distance
    }
}
