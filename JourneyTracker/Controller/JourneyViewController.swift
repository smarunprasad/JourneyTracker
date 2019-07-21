//
//  SecondViewController.swift
//  JourneyTracker
//
//  Created by Arunprasat Selvaraj on 15/07/2019.
//  Copyright © 2019 Arunprasat Selvaraj. All rights reserved.
//

import UIKit

class JourneyViewController: UIViewController {

    var journeyDataSource = JourneyDataSource()

    @IBOutlet weak var tableView: UITableView! {
        didSet {
            self.tableView.dataSource = journeyDataSource
        }
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        
 
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
        setUpUI()
        setUpModel()
    }
    func setUpUI() {
        
        self.tableView.estimatedRowHeight = 200
        self.tableView.rowHeight = UITableView.automaticDimension
        self.tableView.tableFooterView = UIView()
        self.tableView.register(UINib.init(nibName: JourneyTableViewCell.identifier, bundle: nil), forCellReuseIdentifier: JourneyTableViewCell.identifier)
    }
    
    func setUpModel() {
        
        journeyDataSource.journeyListData = KeychainManager.getALLDataFromWapper()
        
        DispatchQueue.main.async {
            
            UIView.transition(with: self.tableView, duration: 1.0, options: .transitionCrossDissolve, animations: {
                self.tableView.reloadData()
            }, completion: nil)
        }
    }
    
    func moveToMapScreen(trackingModel: TrackingModel) {
        
        let viewController: TrackingViewController = UIStoryboard.init(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "TrackingViewController") as! TrackingViewController
        viewController.trackingModel = trackingModel
        
        self.navigationController?.pushViewController(viewController, animated: true)
    }
}

extension JourneyViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        tableView.deselectRow(at: indexPath, animated: true)
        moveToMapScreen(trackingModel: journeyDataSource.journeyListData[indexPath.row])
    }
}

