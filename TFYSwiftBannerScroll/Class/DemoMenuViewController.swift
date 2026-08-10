//
//  DemoMenuViewController.swift
//  TFYSwiftBannerScroll
//

import UIKit

final class DemoMenuViewController: UITableViewController {
    
    private struct Item {
        let title: String
        let subtitle: String
        let factory: () -> UIViewController
    }
    
    private lazy var items: [Item] = [
        Item(title: "基础轮播", subtitle: "itemSize / interitemSpacing / scrollToItem", factory: { BasicBannerDemoViewController() }),
        Item(title: "无限循环 + 自动轮播", subtitle: "isInfinite / automaticSlidingInterval", factory: { InfiniteAutoplayDemoViewController() }),
        Item(title: "滚动物理", subtitle: "deceleration / bounces / scrollOffset", factory: { ScrollPhysicsDemoViewController() }),
        Item(title: "转场动画画廊", subtitle: "全部 Transformer 类型与参数", factory: { TransformersDemoViewController() }),
        Item(title: "垂直滚动", subtitle: "仅展示支持垂直的动画", factory: { VerticalScrollDemoViewController() }),
        Item(title: "网格布局", subtitle: "configureGridLayout", factory: { GridLayoutDemoViewController() }),
        Item(title: "页面指示器", subtitle: "对齐 / 颜色 / 图片 / 路径 / alpha", factory: { PageControlDemoViewController() }),
        Item(title: "自定义 Cell", subtitle: "子类化 TFYSwiftPagerViewCell", factory: { CustomCellDemoViewController() }),
        Item(title: "代理事件", subtitle: "全部 optional delegate 日志", factory: { DelegateEventsDemoViewController() }),
        Item(title: "外观与控制", subtitle: "backgroundView / selectItem / contentInsets", factory: { ChromeControlDemoViewController() })
    ]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "TFYSwiftBannerScroll"
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        tableView.tableFooterView = UIView()
        
        navigationItem.largeTitleDisplayMode = .always
        navigationController?.navigationBar.prefersLargeTitles = true
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        items.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        let item = items[indexPath.row]
        var config = cell.defaultContentConfiguration()
        config.text = item.title
        config.secondaryText = item.subtitle
        cell.contentConfiguration = config
        cell.accessoryType = .disclosureIndicator
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        navigationController?.pushViewController(items[indexPath.row].factory(), animated: true)
    }
}
