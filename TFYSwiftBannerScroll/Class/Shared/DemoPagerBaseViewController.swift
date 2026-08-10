//
//  DemoPagerBaseViewController.swift
//  TFYSwiftBannerScroll
//

import UIKit

class DemoPagerBaseViewController: UIViewController, TFYSwiftPagerViewDataSource, TFYSwiftPagerViewDelegate {
    
    let imageNames: [String]
    
    lazy var pagerView: TFYSwiftPagerView = {
        let view = TFYSwiftPagerView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = .systemBackground
        view.dataSource = self
        view.delegate = self
        view.register(TFYSwiftPagerViewCell.self, forCellWithReuseIdentifier: "cell")
        return view
    }()
    
    lazy var pageControl: TFYSwiftPageControl = {
        let control = TFYSwiftPageControl()
        control.translatesAutoresizingMaskIntoConstraints = false
        control.numberOfPages = imageNames.count
        control.contentHorizontalAlignment = .center
        control.setFillColor(.systemGray3, for: .normal)
        control.setFillColor(.systemBlue, for: .selected)
        return control
    }()
    
    private lazy var statusLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = .preferredFont(forTextStyle: .footnote)
        label.textColor = .secondaryLabel
        label.numberOfLines = 0
        label.textAlignment = .center
        return label
    }()
    
    var controlsContainer: UIStackView = {
        let stack = UIStackView()
        stack.axis = .vertical
        stack.spacing = 12
        stack.translatesAutoresizingMaskIntoConstraints = false
        return stack
    }()
    
    init(title: String, imageNames: [String] = DemoImages.banners) {
        self.imageNames = imageNames
        super.init(nibName: nil, bundle: nil)
        self.title = title
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemGroupedBackground
        setupBaseLayout()
        configureDemo()
    }
    
    func configureDemo() {}
    
    func setStatus(_ text: String) {
        statusLabel.text = text
    }
    
    func syncPageControl(to index: Int) {
        guard index >= 0, index < pageControl.numberOfPages else { return }
        pageControl.currentPage = index
    }
    
    private func setupBaseLayout() {
        let scrollView = UIScrollView()
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.alwaysBounceVertical = true
        
        let content = UIView()
        content.translatesAutoresizingMaskIntoConstraints = false
        
        view.addSubview(scrollView)
        scrollView.addSubview(content)
        content.addSubview(pagerView)
        content.addSubview(pageControl)
        content.addSubview(statusLabel)
        content.addSubview(controlsContainer)
        
        let guide = view.safeAreaLayoutGuide
        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: guide.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            
            content.topAnchor.constraint(equalTo: scrollView.contentLayoutGuide.topAnchor),
            content.leadingAnchor.constraint(equalTo: scrollView.contentLayoutGuide.leadingAnchor),
            content.trailingAnchor.constraint(equalTo: scrollView.contentLayoutGuide.trailingAnchor),
            content.bottomAnchor.constraint(equalTo: scrollView.contentLayoutGuide.bottomAnchor),
            content.widthAnchor.constraint(equalTo: scrollView.frameLayoutGuide.widthAnchor),
            
            pagerView.topAnchor.constraint(equalTo: content.topAnchor, constant: 12),
            pagerView.leadingAnchor.constraint(equalTo: content.leadingAnchor, constant: 16),
            pagerView.trailingAnchor.constraint(equalTo: content.trailingAnchor, constant: -16),
            pagerView.heightAnchor.constraint(equalToConstant: 220),
            
            pageControl.topAnchor.constraint(equalTo: pagerView.bottomAnchor, constant: 8),
            pageControl.leadingAnchor.constraint(equalTo: content.leadingAnchor, constant: 16),
            pageControl.trailingAnchor.constraint(equalTo: content.trailingAnchor, constant: -16),
            pageControl.heightAnchor.constraint(equalToConstant: 24),
            
            statusLabel.topAnchor.constraint(equalTo: pageControl.bottomAnchor, constant: 8),
            statusLabel.leadingAnchor.constraint(equalTo: content.leadingAnchor, constant: 16),
            statusLabel.trailingAnchor.constraint(equalTo: content.trailingAnchor, constant: -16),
            
            controlsContainer.topAnchor.constraint(equalTo: statusLabel.bottomAnchor, constant: 16),
            controlsContainer.leadingAnchor.constraint(equalTo: content.leadingAnchor, constant: 16),
            controlsContainer.trailingAnchor.constraint(equalTo: content.trailingAnchor, constant: -16),
            controlsContainer.bottomAnchor.constraint(equalTo: content.bottomAnchor, constant: -24)
        ])
    }
    
    func makeSwitchRow(title: String, isOn: Bool, action: @escaping (Bool) -> Void) -> UIView {
        let row = UIStackView()
        row.axis = .horizontal
        row.alignment = .center
        
        let label = UILabel()
        label.text = title
        label.font = .systemFont(ofSize: 15)
        
        let toggle = UISwitch()
        toggle.isOn = isOn
        toggle.addAction(UIAction { _ in action(toggle.isOn) }, for: .valueChanged)
        
        row.addArrangedSubview(label)
        row.addArrangedSubview(toggle)
        return row
    }
    
    func makeSliderRow(title: String, value: Float, min: Float = 0, max: Float = 1, action: @escaping (Float) -> Void) -> UIView {
        let container = UIStackView()
        container.axis = .vertical
        container.spacing = 4
        
        let label = UILabel()
        label.text = title
        label.font = .systemFont(ofSize: 14)
        label.textColor = .secondaryLabel
        
        let slider = UISlider()
        slider.minimumValue = min
        slider.maximumValue = max
        slider.value = value
        slider.addAction(UIAction { _ in action(slider.value) }, for: .valueChanged)
        
        container.addArrangedSubview(label)
        container.addArrangedSubview(slider)
        return container
    }
    
    func makeButton(_ title: String, action: @escaping () -> Void) -> UIButton {
        var config = UIButton.Configuration.filled()
        config.title = title
        config.baseBackgroundColor = .secondarySystemFill
        config.baseForegroundColor = .label
        config.cornerStyle = .medium
        let button = UIButton(configuration: config)
        button.addAction(UIAction { _ in action() }, for: .touchUpInside)
        return button
    }
    
    // MARK: - DataSource
    
    func numberOfItems(in pagerView: TFYSwiftPagerView) -> Int {
        imageNames.count
    }
    
    func pagerView(_ pagerView: TFYSwiftPagerView, cellForItemAt index: Int) -> TFYSwiftPagerViewCell {
        let cell = pagerView.dequeueReusableCell(withReuseIdentifier: "cell", at: index)
        cell.imageView?.image = DemoImages.image(named: imageNames[index])
        cell.imageView?.contentMode = .scaleAspectFill
        cell.imageView?.clipsToBounds = true
        cell.textLabel?.text = "  Item \(index + 1)"
        return cell
    }
    
    // MARK: - Delegate (overridable)
    
    func pagerView(_ pagerView: TFYSwiftPagerView, didChangeIndex index: Int) {
        syncPageControl(to: index)
        setStatus("currentIndex = \(index)")
    }
    
    func pagerView(_ pagerView: TFYSwiftPagerView, didSelectItemAt index: Int) {
        pagerView.deselectItem(at: index, animated: true)
        setStatus("didSelectItemAt \(index)")
    }
    
    func pagerViewWillEndDragging(_ pagerView: TFYSwiftPagerView, targetIndex: Int) {
        syncPageControl(to: targetIndex)
    }
    
    func pagerViewDidEndScrollAnimation(_ pagerView: TFYSwiftPagerView) {
        syncPageControl(to: pagerView.currentIndex)
    }
    
    func pagerViewDidEndDecelerating(_ pagerView: TFYSwiftPagerView) {
        syncPageControl(to: pagerView.currentIndex)
    }
    
    func pagerViewDidScroll(_ pagerView: TFYSwiftPagerView) {}
}
