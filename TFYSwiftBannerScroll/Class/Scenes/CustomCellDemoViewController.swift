import UIKit

final class CustomCellDemoViewController: DemoPagerBaseViewController {
    private var mode = 0
    private var shadows = false
    private var showsImage = true
    private var showsText = true
    private var selected = false
    private var highlighted = false
    private var imageMode: UIView.ContentMode = .scaleAspectFill
    init() { super.init(title: "Cell 与注册方式") }
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
    override func configureDemo() {
        describe("切换 Class / Nib 注册；体验默认图片、文字、复用、选择高亮，以及自定义内容和按钮。")
        pagerView.register(DemoBannerCell.self, forCellWithReuseIdentifier: "custom")
        pagerView.register(UINib(nibName: "DemoNibBannerCell", bundle: .main), forCellWithReuseIdentifier: "nib")
        useCardSize(width: 0.88, height: 0.9)
        let registration = addSection("注册与复用", detail: "Nib 是项目内真实的 .xib 资源，通过 init(coder:) 创建 TFYSwiftPagerViewCell。")
        registration.addArrangedSubview(makeChoiceRow(title: "Cell 类型", options: ["默认 Class", "自定义 Class + CTA", "Nib 注册"]) { [weak self] in self?.mode = $0; self?.pagerView.reloadData() })
        registration.addArrangedSubview(makeButton("滚动触发复用") { [weak self] in
            guard let self else { return }; self.pagerView.scrollToItem(at: (self.pagerView.currentIndex + 1) % self.imageNames.count, animated: true)
        })
        let appearance = addSection("默认 Cell 外观", detail: "图片和文字开关作用于默认 / Nib Cell；自定义 Cell 由自己的子视图绘制。")
        appearance.addArrangedSubview(makeSwitchRow(title: "显示 imageView", isOn: true) { [weak self] in self?.showsImage = $0; self?.pagerView.reloadData() })
        appearance.addArrangedSubview(makeSwitchRow(title: "显示 textLabel", isOn: true) { [weak self] in self?.showsText = $0; self?.pagerView.reloadData() })
        appearance.addArrangedSubview(makeChoiceRow(title: "图片填充模式", options: ["裁切填满", "完整显示", "拉伸"]) { [weak self] in self?.imageMode = [.scaleAspectFill, .scaleAspectFit, .scaleToFill][$0]; self?.pagerView.reloadData() })
        appearance.addArrangedSubview(makeSwitchRow(title: "阴影 isShadowEnabled", isOn: false) { [weak self] in self?.shadows = $0; self?.pagerView.reloadData() })
        appearance.addArrangedSubview(makeSwitchRow(title: "模拟选中 isSelected", isOn: false) { [weak self] in self?.selected = $0; self?.pagerView.reloadData() })
        appearance.addArrangedSubview(makeSwitchRow(title: "模拟高亮 isHighlighted", isOn: false) { [weak self] in self?.highlighted = $0; self?.pagerView.reloadData() })
        setStatus("默认 Class：先创建文字，再创建图片，也能保持正确遮挡顺序")
    }
    override func pagerView(_ pagerView: TFYSwiftPagerView, cellForItemAt index: Int) -> TFYSwiftPagerViewCell {
        let identifier = ["cell", "custom", "nib"][mode]
        let cell = pagerView.dequeueReusableCell(withReuseIdentifier: identifier, at: index)
        if let custom = cell as? DemoBannerCell {
            custom.configure(imageName: imageNames[index], title: "自定义 Banner #\(index + 1)")
            custom.onActionTap = { [weak self] in self?.setStatus("CTA 已点击，index = \(index)") }
        } else {
            cell.textLabel?.text = showsText ? "\(mode == 2 ? "Nib" : "Class") · 第 \(index + 1) 项" : nil
            cell.textLabel?.superview?.isHidden = !showsText
            cell.imageView?.image = showsImage ? DemoImages.image(named: imageNames[index]) : nil
            cell.imageView?.contentMode = imageMode
            cell.imageView?.clipsToBounds = true
        }
        cell.isShadowEnabled = shadows
        cell.isSelected = selected
        cell.isHighlighted = highlighted
        return cell
    }
}
