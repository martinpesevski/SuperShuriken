//
//  SwitchView.swift
//  SuperShuriken
//
//  Created by Martin Peshevski on 4/25/19.
//  Copyright © 2019 MP. All rights reserved.
//

import UIKit
import SnapKit

protocol ToggleViewDelegate: class {
    func onToggle(sender: ToggleView, selected: Bool)
}

class ToggleView: UIView {
    weak var delegate: ToggleViewDelegate?
    
    lazy var toggle: UISwitch = {
        let tog = UISwitch()
        tog.tintColor = .red
        tog.addTarget(self, action: #selector(onToggle(sender:)), for: .valueChanged)
        
        return tog
    }()
    
    lazy var titleLabel: UILabel = {
        let title = UILabel()
        title.font = UIFont.systemFont(ofSize: 20)
        title.textColor = .white
        title.textAlignment = .left
        
        return title
    }()
    
    lazy var container: UIStackView = {
        let stack = UIStackView(arrangedSubviews: [titleLabel, toggle])
        stack.axis = .horizontal
        stack.distribution = .fill
        
        return stack
    }()
    
    init(title: String) {
        super.init(frame: .zero)

        titleLabel.text = title
        addSubview(container)
        container.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }
    
    @objc func onToggle(sender: UISwitch){
        delegate?.onToggle(sender: self, selected: sender.isOn)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
