//
//  MapsIndoorsDirections.swift
//  MapsIndoors Template - IOS
//
//  Created by Christian Wolf Johannsen on 25/11/2021.
//

import Foundation
import MapsIndoors
import SwiftUI

class MapsIndoorsDirections  {
    func getDirectionsFrom(origin: MPLocation?, toDestination: MPLocation?, accessibilityUserRole: MPUserRole?, useAccessibility: Bool, completion: @escaping (MPRoute?, Error?) -> Void) {
        if let fromLocation = origin, let toLocation = toDestination {
            let directionsQuery = MPDirectionsQuery(origin: fromLocation, destination: toLocation)
            if useAccessibility {
                directionsQuery.avoidWayTypes = [.stairs, .escalator]
                if let userRole = accessibilityUserRole {
                    directionsQuery.userRoles = (MapsIndoors.userRoles ?? []) + [userRole]
                }
            }
            
            MPDirectionsService().routing(with: directionsQuery) { foundRoute, error in
                completion(foundRoute, error)
            }
        }
    }
}

class LegInstructions {
    let route: MPRoute
    let leg: MPRouteLeg
    let endLocation: MPLocation?
    var legIndex: Int
    let unitFormatter = MeasurementFormatter()

    init(route: MPRoute, leg: MPRouteLeg, endLocation: MPLocation?) {
        self.route = route
        self.leg = leg
        self.endLocation = endLocation
        legIndex = route.legs?.indexOfObjectIdentical(to: leg) ?? 0

        unitFormatter.numberFormatter.maximumFractionDigits = 0
        unitFormatter.unitOptions = .naturalScale
        unitFormatter.unitStyle = .long
    }
    
    func buildingAt(point: MPPoint) -> MPBuilding? {
        let data = MPVenueProvider.getDataFrom(point)
        return data?["building"] as? MPBuilding
    }
    
    var description: String {
        var desc: String
        
        if isApproachingDestination {
            desc = "Walk to \(endLocationName)"
        } else {
            if isStayingInside {
                if highway == .footway || highway == .residential {
                    if startLevel == endLevel {
                        desc = "Continue on \(endAddress)"
                    } else {
                        desc = "Walk from \(startAddress) to \(endAddress)"
                    }
                } else {
                    desc = "Take \(highway.rawValue) to \(endAddress)"
                }
            } else if isExitingBuilding {
                desc = "Exit \(thisLegBuilding?.name ?? "")"
            } else {
                desc = "Enter \(nextLegBuilding?.name ?? "")"
            }
        }
        
        return desc
    }

    var distance: Int {
        leg.distance?.intValue ?? 0
    }
    
    var distanceDescription: String {
        let measure = Measurement(value: leg.distance?.doubleValue ?? 0, unit: UnitLength.meters)
        return unitFormatter.string(from: measure)
    }
    
    var duration: Int {
        leg.duration?.intValue ?? 0
    }
    
    var durationDescription: String {
        let measure = Measurement(value: leg.duration?.doubleValue ?? 0, unit: UnitDuration.seconds)
        return unitFormatter.string(from: measure)
    }
    
    private var endAddress: String {
        nextLeg.end_address ?? endLevel
    }
    
    private var endLevel: String {
        nextLegLastStep.start_location?.floor_name ?? nextLegLastStep.start_location?.zLevel?.stringValue ?? ""
    }
    
    private var endLocationName: String {
        endLocation?.name ?? "destination"
    }
    
    private var firstStep: MPRouteStep {
        leg.steps?.firstObject as! MPRouteStep
    }

    private var highway: MPHighwayType {
        nextLegFirstStep.highway ?? .footway
    }
    
    var icon: Image {
        var iconName = ""
        if isApproachingDestination {
            iconName = "Location"
        } else if isStayingInside {
            switch highway {
            case .elevator, .wheelChairLift:
                iconName = "Elevator"
            case .escalator, .wheelChairRamp:
                iconName = "Escalator"
            case .stairs, .ladder:
                iconName = "Stairs"
            default:
                iconName = "Walk"
            }
        } else if isEnteringBuilding {
            iconName = "Enter"
        } else if isExitingBuilding {
            iconName = "Exit"
        }
        return Image(iconName)
    }
    
    private var isApproachingDestination: Bool {
        legIndex == route.legs!.count - 1
    }
    
    private var isEnteringBuilding: Bool {
        thisLegBuilding == nil && nextLegBuilding != nil
    }
    
    private var isExitingBuilding: Bool {
        thisLegBuilding != nil && nextLegBuilding == nil
    }
    
    private var isStayingInside: Bool {
        thisLegBuilding != nil && nextLegBuilding != nil
    }
    
    private var lastStep: MPRouteStep {
        leg.steps?.lastObject as! MPRouteStep
    }
    
    private var nextLeg: MPRouteLeg {
        route.legs?.object(at: legIndex + 1) as! MPRouteLeg
    }
    
    private var nextLegBuilding: MPBuilding? {
        buildingAt(point: nextLegLastStep.getStartPoint()!)
    }
    
    private var nextLegFirstStep: MPRouteStep {
        nextLeg.steps?.firstObject as! MPRouteStep
    }
    
    private var nextLegLastStep: MPRouteStep {
        nextLeg.steps?.lastObject as! MPRouteStep
    }
    
    private var startAddress: String {
        leg.start_address ?? startLevel
    }

    private var startLevel: String {
        nextLegFirstStep.start_location?.floor_name ?? nextLegFirstStep.start_location?.zLevel?.stringValue ?? ""
    }

    private var thisLegBuilding: MPBuilding? {
        buildingAt(point: lastStep.getStartPoint()!)
    }
}
