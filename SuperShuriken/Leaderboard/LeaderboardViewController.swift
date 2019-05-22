//
//  LeaderboardViewController.swift
//  SuperShuriken
//
//  Created by Martin Peshevski on 5/16/19.
//  Copyright © 2019 MP. All rights reserved.
//

import UIKit
import GameKit

class LeaderboardViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    var scoresArray: [GKScore] = []
    
    let backgroundImageView: UIImageView = {
        let image = UIImageView(image: UIImage(named: "splashScreen"))
        image.contentMode = .scaleAspectFill
        
        return image
    }()
    
    lazy var tableView: UITableView = {
        let table = UITableView()
        table.register(LeaderboardCell.self, forCellReuseIdentifier: "leaderboardCell")
        table.register(SectionHeader.self, forHeaderFooterViewReuseIdentifier: "header")
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
        GameCenterManager.shared.getHighScores { [weak self] scores, error in
            guard let self = self, let scores = scores, error == nil else {
                return
            }
            
            self.scoresArray = scores
            self.tableView.reloadData()
        }
    }
    
    @objc func onMenu() {
        dismiss(animated: true, completion: nil)
    }
    
    //MARK: - tableview
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return scoresArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "leaderboardCell", for: indexPath) as? LeaderboardCell else {
            return UITableViewCell()
        }
        cell.score = scoresArray[indexPath.row]
        return cell
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        guard let view = tableView.dequeueReusableHeaderFooterView(withIdentifier: "header") as? SectionHeader else {
            return UIView()
        }
        
        view.title = "HALL OF FAME"
        return view
    }
}

class SectionHeader: UITableViewHeaderFooterView {
    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.textColor = UIColor.white
        label.font = UIFont.boldSystemFont(ofSize: 25)
        label.textAlignment = .center
        
        return label
    }()
    
    override init(reuseIdentifier: String?) {
        super.init(reuseIdentifier: reuseIdentifier)
        addSubview(titleLabel)
        titleLabel.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }
    
    var title: String? {
        willSet {
            titleLabel.text = newValue
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
