//
//  TFYSwiftCustomController.swift
//  TFYSwiftBannerScroll
//
//  Created by 田风有 on 2021/5/30.
//

import UIKit

class TFYSwiftCustomController: UIViewController {

    private let W_W = UIScreen.main.bounds.size.width
    private let H_H = UIScreen.main.bounds.size.height
    
    fileprivate let imageNames = ["1.jpg","2.jpg","3.jpg","4.jpg","5.jpg","6.jpg","7.jpg","01.jpg","02.jpg","03.jpg","04.jpg","05.jpg","06.jpg"]
    
    lazy var pageView: TFYSwiftPagerView = {
        var pageView = TFYSwiftPagerView(frame: CGRect(x: 0, y: 88 + 54, width: W_W, height: H_H - 100 - 88 - 54))
        pageView.register(TFYSwiftCustomViewCell.self, forCellWithReuseIdentifier: "TFYSwiftCustomViewCell")
        pageView.delegate = self
        pageView.dataSource = self
        pageView.transformer = TFYSwiftPagerViewTransformer(type: .linear)
        pageView.itemSize = CGSize(width: W_W - 100, height:  H_H - 100 - 88 - 54)
        pageView.backgroundColor = .white
        return pageView
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.view.backgroundColor = .blue
        
        self.view.addSubview(self.pageView)
        
    }

}

extension TFYSwiftCustomController: TFYSwiftPagerViewDelegate,TFYSwiftPagerViewDataSource {
    
    func numberOfItems(in pagerView: TFYSwiftPagerView) -> Int {
        return imageNames.count
    }
    
    func pagerView(_ pagerView: TFYSwiftPagerView, cellForItemAt index: Int) -> TFYSwiftPagerViewCell {
        let cell = pageView.dequeueReusableCell(withReuseIdentifier: "TFYSwiftCustomViewCell", at: index) as? TFYSwiftCustomViewCell
        cell!.image = imageNames[index]
        return cell!
    }
}
