//
//  AchievementsViewController.swift
//  SuperShuriken
//
//  Created by Martin Peshevski on 5/29/19.
//  Copyright © 2019 MP. All rights reserved.
//

import UIKit

class AchievementsViewControlelr: UIViewController, UITableViewDataSource, UITableViewDelegate {
    var achievementsArray: [Achievement] = []
    
    let backgroundImageView: UIImageView = {
        let image = UIImageView(image: UIImage(named: "splashScreen"))
        image.contentMode = .scaleAspectFill
        
        return image
    }()
    
    lazy var tableView: UITableView = {
        let table = UITableView()
        table.register(AchievementCell.self, forCellReuseIdentifier: "achievementCell")
        table.dataSource = self
        table.delegate = self
        table.tableFooterView = UIView()
        table.backgroundColor = UIColor.black.withAlphaComponent(0.5)
        table.layer.cornerRadius = 5
        table.layer.borderWidth = 3
        table.layer.borderColor = UIColor.black.cgColor
        table.separatorStyle = .none
        
        return table
    }()
    
    lazy var menuButton: UIButton = {
        let button = UIButton()
        button.setTitle("Menu", for: .normal)
        button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 20)
        button.setTitleColor(.white, for: .normal)
        button.addTarget(self, action: #selector(onMenu), for: .touchUpInside)
        return button
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.addSubview(backgroundImageView)
        backgroundImageView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        self.view.addSubview(tableView)
        tableView.snp.makeConstraints { make in
            make.top.bottom.equalToSuperview().inset(50)
            make.centerX.equalToSuperview()
            make.width.equalToSuperview().multipliedBy(0.5)
        }
        
        self.view.addSubview(menuButton)
        menuButton.snp.makeConstraints { make in
            make.left.top.equalToSuperview().inset(20)
            make.width.equalTo(100)
            make.height.equalTo(50)
        }
        
        loadScores()
    }
    
    func loadScores(){
        GameCenterManager.shared.getAchievements { [weak self] achievements, error in
            guard let self = self, let achievements = achievements, error == nil else { return }
            
            self.achievementsArray = achievements
            self.tableView.reloadData()
        }
    }
    
    @objc func onMenu() {
        dismiss(animated: true, completion: nil)
    }
    
    //MARK: - tableview
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return achievementsArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "achievementCell", for: indexPath) as? AchievementCell else {
            return UITableViewCell()
        }
        cell.achievement = achievementsArray[indexPath.row]
        return cell
    }
}
