//
//  GeolocationService.swift
//  RxExample
//
//  Created by Carlos García on 19/01/16.
//  Copyright © 2016 Krunoslav Zaher. All rights reserved.
//

import Foundation
import CoreLocation
#if !RX_NO_MODULE
    import RxCocoa
#endif

class GeolocationService {
    
    static let instance = GeolocationService()
    private (set) var autorized: Driver<Bool>
    private (set) var location: Driver<CLLocationCoordinate2D>
    
    private let locationManager = CLLocationManager()
    
    private init() {
        locationManager.distanceFilter = kCLDistanceFilterNone;
        locationManager.desiredAccuracy = kCLLocationAccuracyBestForNavigation;
        
        autorized = locationManager.rx_didChangeAuthorizationStatus
            .startWith(CLLocationManager.authorizationStatus())
            .asDriver(onErrorJustReturn: CLAuthorizationStatus.NotDetermined)
            .map {
                switch $0 {
                case .AuthorizedAlways:
                    return true
                default:
                    return false
                }
            }
        
        location = locationManager.rx_didUpdateLocations
            .asDriver(onErrorJustReturn: [])
            .filter { $0.count > 0 }
            .map { $0.last!.coordinate }
        
        locationManager.requestAlwaysAuthorization()
        locationManager.startUpdatingLocation()
    }
    
}