//
//  FindPreferLocationViewController.swift
//  MiddlePoint
//
//  Created by 장윤혁 on 2020/05/22.
//  Copyright © 2020 yoonhyuk. All rights reserved.
//

import UIKit
import CoreLocation

class FindPreferLocationViewController: UIViewController {
    var myCoordination: CLLocationCoordinate2D? // 나의 위치 정보를 담을 변수
    var friendsCoordinations: [CLLocationCoordinate2D] = [] // 친구들의 위치정보를 담을 배열 변수
    var myAddress: String = "" // 내 주소를 담을 변수
    var friendsAddress: [String] = [] // 친구들의 주소를 담을 배열 변수
    
    override func viewDidLoad() {
        super.viewDidLoad()

    }
    
    
    

}
