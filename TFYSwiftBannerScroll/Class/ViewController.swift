//
//  ViewController.swift
//  TFYSwiftBannerScroll
//
//  Created by 田风有 on 2021/5/19.
//

import UIKit

class ViewController: UIViewController {

    // MARK: - Constants
    private let screenWidth = UIScreen.main.bounds.size.width
    private let screenHeight = UIScreen.main.bounds.size.height
    private let imageNames = ["1.jpg","2.jpg","3.jpg","4.jpg","5.jpg","6.jpg","7.jpg",
                            "01.jpg","02.jpg","03.jpg","04.jpg","05.jpg","06.jpg"]
    
    // MARK: - Types
    private enum Section: Int {
        case transformType = 0
        case indicatorPosition
        case indicatorStyle
        case settings
        case scrollDirection
    }
    
    // MARK: - Properties
    private var typeIndex: Int = 0
    private var alignmentIndex: Int = 0
    private var styleIndex: Int = 0
    
    private let transformerTypes: [PagerViewTransformerType] = [
        .crossFading, .zoomOut, .depth, .linear, .overlap,
        .ferrisWheel, .invertedFerrisWheel, .coverFlow, .cubic,
        .rotate3D, .parallax, .springy, .flip, .cards,
        .cylinder, .wave, .windmill, .accordion,
        .carousel, .stack, .grid
    ]
    
    // MARK: - Custom Paths
    private var starPath: UIBezierPath {
        let width = pageControl.itemSpacing
        let height = pageControl.itemSpacing
        let starPath = UIBezierPath()
        
        // 绘制五角星路径
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
    
    private var heartPath: UIBezierPath {
        let width = pageControl.itemSpacing
        let height = pageControl.itemSpacing
        let heartPath = UIBezierPath()
        
        // 绘制心形路径
        heartPath.move(to: CGPoint(x: width*0.5, y: height))
        heartPath.addCurve(
            to: CGPoint(x: 0, y: height*0.25),
            controlPoint1: CGPoint(x: width*0.5, y: height*0.75),
            controlPoint2: CGPoint(x: 0, y: height*0.5)
        )
        heartPath.addArc(
            withCenter: CGPoint(x: width*0.25, y: height*0.25),
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
    
    // MARK: - UI Components
    private lazy var pageView: TFYSwiftPagerView = {
        let view = TFYSwiftPagerView(frame: CGRect(x: 0, y: 88, width: screenWidth, height: screenHeight/3))
        view.backgroundColor = .white
        view.dataSource = self
        view.delegate = self
        view.scrollDirection = .horizontal
        view.automaticSlidingInterval = 3
        view.itemSize = CGSize(width: screenWidth - 100, height: screenHeight/3 - 40)
        view.register(TFYSwiftPagerViewCell.self, forCellWithReuseIdentifier: "pageCell")
        return view
    }()
    
    private lazy var pageControl: TFYSwiftPageControl = {
        let control = TFYSwiftPageControl(frame: CGRect(x: 0, y: pageView.frame.maxY - 26,
                                                       width: screenWidth, height: 26))
        control.numberOfPages = imageNames.count
        return control
    }()
    
    private lazy var tableView: UITableView = {
        let tableView = UITableView(frame: CGRect(x: 0, y: pageView.frame.maxY,
                                                width: screenWidth,
                                                height: screenHeight - pageView.frame.maxY),
                                   style: .grouped)
        tableView.delegate = self
        tableView.dataSource = self
        tableView.backgroundColor = .white
        tableView.showsVerticalScrollIndicator = false
        tableView.showsHorizontalScrollIndicator = false
        if #available(iOS 15.0, *) {
            tableView.sectionHeaderTopPadding = 0
        }
        return tableView
    }()
    
    // MARK: - Sliders
    private lazy var sliders: [UISlider] = {
        return [
            createSlider(tag: 1, value: 0.5), // 轮播大小
            createSlider(tag: 2, value: 0.5), // 视图间距
            createSlider(tag: 3, value: 0.5), // 指示器大小
            createSlider(tag: 4, value: 0.5), // 指示器间距
            createSlider(tag: 5, value: 0.25), // 视差强度
            createSlider(tag: 6, value: 0.5), // 旋转角度
            createSlider(tag: 7, value: 2, min: 1, max: 4), // 网格行数
            createSlider(tag: 8, value: 3, min: 1, max: 5)  // 网格列数
        ]
    }()
    
    // MARK: - Data Source
    private let dataSouce: [[String: Any]] = [
        [
            "name": "轮播模式",
            "items": [
                ["name": "渐变浅出"],
                ["name": "缩小"],
                ["name": "POP退出"],
                ["name": "卡片线性 -- 不支持垂直动画"],
                ["name": "卡片重叠 -- 不支持垂直动画"],
                ["name": "上步扇形 -- 不支持垂直动画"],
                ["name": "下部扇形 -- 不支持垂直动画"],
                ["name": "内部折叠 -- 不支持垂直动画"],
                ["name": "立体旋转"],
                ["name": "3D旋转"],
                ["name": "视差滚动"],
                ["name": "弹性动画"],
                ["name": "翻转效果"],
                ["name": "卡片堆叠"],
                ["name": "圆柱体"],
                ["name": "波浪效果"],
                ["name": "风车旋转"],
                ["name": "手风琴"],
                ["name": "旋转木马"],
                ["name": "堆叠"],
                ["name": "网格布局"]
            ]
        ],
        [
            "name": "指示器位置",
            "items": [
                ["name": "右边"],
                ["name": "居中"],
                ["name": "左边"]
            ]
        ],
        [
            "name": "指示器状态",
            "items": [
                ["name": "默认"],
                ["name": "圆圈镂空"],
                ["name": "自定图片"],
                ["name": "绘制五角星"],
                ["name": "绘制的爱心"]
            ]
        ],
        [
            "name": "其他设置",
            "items": [
                ["name": "轮播大小"],
                ["name": "视图间距"],
                ["name": "指示器大小"],
                ["name": "指示器间距"],
                ["name": "视差强度控制"],
                ["name": "旋转角度控制"],
                ["name": "网格行数"],
                ["name": "网格列数"]
            ]
        ],
        [
            "name": "视图滚动方向 -- 有的动画不支持垂直",
            "items": [
                ["name": "水平"],
                ["name": "垂直"]
            ]
        ]
    ]
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        configureInitialState()
    }
        
    // MARK: - Private Methods
    private func setupUI() {
        view.backgroundColor = .white
        title = "TFYSwiftBannerScroll"
        
        view.addSubview(pageView)
        view.addSubview(pageControl)
        setupTableView()
    }
    
    private func configureInitialState() {
        let transformer = TFYSwiftPagerViewTransformer(type: .crossFading)
        pageView.transformer = transformer
    }
    
    private func createSlider(tag: Int, value: Float, min: Float = 0, max: Float = 1) -> UISlider {
        let slider = UISlider(frame: CGRect(x: 80, y: 0, width: screenWidth - 100, height: 40))
        slider.tag = tag
        slider.minimumValue = min
        slider.maximumValue = max
        slider.value = value
        slider.isContinuous = true
        slider.addTarget(self, action: #selector(sliderValueChanged), for: .valueChanged)
        return slider
    }
    
    @objc private func sliderValueChanged(_ sender: UISlider) {
        switch sender.tag {
        case 1: // 轮播大小
            let newScale = 0.5 + CGFloat(sender.value) * 0.5
            pageView.itemSize = pageView.frame.size.applying(CGAffineTransform(scaleX: newScale, y: newScale))
            
        case 2: // 视图间距
            pageView.interitemSpacing = CGFloat(sender.value) * 20
            
        case 3: // 指示器大小
            pageControl.itemSpacing = 6.0 + CGFloat(sender.value * 10.0)
            if [3, 4].contains(styleIndex) {
                let index = styleIndex
                styleIndex = index
            }
            
        case 4: // 指示器间距
            pageControl.interitemSpacing = 6.0 + CGFloat(sender.value * 10.0)
            
        case 5: // 视差强度
            pageView.parallaxFactor = CGFloat(sender.value) * 2.0
            
        case 6: // 旋转角度
            pageView.rotationAngle = CGFloat(sender.value) * .pi
            
        case 7: // 网格行数
            if let transformer = pageView.transformer, transformer.type == .grid {
                transformer.gridRows = Int(sender.value)
                pageView.reloadData()
            }
            
        case 8: // 网格列数
            if let transformer = pageView.transformer, transformer.type == .grid {
                transformer.gridColumns = Int(sender.value)
                pageView.reloadData()
            }
            
        default:
            break
        }
    }
    
    private func setupTableView() {
        view.addSubview(tableView)
    }
}

// MARK: - UITableViewDataSource & UITableViewDelegate
extension ViewController: UITableViewDataSource, UITableViewDelegate {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return dataSouce.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let items = dataSouce[section]["items"] as! [[String: String]]
        return items.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let items = dataSouce[indexPath.section]["items"] as! [[String: String]]
        let item = items[indexPath.row]
        let name = item["name"]!
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell\(name)") ??
            UITableViewCell(style: .subtitle, reuseIdentifier: "cell\(name)")
        
        cell.textLabel?.text = name
        cell.textLabel?.font = .systemFont(ofSize: 14)
        cell.accessoryType = .disclosureIndicator
        
        if indexPath.section == Section.settings.rawValue {
            cell.selectionStyle = .none
            cell.accessoryType = .none
            
            // Add slider based on row
            if let slider = sliders[safe: indexPath.row] {
                cell.contentView.addSubview(slider)
            }
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let headerView = UILabel()
        headerView.backgroundColor = .orange
        headerView.text = dataSouce[section]["name"] as? String
        headerView.font = .systemFont(ofSize: 13)
        headerView.textAlignment = .center
        return headerView
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 30
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 40
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        switch Section(rawValue: indexPath.section) {
        case .transformType:
            typeIndex = indexPath.row
            let type = transformerTypes[indexPath.row]
            let transformer = TFYSwiftPagerViewTransformer(type: type)
            
            if type == .grid {
                // 配置网格布局
                pageView.configureGridLayout(rows: 2, columns: 3, spacing: 10)
                
                // 隐藏页面指示器
                pageControl.isHiddenInGridMode = true
                
                // 重置内边距和大小
                pageView.collectionView.contentInset = .zero
                pageView.itemSize = pageView.bounds.size
                
                // 禁用自动滚动
                pageView.automaticSlidingInterval = 0
                
                // 启用分页
                pageView.collectionView.isPagingEnabled = true
                
                // 更新布局
                pageView.collectionViewLayout.invalidateLayout()
                pageView.reloadData()
            } else {
                // 恢复正常布局
                pageControl.isHiddenInGridMode = false
                pageView.itemSize = CGSize(width: screenWidth - 100, height: screenHeight/3 - 40)
                pageView.collectionView.contentInset = UIEdgeInsets(top: 0, left: 50, bottom: 0, right: 50)
                pageView.collectionView.isPagingEnabled = false
            }
            
            pageView.transformer = transformer
            
        case .indicatorPosition:
            alignmentIndex = indexPath.row
            pageControl.contentHorizontalAlignment = [.right, .center, .left][indexPath.row]
            
        case .indicatorStyle:
            styleIndex = indexPath.row
            updatePageControlStyle()
            
        case .scrollDirection:
            pageView.scrollDirection = indexPath.row == 0 ? .horizontal : .vertical
            pageView.reloadData()
            
        default:
            break
        }
        
        if let visibleRows = tableView.indexPathsForVisibleRows {
            tableView.reloadRows(at: visibleRows, with: .automatic)
        }
    }
}

// MARK: - Helper Methods
private extension ViewController {
    func updatePageControlStyle() {
        // Reset all styles
        pageControl.setStrokeColor(nil, for: .normal)
        pageControl.setStrokeColor(nil, for: .selected)
        pageControl.setFillColor(nil, for: .normal)
        pageControl.setFillColor(nil, for: .selected)
        pageControl.setImage(nil, for: .normal)
        pageControl.setImage(nil, for: .selected)
        pageControl.setPath(nil, for: .normal)
        pageControl.setPath(nil, for: .selected)
        
        switch styleIndex {
        case 1: // Ring
            pageControl.setStrokeColor(.green, for: .normal)
            pageControl.setStrokeColor(.green, for: .selected)
            pageControl.setFillColor(.green, for: .selected)
            
        case 2: // Image
            pageControl.setImage(UIImage(named: "normalImage"), for: .normal)
            pageControl.setImage(UIImage(named: "currentImage"), for: .selected)
            
        case 3: // Star
            pageControl.setStrokeColor(.yellow, for: .normal)
            pageControl.setStrokeColor(.yellow, for: .selected)
            pageControl.setFillColor(.yellow, for: .selected)
            pageControl.setPath(starPath, for: .normal)
            pageControl.setPath(starPath, for: .selected)
            
        case 4: // Heart
            let color = UIColor(red: 255/255.0, green: 102/255.0, blue: 255/255.0, alpha: 1.0)
            pageControl.setStrokeColor(color, for: .normal)
            pageControl.setStrokeColor(color, for: .selected)
            pageControl.setFillColor(color, for: .selected)
            pageControl.setPath(heartPath, for: .normal)
            pageControl.setPath(heartPath, for: .selected)
            
        default:
            break
        }
    }
}

// MARK: - Safe Array Access
private extension Array {
    subscript(safe index: Int) -> Element? {
        return indices.contains(index) ? self[index] : nil
    }
}

// MARK: - TFYSwiftPagerViewDataSource & Delegate
extension ViewController: TFYSwiftPagerViewDataSource, TFYSwiftPagerViewDelegate {
    func numberOfItems(in pagerView: TFYSwiftPagerView) -> Int {
        return imageNames.count
    }
    
    func pagerView(_ pagerView: TFYSwiftPagerView, cellForItemAt index: Int) -> TFYSwiftPagerViewCell {
        let cell = pageView.dequeueReusableCell(withReuseIdentifier: "pageCell", at: index)
        configureCell(cell, at: index)
        return cell
    }
    
    private func configureCell(_ cell: TFYSwiftPagerViewCell, at index: Int) {
        cell.imageView?.image = UIImage(named: imageNames[index])
        cell.imageView?.contentMode = .scaleAspectFill
        cell.imageView?.clipsToBounds = true
        cell.textLabel?.text = "这是一个测试标题:\(index)"
    }
    
    func pagerView(_ pagerView: TFYSwiftPagerView, didSelectItemAt index: Int) {
        pagerView.deselectItem(at: index, animated: true)
        pagerView.scrollToItem(at: index, animated: true)
        navigationController?.pushViewController(TFYSwiftCustomController(), animated: true)
    }
    
    func pagerViewWillEndDragging(_ pagerView: TFYSwiftPagerView, targetIndex: Int) {
        pageControl.currentPage = targetIndex
    }
    
    func pagerViewDidEndScrollAnimation(_ pagerView: TFYSwiftPagerView) {
        pageControl.currentPage = pagerView.currentIndex
    }
}

extension NSObject {
    
    struct associatedKey {
         static var key = UnsafeRawPointer(bitPattern: "xz_badge".hashValue)!
    }
    
    private var dataSouce: NSDictionary {
        set {
            objc_setAssociatedObject(self, associatedKey.key, newValue, objc_AssociationPolicy.OBJC_ASSOCIATION_COPY)
        }
        get {
            return (objc_getAssociatedObject(self, associatedKey.key) as? NSDictionary)!

        }
    }
}

