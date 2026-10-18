import UIKit

final class PageControlDemoViewController: DemoPagerBaseViewController {
    private var shape = 0
    init() { super.init(title: "页面指示器") }
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
    override func configureDemo() {
        describe("颜色、路径、图片和透明度分别设置普通 / 选中状态；切换单项数据验证自动隐藏。")
        useAutomaticSize()
        let geometry = addSection("大小与对齐")
        geometry.addArrangedSubview(makeChoiceRow(title: "水平对齐", options: ["居中", "左侧", "右侧", "leading", "trailing", "fill"]) { [weak self] in
            self?.pageControl.contentHorizontalAlignment = [.center, .left, .right, .leading, .trailing, .fill][$0]
        })
        geometry.addArrangedSubview(makeSliderRow(title: "指示器直径 itemSpacing", value: 6, min: 4, max: 20) { [weak self] in self?.pageControl.itemSpacing = CGFloat($0); self?.applyShape() })
        geometry.addArrangedSubview(makeSliderRow(title: "指示器间距 interitemSpacing", value: 6, min: 0, max: 24) { [weak self] in self?.pageControl.interitemSpacing = CGFloat($0) })
        for (name, key) in [("上边距", \UIEdgeInsets.top), ("左边距", \UIEdgeInsets.left), ("下边距", \UIEdgeInsets.bottom), ("右边距", \UIEdgeInsets.right)] {
            geometry.addArrangedSubview(makeSliderRow(title: "指示器\(name)", value: 0, min: 0, max: key == \.top || key == \.bottom ? 6 : 40) { [weak self] value in
                self?.pageControl.contentInsets[keyPath: key] = CGFloat(value)
            })
        }
        let style = addSection("形状与图片", detail: "图片样式通过 setImage 设置；切回路径时，清除两种状态的图片。")
        style.addArrangedSubview(makeChoiceRow(title: "指示器样式", options: ["圆点", "圆环", "五角星路径", "圆角路径", "自定义图片"]) { [weak self] in self?.shape = $0; self?.applyShape() })
        let colors = addSection("普通与选中状态")
        let palette: [UIColor] = [.systemIndigo, .systemOrange, .systemTeal, .systemGray, .clear]
        let names = ["靛蓝", "橙色", "青色", "灰色", "透明"]
        for (title, state, stroke) in [("普通填充", UIControl.State.normal, false), ("选中填充", .selected, false), ("普通描边", .normal, true), ("选中描边", .selected, true)] {
            colors.addArrangedSubview(makeChoiceRow(title: title, options: names, selected: title == "普通填充" ? 3 : (stroke ? 4 : 0)) { [weak self] index in
                if stroke { self?.pageControl.setStrokeColor(palette[index], for: state) }
                else { self?.pageControl.setFillColor(palette[index], for: state) }
            })
        }
        for (name, state) in [("普通透明度", UIControl.State.normal), ("选中透明度", .selected)] {
            colors.addArrangedSubview(makeSliderRow(title: name, value: 1, min: 0, max: 1) { [weak self] in self?.pageControl.setAlpha(CGFloat($0), for: state) })
        }
        let behavior = addSection("页数与状态", detail: "手动设置 currentPage 仅改变指示器；跳转按钮同时控制 Pager。")
        behavior.addArrangedSubview(makeSwitchRow(title: "单页自动隐藏 hidesForSinglePage", isOn: false) { [weak self] in self?.pageControl.hidesForSinglePage = $0 })
        behavior.addArrangedSubview(makeSwitchRow(title: "隐藏开关 isHiddenInGridMode", isOn: false) { [weak self] in self?.pageControl.isHiddenInGridMode = $0 })
        behavior.addArrangedSubview(makeSliderRow(title: "手动设置 currentPage", value: 0, min: 0, max: Float(imageNames.count - 1), step: 1) { [weak self] in self?.pageControl.currentPage = Int($0.rounded()) })
        behavior.addArrangedSubview(makeButton("Pager 跳转到指示器选中页") { [weak self] in
            guard let self else { return }; self.pagerView.scrollToItem(at: self.pageControl.currentPage, animated: true)
        })
        addDataControls()
        setStatus("numberOfPages 与数据数量同步")
    }

    private func applyShape() {
        for state in [UIControl.State.normal, .selected] {
            pageControl.setImage(nil, for: state)
            pageControl.setPath(nil, for: state)
        }
        let size = pageControl.itemSpacing
        if shape == 1 {
            pageControl.setFillColor(.clear, for: .normal)
            pageControl.setStrokeColor(.systemIndigo, for: .normal)
            pageControl.setStrokeColor(.systemIndigo, for: .selected)
            pageControl.setFillColor(.systemIndigo, for: .selected)
        } else if shape == 2 || shape == 3 {
            let path = shape == 2 ? starPath(size: size) : UIBezierPath(roundedRect: CGRect(x: 0, y: 0, width: size, height: size * 0.6), cornerRadius: size * 0.3)
            pageControl.setPath(path, for: .normal)
            pageControl.setPath(path, for: .selected)
        } else if shape == 4 {
            for (state, name) in [(UIControl.State.normal, "circle"), (.selected, "star.fill")] {
                let image = UIGraphicsImageRenderer(size: CGSize(width: size, height: size)).image { _ in
                    UIImage(systemName: name)?.withTintColor(.systemIndigo, renderingMode: .alwaysOriginal).draw(in: CGRect(x: 0, y: 0, width: size, height: size))
                }
                pageControl.setImage(image, for: state)
            }
        }
    }

    private func starPath(size: CGFloat) -> UIBezierPath {
        let path = UIBezierPath()
        let center = CGPoint(x: size / 2, y: size / 2)
        for point in 0..<10 {
            let angle = CGFloat(point) * .pi / 5 - .pi / 2
            let radius = size * (point.isMultiple(of: 2) ? 0.5 : 0.22)
            let vertex = CGPoint(x: center.x + cos(angle) * radius, y: center.y + sin(angle) * radius)
            if point == 0 { path.move(to: vertex) } else { path.addLine(to: vertex) }
        }
        path.close()
        return path
    }
}
