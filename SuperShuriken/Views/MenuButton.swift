//
//  MenuButton.swift
//  SuperShuriken
//
//  Created by Martin Peshevski on 4/24/19.
//  Copyright © 2019 MP. All rights reserved.
//

import UIKit
import SnapKit

class MenuButton: UIButton {
    
    lazy var loadingIndicator: UIActivityIndicatorView = {
        let view = UIActivityIndicatorView(activityIndicatorStyle: .white)
        view.isHidden = true

        return view
    }()
    
    override init(frame: CGRect = .zero) {
        super.init(frame: frame)
        
        self.setBackgroundImage(UIImage(named: "ic_button"), for: .normal)
        self.setBackgroundImage(UIImage(named: "ic_button_clicked"), for: .highlighted)
        self.titleLabel?.font = (UIFont.systemFont(ofSize: 20))
        self.setTitleColor(.white, for: .normal)
        contentHorizontalAlignment = .left
        contentEdgeInsets = UIEdgeInsets(top: 0, left: 30, bottom: 0, right: 0)
        
        addSubview(loadingIndicator)
        snp.makeConstraints { make in
            make.width.equalTo(300)
            make.height.equalTo(50)
        }
        loadingIndicator.snp.makeConstraints { make in
            make.right.equalToSuperview().inset(30)
            make.centerY.equalToSuperview()
        }
    }
    
    func setLoading(_ isLoading: Bool) {
        isUserInteractionEnabled = !isLoading
        isLoading ? loadingIndicator.startAnimating() : loadingIndicator.stopAnimating()
        loadingIndicator.isHidden = !isLoading
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
