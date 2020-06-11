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
        //preferLocationList 의 선호장소 의 선택 유뮤에 따라서 장소를 검색 시작
        
        preferLocationList?.forEach {
            if $0.selection == true {
                
                switch $0.title {
                    // title 이 coffee일경우 커피숍 검색
                case .coffee:
                    self.getNearPlaces(type: "cafe", centerLocation: centerCoordination)
                    // title 이 restaurant일경우 레스토랑 검색
                case .restaurant:
                    self.getNearPlaces(type: "restaurant", centerLocation: centerCoordination)
                default:
                    // title 이 transit일경우 버스와 지하철을 검색
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
        // 네트워크 라이브러리인 Alamofire 를 사용해서 url로 리퀘스트 해서 리스폰스를 json으로 받음
        Alamofire.request(url, method: .get).validate().responseJSON { [weak self] response in
            //response 가 성곡적으로 왔는지 파악
            guard response.result.isSuccess else {
                // 받지 못했다면 에러를 로그에 찍고 끝냄
                print("\(String(describing:response.result.error))")
                
                return
            }
            
            do {
                // result json 을 앱에서 사용할수있는 데이터 구조체인 PlaceData으로 디코딩함
                let result = try JSONDecoder().decode(PlaceData.self, from: response.data!)
                
                //placeData 의 results 가 값이 비어있으면 끝냄 아니면 데이터를 처리함
                guard let placeData = result.results else { return }
                //기본 마커 값 검은색으로 설정
                var markerColor: UIColor = UIColor.black
                
                
                if type == "restaurant" {
                    //레스토랑 데이터가 있을경우 저장하고 마커를 빨간색으로 변경
                    self?.currentRestaurntData = placeData
                    markerColor = UIColor.red
                } else if type == "cafe" {
                    //카페 데이터가 있을경우 저장하고 마커를 갈색으로 변경
                    self?.currentCafeData = placeData
                    markerColor = UIColor.brown
                } else {
                    //버스 지하철 데이터가 있을경우 저장하고 마커를 초록색으로 변경
                    if self?.currentTransitData.isEmpty == false {
                        self?.currentTransitData.append(contentsOf: placeData)
                    } else {
                        self?.currentTransitData = placeData
                    }
                    
                    markerColor = UIColor.green
                }
                
                print("placeData: \(placeData)")
                
                for result in placeData {
                    //받아온 데이터 만큼 지도에 마커를 찍어줌 
                    
                    guard let location = result.geometry?.location else { return }
                    guard let name = result.name else { return }
                    
                    let marker = GMSMarker(position: CLLocationCoordinate2D(latitude: location.lat ?? 0, longitude: location.lng ?? 0))
                    marker.snippet = name
                    marker.icon = GMSMarker.markerImage(with: markerColor)
                    marker.map = self?.mapView
                }
                
            } catch {
                return
            }
            
        }
    }
    
}
