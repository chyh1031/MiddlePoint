//
//  FindPreferLocationViewController.swift
//  MiddlePoint
//
//  Created by 장윤혁 on 2020/05/22.
//  Copyright © 2020 yoonhyuk. All rights reserved.
//

import UIKit
import CoreLocation

enum PreferType: String {
    case transit = "지하철, 버스정류장"
    case coffee = "카페"
    case restaurant = "레스토랑"
}

class FindPreferLocationViewController: UIViewController {
    var searchAddressModel: SearchAddressModel? // 나의 위치 정보를 담을 변수
    var centerCoordination: CLLocationCoordinate2D?
    var polygonArea: PolygonArea = PolygonArea()
    var isGetCenter: Bool = false
    var isSelectedtCenter: Bool = false
    var preferLocationList: [(title:PreferType, selection: Bool)] = [(title: PreferType.transit, selection: false), (title: .coffee, selection: false), (title: .restaurant, selection: false)]
    
    @IBOutlet weak var preferTableView: UITableView!
    @IBOutlet weak var resultButton: UIButton!
    
    @IBAction func resultButtonDidTap(_ sender: Any) {
        if isGetCenter == false {
            getCentCoordination()
        } else {
            if isSelectedtCenter == false {
                let alert = UIAlertController(title: "", message: "선호장소를 선택해주세요.",preferredStyle: .alert)
                let okAction = UIAlertAction(title: "확인", style: UIAlertAction.Style.default)
                
                alert.addAction(okAction)
                present(alert, animated: true, completion: nil)
            } else {
                guard let centerCoordination = centerCoordination else { return }
                
                let resultViewController = storyboard?.instantiateViewController(withIdentifier: "ResultPreferLocationViewController") as! ResultPreferLocationViewController
                
                resultViewController.searchAddressModel = searchAddressModel
                resultViewController.centerCoordination = centerCoordination
                resultViewController.preferLocationList = preferLocationList
                navigationController?.pushViewController(resultViewController, animated: true)
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setPreferTableView()
        getCentCoordination()
        
    }
    
    func setPreferTableView() {
        preferTableView.delegate = self
        preferTableView.dataSource = self
    }
    
    func getCentCoordination() {
        resultButton.setTitle("중간 위치를 알아오는중..", for: .normal)
        
        guard let searchAddressModel = searchAddressModel else { return }
        var wholeCoordinations =  searchAddressModel.friendsCoordinations
        
        wholeCoordinations.append(searchAddressModel.myCoordination)
        
        polygonArea.polygonCenterOfMass(polygon: wholeCoordinations) { success, centerCoordination in
            if success == true {
                guard let centerCoordination = centerCoordination else { return }
                
                self.centerCoordination = centerCoordination
                self.isGetCenter = true
                self.resultButton.setTitle("결과 보기", for: .normal)
            } else {
                self.isGetCenter = false
                self.resultButton.setTitle("중간위치를 다시불러오시겠습니까?", for: .normal)
            }
        }
    }
    
}

extension FindPreferLocationViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return preferLocationList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "FindPreferLocationTableViewCell", for: indexPath) as! FindPreferLocationTableViewCell
        cell.preferLocationLabel.text = preferLocationList[indexPath.row].title.rawValue
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, willSelectRowAt indexPath: IndexPath) -> IndexPath? {
        if tableView.cellForRow(at: indexPath)?.accessoryType == .checkmark {
            tableView.cellForRow(at: indexPath)?.accessoryType = .none
            preferLocationList[indexPath.row].selection = false
        } else {
            tableView.cellForRow(at: indexPath)?.accessoryType = .checkmark
            preferLocationList[indexPath.row].selection = true
        }
        

        let preferTrueCount = preferLocationList.filter { $0.selection == true }.count
        
        if preferTrueCount > 0 {
            isSelectedtCenter = true
        } else {
            isSelectedtCenter = false
        }
        
        return indexPath
    }
    
    
}

