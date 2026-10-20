//
//  TFYSwiftPagerViewTransformer.swift
//  TFYSwiftBannerScroll
//
//  Created by 田风有 on 2021/5/19.
//

import UIKit

@objc
public enum PagerViewTransformerType: Int, CaseIterable {
    case crossFading       // 渐变淡出效果
    case zoomOut           // 缩小淡出效果
    case depth             // 立体深度效果
    case overlap           // 卡片重叠效果（仅水平）
    case linear            // 线性滑动效果（仅水平）
    case coverFlow         // 封面流效果（仅水平）
    case ferrisWheel       // 摩天轮效果（仅水平）
    case invertedFerrisWheel // 反向摩天轮效果（仅水平）
    case cubic             // 3D立方体效果
    case rotate3D          // 3D旋转效果
    case parallax          // 视差滚动效果
    case springy           // 弹性动画效果
    case flip              // 页面翻转效果
    case cards             // 层叠卡片效果
    case cylinder          // 圆柱体排列效果
    case wave              // 波浪起伏效果
    case windmill          // 风车旋转效果
    case accordion         // 手风琴折叠效果
    case carousel          // 旋转木马效果
    case stack             // 卡片堆叠效果
    case grid              // 网格布局效果
    case posterStack       // 居中海报与两侧倾斜层叠（仅水平）
    case fan               // 扇形卡片
    case throwCard         // 飞出叠牌
    case bookFlip          // 沿书脊翻页
    
    /// 是否支持垂直滚动方向。
    public var supportsVertical: Bool {
        switch self {
        case .overlap, .linear, .coverFlow, .ferrisWheel, .invertedFerrisWheel, .posterStack:
            return false
        default:
            return true
        }
    }
    
    public var displayName: String {
        switch self {
        case .crossFading: return "渐变淡出"
        case .zoomOut: return "缩小"
        case .depth: return "深度"
        case .overlap: return "卡片重叠"
        case .linear: return "卡片线性"
        case .coverFlow: return "封面流"
        case .ferrisWheel: return "摩天轮"
        case .invertedFerrisWheel: return "反向摩天轮"
        case .cubic: return "立体立方"
        case .rotate3D: return "3D旋转"
        case .parallax: return "视差滚动"
        case .springy: return "弹性"
        case .flip: return "翻转"
        case .cards: return "卡片层叠"
        case .cylinder: return "圆柱体"
        case .wave: return "波浪"
        case .windmill: return "风车"
        case .accordion: return "手风琴"
        case .carousel: return "旋转木马"
        case .stack: return "堆叠"
        case .grid: return "网格"
        case .posterStack: return "海报层叠"
        case .fan: return "扇形卡片"
        case .throwCard: return "飞出叠牌"
        case .bookFlip: return "翻书"
        }
    }
}

open class TFYSwiftPagerViewTransformer: NSObject {

    open internal(set) weak var pagerView: TFYSwiftPagerView?
    open internal(set) var type: PagerViewTransformerType
    
    @objc open var minimumScale: CGFloat = 0.65 {
        didSet {
            self.minimumScale = self.minimumScale.isFinite ? min(max(self.minimumScale, 0), 1) : 0.65
            self.pagerView?.invalidateTransformerLayout()
        }
    }
    @objc open var minimumAlpha: CGFloat = 0.6 {
        didSet {
            self.minimumAlpha = self.minimumAlpha.isFinite ? min(max(self.minimumAlpha, 0), 1) : 0.6
            self.pagerView?.invalidateTransformerLayout()
        }
    }
    @objc open var perspective: CGFloat = -0.002 { // 3D透视参数
        didSet {
            self.perspective = self.perspective.isFinite ? self.perspective : -0.002
            self.pagerView?.invalidateTransformerLayout()
        }
    }
    @objc open var springDamping: CGFloat = 0.8 { // 弹性动画阻尼系数
        didSet {
            self.springDamping = self.springDamping.isFinite ? min(max(self.springDamping, 0), 1) : 0.8
            self.pagerView?.invalidateTransformerLayout()
        }
    }
    @objc open var parallaxFactor: CGFloat = 0.5 { // 视差强度系数
        didSet {
            self.parallaxFactor = self.parallaxFactor.isFinite ? max(self.parallaxFactor, 0) : 0.5
            self.pagerView?.invalidateTransformerLayout()
        }
    }
    @objc open var rotationAngle: CGFloat = .pi/2 { // 3D旋转角度基数
        didSet {
            self.rotationAngle = self.rotationAngle.isFinite ? self.rotationAngle : .pi/2
            self.pagerView?.invalidateTransformerLayout()
        }
    }
    @objc open var waveHeight: CGFloat = 50.0 { // 波浪效果的高度
        didSet {
            self.waveHeight = self.waveHeight.isFinite ? self.waveHeight : 50.0
            self.pagerView?.invalidateTransformerLayout()
        }
    }
    @objc open var cylinderRadius: CGFloat = 200.0 { // 圆柱体效果的半径
        didSet {
            self.cylinderRadius = self.cylinderRadius.isFinite ? max(self.cylinderRadius, 0) : 200.0
            self.pagerView?.invalidateTransformerLayout()
        }
    }
    @objc open var flipAngle: CGFloat = .pi { // 翻转角度
        didSet {
            self.flipAngle = self.flipAngle.isFinite ? self.flipAngle : .pi
            self.pagerView?.invalidateTransformerLayout()
        }
    }
    @objc open var cardSpacing: CGFloat = 10.0 { // 卡片间距
        didSet {
            self.cardSpacing = self.cardSpacing.isFinite ? max(self.cardSpacing, 0) : 10.0
            self.pagerView?.invalidateTransformerLayout()
        }
    }
    @objc open var windmillSpeed: CGFloat = 1.0 { // 风车旋转速度
        didSet {
            self.windmillSpeed = self.windmillSpeed.isFinite ? self.windmillSpeed : 1.0
            self.pagerView?.invalidateTransformerLayout()
        }
    }
    @objc open var accordionFactor: CGFloat = 0.8 { // 手风琴折叠系数
        didSet {
            self.accordionFactor = self.accordionFactor.isFinite ? min(max(self.accordionFactor, 0), 1) : 0.8
            self.pagerView?.invalidateTransformerLayout()
        }
    }
    @objc open var carouselRadius: CGFloat = 300.0 { // 旋转木马半径
        didSet {
            self.carouselRadius = self.carouselRadius.isFinite ? max(self.carouselRadius, 0) : 300.0
            self.pagerView?.invalidateTransformerLayout()
        }
    }
    @objc open var stackOffset: CGFloat = 8.0 { // 堆叠偏移量
        didSet {
            self.stackOffset = self.stackOffset.isFinite ? max(self.stackOffset, 0) : 8.0
            self.pagerView?.invalidateTransformerLayout()
        }
    }
    @objc open var gridRows: Int = 2 {
        didSet {
            self.gridRows = max(self.gridRows, 1)
            self.pagerView?.invalidateTransformerLayout()
        }
    }
    @objc open var gridColumns: Int = 3 {
        didSet {
            self.gridColumns = max(self.gridColumns, 1)
            self.pagerView?.invalidateTransformerLayout()
        }
    }
    @objc open var gridSpacing: CGFloat = 10.0 {
        didSet {
            self.gridSpacing = self.gridSpacing.isFinite ? max(self.gridSpacing, 0) : 0
            self.pagerView?.invalidateTransformerLayout()
        }
    }
    
    @objc
    public init(type: PagerViewTransformerType) {
        self.type = type
        switch type {
        case .zoomOut:
            self.minimumScale = 0.85
        case .depth:
            self.minimumScale = 0.5
        case .posterStack:
            self.minimumScale = 0.9
            self.minimumAlpha = 0.55
            self.rotationAngle = .pi / 24
        case .fan:
            self.minimumScale = 0.9
            self.minimumAlpha = 0.75
            self.rotationAngle = .pi / 12
        case .throwCard:
            self.minimumScale = 0.88
            self.minimumAlpha = 1
            self.rotationAngle = .pi / 12
            self.cardSpacing = 12
        default:
            break
        }
    }
    
    // 应用transform到属性- zIndex: Int, frame: CGRect, alpha: CGFloat, transform: CGAffineTransform或transform3D: CATransform3D。
    open func applyTransform(to attributes: TFYSwiftPagerViewLayoutAttributes) {
        guard let pagerView = self.pagerView else {
            return
        }
        attributes.transform3D = CATransform3DIdentity
        attributes.alpha = 1
        attributes.zIndex = 0
        let position = attributes.position
        guard position.isFinite else { attributes.alpha = 0; return }
        let distance = abs(position)
        guard self.type == .grid || distance < 5 else { attributes.alpha = 0; return }
        // Fine-grained, stable front-to-back ordering during fractional drags.
        attributes.zIndex = Int((5 - min(distance, 5)) * 10_000) * 2 + (position <= 0 ? 1 : 0)
        let scrollDirection = pagerView.scrollDirection
        let itemSpacing = (scrollDirection == .horizontal ? attributes.bounds.width : attributes.bounds.height) + self.proposedInteritemSpacing()
        switch self.type {
        case .crossFading:
            var zIndex = 0
            var alpha: CGFloat = 0
            var transform = CGAffineTransform.identity
            switch scrollDirection {
            case .horizontal:
                transform.tx = -itemSpacing * position
            case .vertical:
                transform.ty = -itemSpacing * position
            }
            if (abs(position) < 1) { // [-1,1]
                // 当移动到左侧页面时，使用默认的幻灯片转换
                alpha = 1 - abs(position)
                zIndex = 1
            } else { // (1,+Infinity]
                // 这一页离屏幕太远了。
                alpha = 0
                zIndex = Int.min
            }
            attributes.alpha = alpha
            attributes.transform = transform
            attributes.zIndex = zIndex
        case .zoomOut:
            var alpha: CGFloat = 0
            var transform = CGAffineTransform.identity
            switch position {
            case -CGFloat.greatestFiniteMagnitude ..< -1 : // [-Infinity,-1)
                // 这一页离屏幕太远了。
                alpha = 0
            case -1 ... 1 :  // [-1,1]
                // 修改默认的幻灯片转换以缩小页面
                let scaleFactor = max(self.minimumScale, 1 - abs(position))
                transform.a = scaleFactor
                transform.d = scaleFactor
                switch scrollDirection {
                case .horizontal:
                    let vertMargin = attributes.bounds.height * (1 - scaleFactor) / 2;
                    let horzMargin = itemSpacing * (1 - scaleFactor) / 2;
                    transform.tx = position < 0 ? (horzMargin - vertMargin*2) : (-horzMargin + vertMargin*2)
                case .vertical:
                    let horzMargin = attributes.bounds.width * (1 - scaleFactor) / 2;
                    let vertMargin = itemSpacing * (1 - scaleFactor) / 2;
                    transform.ty = position < 0 ? (vertMargin - horzMargin*2) : (-vertMargin + horzMargin*2)
                }
                // 相对于页面大小淡出页面。
                alpha = self.minimumScale == 1 ? 1
                    : self.minimumAlpha + (scaleFactor-self.minimumScale)/(1-self.minimumScale)*(1-self.minimumAlpha)
            case 1 ... CGFloat.greatestFiniteMagnitude :  // (1,+Infinity]
                // 这一页离屏幕太远了。
                alpha = 0
            default:
                break
            }
            attributes.alpha = alpha
            attributes.transform = transform
        case .depth:
            var transform = CGAffineTransform.identity
            var zIndex = 0
            var alpha: CGFloat = 0.0
            switch position {
            case -CGFloat.greatestFiniteMagnitude ..< -1: // [-Infinity,-1)
                // 这一页离屏幕太远了。
                alpha = 0
                zIndex = 0
            case -1 ... 0:  // [-1,0]
                // 当移动到左侧页面时，使用默认的幻灯片转换
                alpha = 1
                transform.tx = 0
                transform.a = 1
                transform.d = 1
                zIndex = 1
            case 0 ..< 1: // (0,1)
                // 让页面淡出。
                alpha = CGFloat(1.0) - position
                // 抵消默认的幻灯片转换
                switch scrollDirection {
                case .horizontal:
                    transform.tx = itemSpacing * -position
                case .vertical:
                    transform.ty = itemSpacing * -position
                }
                // 缩小页面(在minimumScale和1之间)
                let scaleFactor = self.minimumScale
                    + (1.0 - self.minimumScale) * (1.0 - abs(position));
                transform.a = scaleFactor
                transform.d = scaleFactor
                zIndex = 0
            case 1 ... CGFloat.greatestFiniteMagnitude: // [1,+Infinity)
                // 这一页离屏幕太远了。
                alpha = 0
                zIndex = 0
            default:
                break
            }
            attributes.alpha = alpha
            attributes.transform = transform
            attributes.zIndex = zIndex
        case .overlap,.linear:
            guard scrollDirection == .horizontal else {
                // 此类型不支持垂直模式
                return
            }
            let scale = max(1 - (1-self.minimumScale) * abs(position), self.minimumScale)
            let transform = CGAffineTransform(scaleX: scale, y: scale)
            attributes.transform = transform
            let alpha = 1 - (1 - self.minimumAlpha) * min(distance, 1)
            attributes.alpha = alpha
        case .coverFlow:
            guard scrollDirection == .horizontal else {
                // 此类型不支持垂直模式
                return
            }
            let position = min(max(-position,-1) ,1)
            let rotation = sin(position*(.pi)*0.5)*(.pi)*0.25*1.5
            let translationZ = -itemSpacing * 0.5 * abs(position)
            var transform3D = CATransform3DIdentity
            transform3D.m34 = self.perspective
            transform3D = CATransform3DRotate(transform3D, rotation, 0, 1, 0)
            transform3D = CATransform3DTranslate(transform3D, 0, 0, translationZ)
            attributes.transform3D = transform3D
        case .ferrisWheel, .invertedFerrisWheel:
            guard scrollDirection == .horizontal else {
                // 此类型不支持垂直模式
                return
            }
            
            var zIndex = 0
            var transform = CGAffineTransform.identity
            switch position {
            case -5 ... 5:
                let itemSpacing = attributes.bounds.width+self.proposedInteritemSpacing()
                let count: CGFloat = 14
                let circle: CGFloat = .pi * 2.0
                let radius = itemSpacing * count / circle
                let ty = radius * (self.type == .ferrisWheel ? 1 : -1)
                let theta = circle / count
                let rotation = position * theta * (self.type == .ferrisWheel ? 1 : -1)
                transform = transform.translatedBy(x: -position*itemSpacing, y: ty)
                transform = transform.rotated(by: rotation)
                transform = transform.translatedBy(x: 0, y: -ty)
                zIndex = attributes.zIndex
            default:
                break
            }
            attributes.alpha = (1 - (1 - self.minimumAlpha) * min(distance, 1)) * min(5 - distance, 1)
            attributes.transform = transform
            attributes.zIndex = zIndex
        case .cubic:
            switch position {
            case -CGFloat.greatestFiniteMagnitude ... -1:
                attributes.alpha = 0
            case -1 ..< 1:
                attributes.alpha = 1
                attributes.zIndex = Int((1-position) * CGFloat(10))
                let direction: CGFloat = position < 0 ? 1 : -1
                let theta = position * .pi * 0.5 * (scrollDirection == .horizontal ? 1 : -1)
                let radius = scrollDirection == .horizontal ? attributes.bounds.width : attributes.bounds.height
                var transform3D = CATransform3DIdentity
                transform3D.m34 = self.perspective
                switch scrollDirection {
                case .horizontal:
                    // ForwardX -> RotateY -> BackwardX
                    transform3D = CATransform3DRotate(transform3D, theta, 0, 1, 0) // RotateY
                    transform3D = CATransform3DTranslate(transform3D,-direction*radius*0.5, 0, 0) // BackwardX
                    transform3D = CATransform3DConcat(transform3D, CATransform3DMakeTranslation(direction*radius*0.5, 0, 0))
                case .vertical:
                    // ForwardY -> RotateX -> BackwardY
                    transform3D = CATransform3DRotate(transform3D, theta, 1, 0, 0) // RotateX
                    transform3D = CATransform3DTranslate(transform3D,0, -direction*radius*0.5, 0) // BackwardY
                    transform3D = CATransform3DConcat(transform3D, CATransform3DMakeTranslation(0, direction*radius*0.5, 0))
                }
                attributes.transform3D = transform3D
            case 1 ... CGFloat.greatestFiniteMagnitude:
                attributes.alpha = 0
            default:
                attributes.alpha = 0
                attributes.zIndex = 0
            }
        case .rotate3D:  // 新增3D旋转效果
            let angle = position * rotationAngle
                var transform3D = CATransform3DIdentity
                transform3D.m34 = perspective
                switch scrollDirection {
                case .horizontal:
                    transform3D = CATransform3DRotate(transform3D, angle, 0, 1, 0)
                case .vertical:
                    transform3D = CATransform3DRotate(transform3D, angle, 1, 0, 0)
                }
                attributes.transform3D = transform3D
        case .parallax:  // 新增视差滚动效果
            let parallaxFactor = self.parallaxFactor
           var transform = CGAffineTransform.identity
           switch scrollDirection {
           case .horizontal:
               let offset = attributes.bounds.width * parallaxFactor * position
               transform.tx = offset
           case .vertical:
               let offset = attributes.bounds.height * parallaxFactor * position
               transform.ty = offset
           }
           attributes.transform = transform
            
        case .springy:  // 弹性缩放：阻尼越大，超调越小。
            let progress = min(distance, 1)
            let scale = 1 - 0.15 * progress + sin(progress * .pi) * 0.12 * (1 - springDamping)
            attributes.transform = CGAffineTransform(scaleX: scale, y: scale)
            attributes.alpha = 1 - min(distance / 3, 1)
        case .flip:  // 3D翻转效果
            var transform3D = CATransform3DIdentity
            transform3D.m34 = perspective
            let angle = position * flipAngle
            switch scrollDirection {
            case .horizontal:
                transform3D = CATransform3DRotate(transform3D, angle, 0, 1, 0)
            case .vertical:
                transform3D = CATransform3DRotate(transform3D, angle, 1, 0, 0)
            }
            attributes.transform3D = transform3D
            // Hide the back face instead of displaying a mirrored image.
            attributes.alpha = distance <= 1 ? max(0, cos(angle)) : 0
        case .cards:  // 卡片堆叠效果
            let scale = max(1 - distance * 0.2, self.minimumScale)
            let translation = cardSpacing * position
            var transform = CGAffineTransform.identity
                .scaledBy(x: scale, y: scale)
            
            switch scrollDirection {
            case .horizontal:
                transform = transform.translatedBy(x: translation, y: 0)
            case .vertical:
                transform = transform.translatedBy(x: 0, y: translation)
            }
            
            attributes.transform = transform
            attributes.alpha = 1 - abs(position) * 0.5
            
        case .cylinder:  // 圆柱体效果
            var transform3D = CATransform3DIdentity
            transform3D.m34 = perspective
            
            let angle = position * .pi / 4
            let radius = cylinderRadius
            
            switch scrollDirection {
            case .horizontal:
                let translateX = radius * sin(angle)
                let translateZ = radius * (1 - cos(angle))
                transform3D = CATransform3DTranslate(transform3D, translateX, 0, -translateZ)
                transform3D = CATransform3DRotate(transform3D, angle, 0, 1, 0)
            case .vertical:
                let translateY = radius * sin(angle)
                let translateZ = radius * (1 - cos(angle))
                transform3D = CATransform3DTranslate(transform3D, 0, translateY, -translateZ)
                transform3D = CATransform3DRotate(transform3D, angle, 1, 0, 0)
            }
            
            let compensation = scrollDirection == .horizontal
                ? CATransform3DMakeTranslation(-itemSpacing * position, 0, 0)
                : CATransform3DMakeTranslation(0, -itemSpacing * position, 0)
            attributes.transform3D = CATransform3DConcat(transform3D, compensation)
            attributes.alpha = max(0, cos(angle))
            
        case .wave:  // 波浪沿滚动的垂直方向起伏。
            let displacement = waveHeight * sin(position * .pi * 0.5)
            let scale = max(1 - distance * 0.2, self.minimumScale)
            let x = scrollDirection == .vertical ? displacement : 0
            let y = scrollDirection == .horizontal ? displacement : 0
            attributes.transform = CGAffineTransform(translationX: x, y: y).scaledBy(x: scale, y: scale)
            attributes.alpha = 1 - distance * 0.3
        case .windmill:  // 风车旋转效果
            attributes.transform = CGAffineTransform(rotationAngle: position * .pi * windmillSpeed)
            attributes.alpha = 1 - min(distance * 0.6, 0.6)
        case .accordion:  // 手风琴折叠效果
            var transform = CGAffineTransform.identity
            let scale = max(1 - abs(position) * accordionFactor, 0.2)
            
            switch scrollDirection {
            case .horizontal:
                transform = transform.scaledBy(x: scale, y: 1.0)
            case .vertical:
                transform = transform.scaledBy(x: 1.0, y: scale)
            }
            
            attributes.transform = transform
            attributes.alpha = 1 - min(abs(position) * 0.5, 0.5)
            
        case .carousel:  // 旋转木马效果
            var transform3D = CATransform3DIdentity
            transform3D.m34 = perspective
            
            let angle = position * .pi / 3
            let radius = carouselRadius
            let translateZ = radius * (cos(angle) - 1)
            
            switch scrollDirection {
            case .horizontal:
                let translateX = radius * sin(angle)
                transform3D = CATransform3DTranslate(transform3D, translateX, 0, translateZ)
            case .vertical:
                let translateY = radius * sin(angle)
                transform3D = CATransform3DTranslate(transform3D, 0, translateY, translateZ)
            }
            
            let compensation = scrollDirection == .horizontal
                ? CATransform3DMakeTranslation(-itemSpacing * position, 0, 0)
                : CATransform3DMakeTranslation(0, -itemSpacing * position, 0)
            attributes.transform3D = CATransform3DConcat(transform3D, compensation)
            attributes.alpha = 1 - min(distance * 0.7, 0.7)
            
        case .stack:  // 堆叠效果
            var transform = CGAffineTransform.identity
            let distance = abs(position)
            let offset = stackOffset * position
            
            switch scrollDirection {
            case .horizontal:
                transform = transform.translatedBy(x: offset, y: abs(offset))
            case .vertical:
                transform = transform.translatedBy(x: abs(offset), y: offset)
            }
            
            let scale = 1 - min(distance, 2) * 0.1
            transform = transform.scaledBy(x: scale, y: scale)
            
            attributes.transform = transform
            // Keep the foreground opaque; fade out cards beyond the immediate neighbours.
            // A constant alpha for every distant card exposes the entire repeated deck while dragging.
            attributes.alpha = max(0, min(1, 2 - distance))
            // Fractional positions need distinct layers, including a deterministic tie at half a step.
            attributes.zIndex = Int((2 - min(distance, 2)) * 10_000) * 2 + (position <= 0 ? 1 : 0)
        case .posterStack:
            guard scrollDirection == .horizontal else { return }
            let distance = abs(position)
            let progress = min(distance, 1)
            let scale = 1 - (1 - self.minimumScale) * progress
            let tilt = min(max(position, -1), 1) * self.rotationAngle
            attributes.transform = CGAffineTransform(rotationAngle: tilt).scaledBy(x: scale, y: scale)
            // Only the nearest cards remain visible; farther cards fade behind them.
            let visibility = max(0, 1 - max(distance - 1, 0) * 2)
            attributes.alpha = (1 - (1 - self.minimumAlpha) * progress) * visibility
            attributes.zIndex = Int((1 - min(distance, 10)) * 100)
        case .fan:
            let angle = position * rotationAngle * (scrollDirection == .horizontal ? 1 : -1)
            let pivotX = scrollDirection == .vertical ? attributes.bounds.width * 0.5 : 0
            let pivotY = scrollDirection == .horizontal ? attributes.bounds.height * 0.5 : 0
            let scale = 1 - (1 - minimumScale) * min(distance, 1)
            attributes.transform = CGAffineTransform(translationX: pivotX, y: pivotY)
                .rotated(by: angle).translatedBy(x: -pivotX, y: -pivotY).scaledBy(x: scale, y: scale)
            attributes.alpha = 1 - (1 - minimumAlpha) * min(distance, 1)
        case .throwCard:
            if position < 0 {
                let drift = cardSpacing * distance
                attributes.transform = CGAffineTransform(translationX: scrollDirection == .vertical ? drift : 0,
                                                         y: scrollDirection == .horizontal ? drift : 0)
                    .rotated(by: position * rotationAngle)
                attributes.alpha = max(0, min(1, (1 - distance) * 5))
                attributes.zIndex = 100_000 + Int((1 - min(distance, 1)) * 1_000)
            } else {
                let scale = max(minimumScale, 1 - (1 - minimumScale) * position)
                let x = scrollDirection == .horizontal ? -itemSpacing * position : cardSpacing * position
                let y = scrollDirection == .vertical ? -itemSpacing * position : cardSpacing * position
                attributes.transform = CGAffineTransform(translationX: x, y: y).scaledBy(x: scale, y: scale)
                attributes.alpha = (1 - (1 - minimumAlpha) * min(position, 1)) * max(0, min(1, 2 - position))
                attributes.zIndex = 90_000 - Int(position * 1_000)
            }
        case .bookFlip:
            var transform = CATransform3DIdentity
            transform.m34 = perspective
            if position < 0 {
                let angle = min(distance, 1) * min(abs(rotationAngle), .pi / 2)
                let pivotX = scrollDirection == .horizontal ? -attributes.bounds.width * 0.5 : 0
                let pivotY = scrollDirection == .vertical ? -attributes.bounds.height * 0.5 : 0
                transform = CATransform3DTranslate(transform, pivotX, pivotY, 0)
                transform = CATransform3DRotate(transform, scrollDirection == .horizontal ? angle : -angle,
                                                scrollDirection == .horizontal ? 0 : 1,
                                                scrollDirection == .horizontal ? 1 : 0, 0)
                transform = CATransform3DTranslate(transform, -pivotX, -pivotY, 0)
                attributes.alpha = max(0, min(1, (1 - distance) * 5))
                attributes.zIndex = 100_000 + Int((1 - min(distance, 1)) * 1_000)
            } else {
                attributes.alpha = (1 - (1 - minimumAlpha) * min(position, 1)) * max(0, min(1, 2 - position))
                attributes.zIndex = 90_000 - Int(position * 1_000)
            }
            let compensation = scrollDirection == .horizontal
                ? CATransform3DMakeTranslation(-itemSpacing * position, 0, 0)
                : CATransform3DMakeTranslation(0, -itemSpacing * position, 0)
            attributes.transform3D = CATransform3DConcat(transform, compensation)
        case .grid:  // 网格布局效果
            // 网格模式下不需要特殊的变换效果
            attributes.alpha = 1.0
            attributes.transform = .identity
            attributes.zIndex = 0
        }
        if self.type != .grid && self.type != .ferrisWheel && self.type != .invertedFerrisWheel {
            attributes.alpha *= max(0, min(1, 3 - distance))
        }
        attributes.alpha = attributes.alpha.isFinite ? min(max(attributes.alpha, 0), 1) : 0
    }
    
    //由变压器类提出的项间间隔。这将覆盖页导航视图提供的默认interitemSpacing。
    open func proposedInteritemSpacing() -> CGFloat {
        guard let pagerView = self.pagerView else {
            return 0
        }
        let scrollDirection = pagerView.scrollDirection
        let size = pagerView.itemSize == .zero
            ? CGSize(width: max(pagerView.bounds.width - pagerView.contentInsets.left - pagerView.contentInsets.right, 0),
                     height: max(pagerView.bounds.height - pagerView.contentInsets.top - pagerView.contentInsets.bottom, 0))
            : pagerView.itemSize
        switch self.type {
        case .overlap:
            guard scrollDirection == .horizontal else {
                return 0
            }
            return size.width * -self.minimumScale * 0.6
        case .linear:
            guard scrollDirection == .horizontal else {
                return 0
            }
            return size.width * -self.minimumScale * 0.2
        case .coverFlow:
            guard scrollDirection == .horizontal else {
                return 0
            }
            return -size.width * sin(.pi*0.25*0.25*3.0)
        case .ferrisWheel,.invertedFerrisWheel:
            guard scrollDirection == .horizontal else {
                return 0
            }
            return -size.width * 0.15
        case .cubic:
            return 0
        case .rotate3D:
            return scrollDirection == .horizontal ?
                -size.width * 0.2 :
                -size.height * 0.2
        case .parallax:
            return scrollDirection == .horizontal ?
                size.width * 0.1 :
                size.height * 0.1
        case .springy:
            return scrollDirection == .horizontal ?
                size.width * 0.3 :
                size.height * 0.3
        case .flip:
            return scrollDirection == .horizontal ?
                -size.width * 0.3 :
                -size.height * 0.3
        case .cards:
            return cardSpacing
        case .cylinder:
            return scrollDirection == .horizontal ?
                -size.width * 0.2 :
                -size.height * 0.2
        case .wave:
            return scrollDirection == .horizontal ?
                size.width * 0.1 :
                size.height * 0.1
        case .windmill:
            return scrollDirection == .horizontal ?
                size.width * 0.15 :
                size.height * 0.15
        case .accordion:
            return scrollDirection == .horizontal ?
                -size.width * 0.5 :
                -size.height * 0.5
        case .carousel:
            return scrollDirection == .horizontal ?
                size.width * 0.2 :
                size.height * 0.2
        case .stack:
            return scrollDirection == .horizontal ?
                -size.width * 0.8 :
                -size.height * 0.8
        case .posterStack:
            guard scrollDirection == .horizontal else { return 0 }
            return -size.width * 0.72 + self.cardSpacing
        case .fan:
            return -(scrollDirection == .horizontal ? size.width : size.height) * 0.65 + self.cardSpacing
        case .throwCard, .bookFlip:
            return 0
        case .grid:
            return self.gridSpacing
        default:
            break
        }
        return pagerView.interitemSpacing
    }
}
