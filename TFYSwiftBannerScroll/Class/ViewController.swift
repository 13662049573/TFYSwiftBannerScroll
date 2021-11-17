//
//  ViewController.swift
//  TFYSwiftBannerScroll
//
//  Created by 田风有 on 2021/5/19.
//

import UIKit

class ViewController: UIViewController {

   private let W_W = UIScreen.main.bounds.size.width
   private let H_H = UIScreen.main.bounds.size.height
    
    fileprivate let dataSouce = [
        [
            "name": "轮播模式",
            "items": [
                [
                    "name": "渐变浅出"
                ],
                [
                    "name": "缩小"
                ],
                [
                    "name": "POP退出"
                ],
                [
                    "name": "卡片线性 -- 不支持垂直动画"
                ],
                [
                    "name": "卡片重叠 -- 不支持垂直动画"
                ],
                [
                    "name": "上步扇形 -- 不支持垂直动画"
                ],
                [
                    "name": "下部扇形 -- 不支持垂直动画"
                ],
                [
                    "name": "内部折叠 -- 不支持垂直动画"
                ],
                [
                    "name": "立体旋转"
                ]
            ]
        ],
        [
            "name": "指示器位置",
            "items": [
                [
                    "name": "右边"
                ],
                [
                    "name": "居中"
                ],
                [
                    "name": "左边"
                ]
            ]
        ],
        [
            "name": "指示器状态",
            "items": [
                [
                    "name": "默认"
                ],
                [
                    "name": "圆圈镂空"
                ],
                [
                    "name": "自定图片"
                ],
                [
                    "name": "绘制五角星"
                ],
                [
                    "name": "绘制的爱心"
                ]
            ]
        ],
        [
            "name": "其实设置",
            "items": [
                [
                    "name": "轮播大小"
                ],
                [
                    "name": "视图间距"
                ],
                [
                    "name": "指示器大小"
                ],
                [
                    "name": "指示器间距"
                ]
            ]
        ],
        [
            "name": "视图滚动方向 -- 有的动画不支持垂直",
            "items": [
                [
                    "name": "水平"
                ],
                [
                    "name": "垂直"
                ]
            ]
        ]
    ]
    
    fileprivate let imageNames = ["1.jpg","2.jpg","3.jpg","4.jpg","5.jpg","6.jpg","7.jpg","01.jpg","02.jpg","03.jpg","04.jpg","05.jpg","06.jpg"]
    fileprivate var numberOfItems = 7
    fileprivate let transformerTypes: [PagerViewTransformerType] = [.crossFading,
                                                                      .zoomOut,
                                                                      .depth,
                                                                      .linear,
                                                                      .overlap,
                                                                      .ferrisWheel,
                                                                      .invertedFerrisWheel,
                                                                      .coverFlow,
                                                                      .cubic]
    
   
    lazy var pageView: TFYSwiftPagerView = {
        var pageView = TFYSwiftPagerView(frame: CGRect(x: 0, y: 88, width: W_W, height: 200))
        pageView.register(TFYSwiftPagerViewCell.self, forCellWithReuseIdentifier: "pageCell")
        pageView.itemSize = TFYSwiftPagerView.automaticSize
        pageView.delegate = self
        pageView.dataSource = self
        pageView.isInfinite = true
        pageView.automaticSlidingInterval = 3
        return pageView
    }()
    
    
    lazy var pageControl: TFYSwiftPageControl = {
        var pageControl = TFYSwiftPageControl(frame: CGRect(x: 0, y: 200 - 30, width: W_W , height: 40))
        pageControl.numberOfPages = imageNames.count
        pageControl.contentHorizontalAlignment = .right
        pageControl.contentInsets = UIEdgeInsets(top: 0, left: 20, bottom: 0, right: 20)
        pageControl.hidesForSinglePage = true
        return pageControl
    }()
    
    lazy var tabbleView: UITableView = {
        var tableview = UITableView(frame: CGRect(x: 0, y: pageView.frame.maxY, width: W_W, height: H_H - 200 - 88), style: .grouped)
        tableview.showsVerticalScrollIndicator = false
        tableview.showsHorizontalScrollIndicator = false
        tableview.backgroundColor = .white
        tableview.delegate = self
        tableview.dataSource = self
        if #available(iOS 15.0, *) {
            tableview.sectionHeaderTopPadding = 0
        } 
        return tableview
    }()
    
    lazy var slider: UISlider = {
        let slider = UISlider(frame: CGRect(x: 80, y: 0, width: W_W - 100, height: 40))
        slider.tag = 1
        slider.value = {
            let scale: CGFloat = self.pageView.itemSize.width/self.pageView.frame.width
            let value: CGFloat = (0.5-scale)*2
            return Float(value)
        }()
        slider.isContinuous = true
        slider.addTarget(self, action: #selector(sliderValueChanged), for: .valueChanged)
        slider.addTarget(self, action: #selector(sliderValueChanged(_:)), for: .touchUpInside)
        return slider
    }()
    
    lazy var slider2: UISlider = {
        let slider = UISlider(frame: CGRect(x: 80, y: 0, width: W_W - 100, height: 40))
        slider.tag = 2
        slider.value = Float(self.pageView.interitemSpacing/20.0)
        slider.isContinuous = true
        slider.addTarget(self, action: #selector(sliderValueChanged), for: .valueChanged)
        slider.addTarget(self, action: #selector(sliderValueChanged(_:)), for: .touchUpInside)
        return slider
    }()
    
    lazy var slider3: UISlider = {
        let slider = UISlider(frame: CGRect(x: 80, y: 0, width: W_W - 100, height: 40))
        slider.tag = 3
        slider.value = Float((self.pageControl.itemSpacing-6.0)/10.0)
        slider.addTarget(self, action: #selector(sliderValueChanged), for: .valueChanged)
        slider.addTarget(self, action: #selector(sliderValueChanged(_:)), for: .touchUpInside)
        return slider
    }()
    
    lazy var slider4: UISlider = {
        let slider = UISlider(frame: CGRect(x: 80, y: 0, width: W_W - 100, height: 40))
        slider.tag = 4
        slider.value = Float((self.pageControl.interitemSpacing-6.0)/10.0)
        slider.addTarget(self, action: #selector(sliderValueChanged), for: .valueChanged)
        slider.addTarget(self, action: #selector(sliderValueChanged(_:)), for: .touchUpInside)
        return slider
    }()
    
    fileprivate var typeIndex = 0 {
        didSet {
            let type = self.transformerTypes[typeIndex]
            self.pageView.transformer = TFYSwiftPagerViewTransformer(type:type)
            switch type {
            case .crossFading, .zoomOut, .depth:
                self.pageView.itemSize = TFYSwiftPagerView.automaticSize
                self.pageView.decelerationDistance = 1
            case .linear, .overlap:
                let transform = CGAffineTransform(scaleX: 0.6, y: 0.75)
                self.pageView.itemSize = self.pageView.frame.size.applying(transform)
                self.pageView.decelerationDistance = TFYSwiftPagerView.automaticDistance
            case .ferrisWheel, .invertedFerrisWheel:
                self.pageView.itemSize = CGSize(width: 180, height: 140)
                self.pageView.decelerationDistance = TFYSwiftPagerView.automaticDistance
            case .coverFlow:
                self.pageView.itemSize = CGSize(width: 220, height: 170)
                self.pageView.decelerationDistance = TFYSwiftPagerView.automaticDistance
            case .cubic:
                let transform = CGAffineTransform(scaleX: 0.9, y: 0.9)
                self.pageView.itemSize = self.pageView.frame.size.applying(transform)
                self.pageView.decelerationDistance = 1
            }
        }
    }
    
    
    fileprivate var styleIndex = 0 {
        didSet {
            // Clean up
            self.pageControl.setStrokeColor(nil, for: .normal)
            self.pageControl.setStrokeColor(nil, for: .selected)
            self.pageControl.setFillColor(nil, for: .normal)
            self.pageControl.setFillColor(nil, for: .selected)
            self.pageControl.setImage(nil, for: .normal)
            self.pageControl.setImage(nil, for: .selected)
            self.pageControl.setPath(nil, for: .normal)
            self.pageControl.setPath(nil, for: .selected)
            switch self.styleIndex {
            case 0:
                // Default
                break
            case 1:
                // Ring
                self.pageControl.setStrokeColor(.green, for: .normal)
                self.pageControl.setStrokeColor(.green, for: .selected)
                self.pageControl.setFillColor(.green, for: .selected)
            case 2:
                // Image
                self.pageControl.setImage(UIImage(named:"normalImage"), for: .normal)
                self.pageControl.setImage(UIImage(named:"currentImage"), for: .selected)
            case 3:
                // UIBezierPath - Star
                self.pageControl.setStrokeColor(.yellow, for: .normal)
                self.pageControl.setStrokeColor(.yellow, for: .selected)
                self.pageControl.setFillColor(.yellow, for: .selected)
                self.pageControl.setPath(self.starPath, for: .normal)
                self.pageControl.setPath(self.starPath, for: .selected)
            case 4:
                // UIBezierPath - Heart
                let color = UIColor(red: 255/255.0, green: 102/255.0, blue: 255/255.0, alpha: 1.0)
                self.pageControl.setStrokeColor(color, for: .normal)
                self.pageControl.setStrokeColor(color, for: .selected)
                self.pageControl.setFillColor(color, for: .selected)
                self.pageControl.setPath(self.heartPath, for: .normal)
                self.pageControl.setPath(self.heartPath, for: .selected)
            default:
                break
            }
        }
    }
    fileprivate var alignmentIndex = 0 {
        didSet {
            self.pageControl.contentHorizontalAlignment = [.right,.center,.left][self.alignmentIndex]
        }
    }
    
    // ⭐️
    fileprivate var starPath: UIBezierPath {
        let width = self.pageControl.itemSpacing
        let height = self.pageControl.itemSpacing
        let starPath = UIBezierPath()
        starPath.move(to: CGPoint(x: width*0.5, y: 0))
        starPath.addLine(to: CGPoint(x: width*0.677, y: height*0.257))
        starPath.addLine(to: CGPoint(x: width*0.975, y: height*0.345))
        starPath.addLine(to: CGPoint(x: width*0.785, y: height*0.593))
        starPath.addLine(to: CGPoint(x: width*0.794, y: height*0.905))
        starPath.addLine(to: CGPoint(x: width*0.5, y: height*0.8))
        starPath.addLine(to: CGPoint(x: width*0.206, y: height*0.905))
        starPath.addLine(to: CGPoint(x: width*0.215, y: height*0.593))
        starPath.addLine(to: CGPoint(x: width*0.025, y: height*0.345))
        starPath.addLine(to: CGPoint(x: width*0.323, y: height*0.257))
        starPath.close()
        return starPath
    }
    
    // ❤️
    fileprivate var heartPath: UIBezierPath {
        let width = self.pageControl.itemSpacing
        let height = self.pageControl.itemSpacing
        let heartPath = UIBezierPath()
        heartPath.move(to: CGPoint(x: width*0.5, y: height))
        heartPath.addCurve(
            to: CGPoint(x: 0, y: height*0.25),
            controlPoint1: CGPoint(x: width*0.5, y: height*0.75) ,
            controlPoint2: CGPoint(x: 0, y: height*0.5)
        )
        heartPath.addArc(
            withCenter: CGPoint(x: width*0.25,y: height*0.25),
            radius: width * 0.25,
            startAngle: .pi,
            endAngle: 0,
            clockwise: true
        )
        heartPath.addArc(
            withCenter: CGPoint(x: width*0.75, y: height*0.25),
            radius: width * 0.25,
            startAngle: .pi,
            endAngle: 0,
            clockwise: true
        )
        heartPath.addCurve(
            to: CGPoint(x: width*0.5, y: height),
            controlPoint1: CGPoint(x: width, y: height*0.5),
            controlPoint2: CGPoint(x: width*0.5, y: height*0.75)
        )
        heartPath.close()
        return heartPath
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .white
        
        view.addSubview(self.pageView)
        self.pageView.addSubview(self.pageControl)
        
        view.addSubview(self.tabbleView)
        
    }


}

extension ViewController: UITableViewDelegate {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return self.dataSouce.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let items:NSArray = self.dataSouce[section]["items"] as! NSArray
        return items.count
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 30
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 40
    }
}

extension ViewController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let dataName = self.dataSouce[section]
        let name = dataName["name"]
        let label = UILabel()
        label.backgroundColor = .orange
        label.text = (name as! String)
        label.font = UIFont.systemFont(ofSize: 13)
        label.textAlignment = .center
        return label
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let datArray = self.dataSouce[indexPath.section];
        let items:[String:String] = (datArray["items"] as! NSArray)[indexPath.row] as! [String:String]
        let name = items["name"]
        
        var cell = tableView.dequeueReusableCell(withIdentifier: "cell\(String(describing: name))")
        if cell == nil {
            cell = UITableViewCell(style: .subtitle, reuseIdentifier: "cell\(String(describing: name))")
        }
        cell?.textLabel?.text = name
        cell?.textLabel?.font = UIFont.systemFont(ofSize: 14)
        cell!.accessoryType = UITableViewCell.AccessoryType.disclosureIndicator
        if indexPath.section == 3 {
            cell!.selectionStyle = UITableViewCell.SelectionStyle.none
            if indexPath.row == 0 {
                cell!.contentView.addSubview(self.slider)
            } else if indexPath.row == 1 {
                cell!.contentView.addSubview(self.slider2)
            } else if indexPath.row == 2 {
                cell!.contentView.addSubview(self.slider3)
            } else if indexPath.row == 3 {
                cell!.contentView.addSubview(self.slider4)
            }
        }
        return cell!
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        if indexPath.section == 0 {
            self.typeIndex = indexPath.row
        }
        if indexPath.section == 1 {
            self.alignmentIndex = indexPath.row
        }
        if indexPath.section == 2 {
            self.styleIndex = indexPath.row
        }
        if indexPath.section == 4 {
            self.pageView.scrollDirection = indexPath.row == 0 ? .horizontal : .vertical
            self.pageView.reloadData()
        }
        if let visibleRows = tableView.indexPathsForVisibleRows {
            tableView.reloadRows(at: visibleRows, with: .automatic)
        }
    }
    
   @objc func sliderValueChanged(_ sender: UISlider) {
        switch sender.tag {
        case 1:
            let newScale = 0.5+CGFloat(sender.value)*0.5 // [0.5 - 1.0]
            self.pageView.itemSize = self.pageView.frame.size.applying(CGAffineTransform(scaleX: newScale, y: newScale))
        case 2:
            self.pageView.interitemSpacing = CGFloat(sender.value) * 20 // [0 - 20]
        case 3:
            self.pageControl.itemSpacing = 6.0 + CGFloat(sender.value*10.0) // [6 - 16]
            // Redraw UIBezierPath
            if [3,4].contains(self.styleIndex) {
                let index = self.styleIndex
                self.styleIndex = index
            }
        case 4:
            self.pageControl.interitemSpacing = 6.0 + CGFloat(sender.value*10.0) // [6 - 16]
        default:
            break
        }
    }
}


// MARK:- TFYSwiftPagerView <DataSource Delegate>

extension ViewController: TFYSwiftPagerViewDataSource,TFYSwiftPagerViewDelegate {
    
    // MARK:- TFYSwiftPagerView DataSource
    
    func numberOfItems(in pagerView: TFYSwiftPagerView) -> Int {
        return imageNames.count
    }
    
    func pagerView(_ pagerView: TFYSwiftPagerView, cellForItemAt index: Int) -> TFYSwiftPagerViewCell {
        let cell = pageView.dequeueReusableCell(withReuseIdentifier: "pageCell", at: index)
        cell.imageView?.image = UIImage(named: imageNames[index])
        cell.imageView?.contentMode = .scaleAspectFill
        cell.imageView?.clipsToBounds = true
        cell.textLabel?.text = "这是一个测试标题:\(index)"
        return cell
    }
    
    // MARK:- TFYSwiftPagerView Delegate
    
    func pagerView(_ pagerView: TFYSwiftPagerView, didSelectItemAt index: Int) {
        pagerView.deselectItem(at: index, animated: true)
        pagerView.scrollToItem(at: index, animated: true)
        let vc: UIViewController = TFYSwiftCustomController()
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    func pagerViewWillEndDragging(_ pagerView: TFYSwiftPagerView, targetIndex: Int) {
        self.pageControl.currentPage = targetIndex
    }
    
    func pagerViewDidEndScrollAnimation(_ pagerView: TFYSwiftPagerView) {
        self.pageControl.currentPage = pagerView.currentIndex
    }
}

extension NSObject {
    
    struct associatedKey {
         static var key = "xz_badge"
    }
    
    private var dataSouce: NSDictionary {
        set {
            objc_setAssociatedObject(self, &(associatedKey.key), newValue, objc_AssociationPolicy.OBJC_ASSOCIATION_COPY)
        }
        get {
            return (objc_getAssociatedObject(self, &(associatedKey.key)) as? NSDictionary)!

        }
    }
}

