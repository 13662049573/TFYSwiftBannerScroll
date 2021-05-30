//
//  TFYSwiftCustomViewCell.swift
//  TFYSwiftBannerScroll
//
//  Created by 田风有 on 2021/5/30.
//

import UIKit

public class TFYSwiftCustomViewCell: TFYSwiftPagerViewCell {

    lazy var icoimageView: UIImageView  = {
        let ico = UIImageView(frame: CGRect(x: 0, y: 0, width: bounds.width, height: bounds.height))
        return ico
    }()
    
    lazy var label: UILabel = {
        let lab = UILabel(frame: CGRect(x: 20, y: 20, width: bounds.width - 40, height: 30))
        lab.text = "测试数据"
        lab.textColor = .orange
        lab.textAlignment = .center
        lab.font = UIFont.systemFont(ofSize: 13)
        return lab
    }()
    
    lazy var btn: UIButton = {
        let button = UIButton(type: .custom)
        button.frame = CGRect(x: bounds.width/4, y: bounds.height - 80, width: bounds.width/2, height: 30)
        button.setTitle("立即购买", for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 12)
        button.backgroundColor = .red
        button.layer.cornerRadius = 15
        button.layer.masksToBounds = true
        return button
    }()
    
    public required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        contentView.addSubview(icoimageView)
        icoimageView.addSubview(label)
        icoimageView.addSubview(btn)
    }
    
    var image: String? {
        didSet {
            icoimageView.image = UIImage(named: image!)
            label.text = "----\(String(describing: image))"
        }
    }
}
