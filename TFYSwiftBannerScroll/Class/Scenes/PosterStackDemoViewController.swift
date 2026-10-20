import UIKit

/// Screenshot-style poster deck: a front poster, tilted neighbours, play button and dots.
final class PosterStackDemoViewController: DemoPagerBaseViewController {
    init() { super.init(title: "海报层叠", imageNames: ["01", "02", "03", "04", "05", "06"]) }
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }

    override func preferredPreviewHeight(availableHeight: CGFloat, compact: Bool) -> CGFloat {
        compact ? 120 : min(420, max(260, availableHeight * 0.47))
    }

    override func configureDemo() {
        describe("中间海报突出，两侧卡片缩小倾斜并压在后面；滑动海报或点击播放按钮。")
        pagerView.register(DemoPosterCell.self, forCellWithReuseIdentifier: "poster")
        pagerView.transformer = TFYSwiftPagerViewTransformer(type: .posterStack)
        pagerView.isInfinite = true
        let backdrop = UIView()
        backdrop.backgroundColor = UIColor(white: 0.06, alpha: 1)
        pagerView.backgroundView = backdrop
        pageControl.itemSpacing = 5
        pageControl.interitemSpacing = 5
        pageControl.setFillColor(.systemGray, for: .normal)
        pageControl.setFillColor(.label, for: .selected)
        let layout = addSection("海报层叠参数", detail: "使用内置 .posterStack；海报圆角和播放按钮由 DemoPosterCell 提供，宿主可自定义。")
        layout.addArrangedSubview(makeSliderRow(title: "两侧缩放 minimumScale", value: 0.9, min: 0.7, max: 1) { [weak self] in
            self?.pagerView.transformer?.minimumScale = CGFloat($0)
        })
        layout.addArrangedSubview(makeSliderRow(title: "两侧透明度 minimumAlpha", value: 0.55, min: 0.2, max: 1) { [weak self] in
            self?.pagerView.transformer?.minimumAlpha = CGFloat($0)
        })
        layout.addArrangedSubview(makeSliderRow(title: "两侧倾角（度）", value: 7.5, min: 0, max: 18) { [weak self] in
            self?.pagerView.rotationAngle = CGFloat($0) * .pi / 180
        })
        layout.addArrangedSubview(makeSliderRow(title: "展开间距 cardSpacing", value: 10, min: 0, max: 36) { [weak self] in
            self?.pagerView.transformer?.cardSpacing = CGFloat($0)
            self?.pagerView.reloadData()
        })
        layout.addArrangedSubview(makeSwitchRow(title: "自动切换海报", isOn: false) { [weak self] in
            self?.pagerView.automaticSlidingInterval = $0 ? 3 : 0
        })
        setStatus("海报层叠 · 左右滑动查看全部 6 张海报")
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        let height = pagerView.bounds.height * 0.9
        let size = CGSize(width: min(pagerView.bounds.width * 0.66, height * 0.76), height: height)
        if pagerView.itemSize != size { pagerView.itemSize = size }
    }

    override func pagerView(_ pagerView: TFYSwiftPagerView, cellForItemAt index: Int) -> TFYSwiftPagerViewCell {
        let cell = pagerView.dequeueReusableCell(withReuseIdentifier: "poster", at: index) as! DemoPosterCell
        cell.configure(imageName: imageNames[index], title: "海报 \(index + 1)")
        cell.onPlay = { [weak self] in self?.setStatus("已点击海报 \(index + 1) 的播放按钮") }
        return cell
    }
}

final class DemoPosterCell: TFYSwiftPagerViewCell {
    private let playButton = UIButton(type: .system)
    private let titleLabel = UILabel()
    var onPlay: (() -> Void)?

    override init(frame: CGRect) { super.init(frame: frame); setup() }
    required init?(coder: NSCoder) { super.init(coder: coder); setup() }

    private func setup() {
        contentView.layer.cornerRadius = 24
        contentView.layer.cornerCurve = .continuous
        contentView.clipsToBounds = true
        imageView?.contentMode = .scaleAspectFill
        imageView?.clipsToBounds = true
        playButton.translatesAutoresizingMaskIntoConstraints = false
        playButton.backgroundColor = UIColor.black.withAlphaComponent(0.35)
        playButton.layer.cornerRadius = 30
        playButton.tintColor = .white
        playButton.setImage(UIImage(systemName: "play.fill", withConfiguration: UIImage.SymbolConfiguration(pointSize: 24, weight: .semibold)), for: .normal)
        playButton.accessibilityIdentifier = "poster.play"
        playButton.addAction(UIAction { [weak self] _ in self?.onPlay?() }, for: .touchUpInside)
        contentView.addSubview(playButton)
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.font = .preferredFont(forTextStyle: .headline)
        titleLabel.adjustsFontForContentSizeCategory = true
        titleLabel.textColor = .white
        titleLabel.backgroundColor = UIColor.black.withAlphaComponent(0.25)
        titleLabel.textAlignment = .center
        titleLabel.layer.cornerRadius = 10
        titleLabel.clipsToBounds = true
        contentView.addSubview(titleLabel)
        NSLayoutConstraint.activate([
            playButton.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            playButton.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            playButton.widthAnchor.constraint(equalToConstant: 60),
            playButton.heightAnchor.constraint(equalToConstant: 60),
            titleLabel.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            titleLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -16),
            titleLabel.widthAnchor.constraint(lessThanOrEqualTo: contentView.widthAnchor, constant: -24),
            titleLabel.heightAnchor.constraint(greaterThanOrEqualToConstant: 32)
        ])
    }

    func configure(imageName: String, title: String) {
        imageView?.image = DemoImages.image(named: imageName)
        titleLabel.text = title
        playButton.accessibilityLabel = "播放\(title)"
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        onPlay = nil
        imageView?.image = nil
        titleLabel.text = nil
    }
}
