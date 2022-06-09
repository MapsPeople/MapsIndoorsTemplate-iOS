//
//  GPSPositionProvider.swift
//  MapsIndoorsTemplate
//
//  Created by Christian Wolf Johannsen on 11/06/2022.
//

import Foundation
import MapsIndoors

class GPSPositionProvider: NSObject, MPPositionProvider {
    var delegate: MPPositionProviderDelegate?
    var latestPositionResult: MPPositionResult? = nil
    var locationServicesActive = false  // enabled AND authorized
    var preferAlwaysLocationPermission = false
    var providerType = MPPositionProviderType.GPS_POSITION_PROVIDER

    func startPositioning(_ arg: String?) {
        guard isThisRunning == false else {
            return
        }

        locationManager.delegate = self
        locationManager.distanceFilter = 7
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.headingFilter = 5

        requestLocationPermissions()

        locationManager.startUpdatingLocation()
        locationManager.startUpdatingHeading()

        isThisRunning = true
    }

    func startPositioning(after millis: Int32, arg: String?) {
        DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(Int(millis))) {
            self.startPositioning(nil)
        }
    }

    func stopPositioning(_ arg: String?) {
        guard isThisRunning == true else {
            return
        }

        isThisRunning = false
        locationManager.stopUpdatingLocation()
        locationManager.stopUpdatingHeading()
    }

    func requestLocationPermissions() {
        if preferAlwaysLocationPermission {
            locationManager.requestAlwaysAuthorization()
        } else {
            locationManager.requestWhenInUseAuthorization()
        }
    }

    func updateLocationPermissionStatus() {
        let appLocationServiceStatus = CLLocationManager.authorizationStatus()
        if authorizationStatus != appLocationServiceStatus {
            authorizationStatus = appLocationServiceStatus

            let isActiveNow = appLocationServiceStatus == .authorizedAlways || appLocationServiceStatus == .authorizedWhenInUse
            if isActiveNow != locationServicesActive {
                locationServicesActive = isActiveNow

                if isActiveNow == false {
                    latestPositionResult = nil
                    notifyLatestPositionResult()
                }
            }
        }
    }

    func isRunning() -> Bool {
        return isThisRunning
    }

    // MARK: - Private parts

    private var authorizationStatus = CLAuthorizationStatus.notDetermined
    private var isThisRunning = false
    private lazy var locationManager: CLLocationManager = {
        CLLocationManager()
    }()

    private func notifyLatestPositionResult() {
        if let positionResult = latestPositionResult, let delegate = delegate, delegate.responds(to: #selector(MPPositionProviderDelegate.onPositionUpdate(_:))) {
            delegate.onPositionUpdate(positionResult)
        }
    }
}

// MARK: - CLLocationManagerDelegate methods

extension GPSPositionProvider: CLLocationManagerDelegate {
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        updateLocationPermissionStatus()
    }

    func locationManager(_ manager: CLLocationManager, didUpdateHeading newHeading: CLHeading) {
        if latestPositionResult?.geometry != nil {
            if (0.0...360.0).contains(newHeading.trueHeading) {
                latestPositionResult?.setHeadingDegrees(newHeading.trueHeading)
                latestPositionResult?.headingAvailable = true
                notifyLatestPositionResult()
            }
        }
    }

    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if locations.count > 0 && isThisRunning {
            if let latestLocation = locations.last {
                if latestPositionResult == nil {
                    latestPositionResult = MPPositionResult()
                }

                latestPositionResult?.geometry = MPPoint(lat: latestLocation.coordinate.latitude, lon: latestLocation.coordinate.longitude)
                if (0.0...360.0).contains(latestLocation.course) {
                    latestPositionResult?.setHeadingDegrees(latestLocation.course)
                }
                if let floor = latestLocation.floor {
                    latestPositionResult?.geometry?.setZValue(Double(floor.level))
                }
                latestPositionResult?.setProbability(latestLocation.horizontalAccuracy)
                latestPositionResult?.provider = self

                notifyLatestPositionResult()
            }
        }
    }

    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        if let delegate = delegate, delegate.responds(to: #selector(MPPositionProviderDelegate.onPositionFailed(_:))) {
            delegate.onPositionFailed(self)
        }
    }
}
