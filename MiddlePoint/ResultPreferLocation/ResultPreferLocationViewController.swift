//
//  ShowPreferLocationViewController.swift
//  MiddlePoint
//
//  Created by 장윤혁 on 2020/06/07.
//  Copyright © 2020 yoonhyuk. All rights reserved.
//

import UIKit
import GoogleMaps
import GooglePlaces
import Alamofire

class ResultPreferLocationViewController: UIViewController, CLLocationManagerDelegate, GMSMapViewDelegate {
    var geocoder: GMSGeocoder! // Google API 로 주소 -> 좌표, 좌표 -> 주소 로 바꾸기위한 모듈
    var searchAddressModel: SearchAddressModel? // 나의 위치 정보를 담을 변수
    var centerCoordination: CLLocationCoordinate2D?
    var mapView: GMSMapView!
    var marker: GMSMarker!
    var circle: GMSCircle!
    var placeClient: GMSPlacesClient!
    var place: GMSPlace!
    var preferLocationList: [(title:PreferType, selection: Bool)]?
    let locationManager = CLLocationManager()
    
    var currentTransitData: [PlaceDataResults] = []
    var currentRestaurntData: [PlaceDataResults] = []
    var currentCafeData: [PlaceDataResults] = []
    
    var searchRadius: Double = 1000 {
        didSet {
            circle.radius = searchRadius
        }
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setMapView()
        
        guard let centerCoordination = centerCoordination else  { return }
        preferLocationList?.forEach {
            if $0.selection == true {
                switch $0.title {
                case .coffee:
                    self.getNearPlaces(type: "cafe", centerLocation: centerCoordination)
                case .restaurant:
                    self.getNearPlaces(type: "restaurant", centerLocation: centerCoordination)
                default:
                    self.getNearPlaces(type: "bus_station", centerLocation: centerCoordination)
                    self.getNearPlaces(type: "subway_station", centerLocation: centerCoordination)
                }
            }
        }
    }
    
    func setMapView() {
       guard let centerCoordination = centerCoordination else  { return }
        mapView = GMSMapView()
        marker = GMSMarker(position: centerCoordination)
        marker.icon = GMSMarker.markerImage(with: UIColor(red: 102/244, green: 65/244, blue: 241/244, alpha: 1))
        marker.map = mapView
        circle = GMSCircle(position: centerCoordination, radius: searchRadius)
        circle.fillColor = UIColor(red: 102/244, green: 65/244, blue: 241/244, alpha: 0.2)
        circle.map = mapView;
        
        let camera = GMSCameraPosition.camera(withLatitude: centerCoordination.latitude, longitude: centerCoordination.longitude, zoom: 16)
        mapView.camera = camera
        mapView.settings.myLocationButton = true
        mapView.isMyLocationEnabled = true
        self.mapView.delegate = self
        self.view = mapView
        
    }
    
    func getNearPlaces(type: String, centerLocation: CLLocationCoordinate2D) {
        guard let url = URL(string:
            "https://maps.googleapis.com/maps/api/place/nearbysearch/json?location=\(centerLocation.latitude),\(centerLocation.longitude)&radius=\(searchRadius)&type=\(type)&key=AIzaSyCoIL-hzWRe6fnwdCNMIVWvBPteQxI48nc") else { return }
        
        Alamofire.request(url, method: .get).validate().responseJSON { response in
            guard response.result.isSuccess else {
                print("Error while fetching remote rooms: \(String(describing:response.result.error))")
                
                return
            }
            
            do {
                let result = try JSONDecoder().decode(PlaceData.self, from: response.data!)
                
                guard let placeData = result.results else { return }
                var markerColor: UIColor = UIColor.black
                
                if type == "restaurant" {
                    self.currentRestaurntData.append(contentsOf: placeData)
                    markerColor = UIColor.red
                } else if type == "cafe" {
                    self.currentCafeData.append(contentsOf: placeData)
                    markerColor = UIColor.brown
                } else {
                    self.currentTransitData.append(contentsOf: placeData)
                    markerColor = UIColor.green
                }
                
                print("placeData: \(placeData)")
                
                for result in placeData {
                    guard let location = result.geometry?.location else { return }
                    guard let name = result.name else { return }
                    
                    let marker = GMSMarker(position: CLLocationCoordinate2D(latitude: location.lat ?? 0, longitude: location.lng ?? 0))
                    marker.snippet = name
                    marker.icon = GMSMarker.markerImage(with: markerColor)
                    marker.map = self.mapView
                }
                
            } catch {
                return
            }
            
        }
    }
    
}
