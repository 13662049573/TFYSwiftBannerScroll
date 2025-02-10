//
//  TFYSwiftPagerViewTransformer.swift
//  TFYSwiftBannerScroll
//
//  Created by 田风有 on 2021/5/19.
//

import UIKit

@objc
public enum PagerViewTransformerType: Int {
    case crossFading       // 渐变淡出效果
    case zoomOut           // 缩小淡出效果
    case depth             // 立体深度效果
    case overlap           // 卡片重叠效果
    case linear            // 线性滑动效果
    case coverFlow         // 封面流效果
    case ferrisWheel       // 摩天轮效果
    case invertedFerrisWheel // 反向摩天轮效果
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
}

open class TFYSwiftPagerViewTransformer: NSObject {

    open internal(set) weak var pagerView: TFYSwiftPagerView?
    open internal(set) var type: PagerViewTransformerType
    
    @objc open var minimumScale: CGFloat = 0.65
    @objc open var minimumAlpha: CGFloat = 0.6
    @objc open var perspective: CGFloat = -0.002  // 3D透视参数
    @objc open var springDamping: CGFloat = 0.8   // 弹性动画阻尼系数
    @objc open var parallaxFactor: CGFloat = 0.5  // 视差强度系数
    @objc open var rotationAngle: CGFloat = .pi/2 // 3D旋转角度基数
    @objc open var waveHeight: CGFloat = 50.0  // 波浪效果的高度
    @objc open var cylinderRadius: CGFloat = 200.0  // 圆柱体效果的半径
    @objc open var flipAngle: CGFloat = .pi  // 翻转角度
    @objc open var cardSpacing: CGFloat = 10.0  // 卡片间距
    @objc open var windmillSpeed: CGFloat = 1.0    // 风车旋转速度
    @objc open var accordionFactor: CGFloat = 0.8  // 手风琴折叠系数
    @objc open var carouselRadius: CGFloat = 300.0 // 旋转木马半径
    @objc open var stackOffset: CGFloat = 8.0      // 堆叠偏移量
    @objc open var gridRows: Int = 2     // 网格行数
    @objc open var gridColumns: Int = 3   // 网格列数
    @objc open var gridSpacing: CGFloat = 10.0  // 网格间距
    
    @objc
    public init(type: PagerViewTransformerType) {
        self.type = type
        switch type {
        case .zoomOut:
            self.minimumScale = 0.85
        case .depth:
            self.minimumScale = 0.5
        default:
            break
        }
    }
    
    // 应用transform到属性- zIndex: Int, frame: CGRect, alpha: CGFloat, transform: CGAffineTransform或transform3D: CATransform3D。
    open func applyTransform(to attributes: TFYSwiftPagerViewLayoutAttributes) {
        guard let pagerView = self.pagerView else {
            return
        }
        let position = attributes.position
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
                alpha = self.minimumAlpha + (scaleFactor-self.minimumScale)/(1-self.minimumScale)*(1-self.minimumAlpha)
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
            let alpha = (self.minimumAlpha + (1-abs(position))*(1-self.minimumAlpha))
            attributes.alpha = alpha
            let zIndex = (1-abs(position)) * 10
            attributes.zIndex = Int(zIndex)
        case .coverFlow:
            guard scrollDirection == .horizontal else {
                // 此类型不支持垂直模式
                return
            }
            let position = min(max(-position,-1) ,1)
            let rotation = sin(position*(.pi)*0.5)*(.pi)*0.25*1.5
            let translationZ = -itemSpacing * 0.5 * abs(position)
            var transform3D = CATransform3DIdentity
            transform3D.m34 = -0.002
            transform3D = CATransform3DRotate(transform3D, rotation, 0, 1, 0)
            transform3D = CATransform3DTranslate(transform3D, 0, 0, translationZ)
            attributes.zIndex = 100 - Int(abs(position))
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
                zIndex = Int((4.0-abs(position)*10))
            default:
                break
            }
            attributes.alpha = abs(position) < 0.5 ? 1 : self.minimumAlpha
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
                transform3D.m34 = -0.002
                switch scrollDirection {
                case .horizontal:
                    // ForwardX -> RotateY -> BackwardX
                    attributes.center.x += direction*radius*0.5 // ForwardX
                    transform3D = CATransform3DRotate(transform3D, theta, 0, 1, 0) // RotateY
                    transform3D = CATransform3DTranslate(transform3D,-direction*radius*0.5, 0, 0) // BackwardX
                case .vertical:
                    // ForwardY -> RotateX -> BackwardY
                    attributes.center.y += direction*radius*0.5 // ForwardY
                    transform3D = CATransform3DRotate(transform3D, theta, 1, 0, 0) // RotateX
                    transform3D = CATransform3DTranslate(transform3D,0, -direction*radius*0.5, 0) // BackwardY
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
            
        case .springy:  // 新增弹性效果
            let scale = 1 - min(abs(position) * 0.3, 0.3)
            let translationX = scrollDirection == .horizontal ? itemSpacing * position : 0
            let translationY = scrollDirection == .vertical ? itemSpacing * position : 0
            let transform = CGAffineTransform(scaleX: scale, y: scale)
                .translatedBy(x: translationX, y: translationY)
                .scaledBy(x: 1 + springDamping * abs(position),
                         y: 1 + springDamping * abs(position))
            attributes.transform = transform
            attributes.alpha = 1 - abs(position)/3
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
            attributes.alpha = abs(position) <= 1 ? 1.0 : 0.0
        case .cards:  // 卡片堆叠效果
            let scale = 1 - abs(position) * 0.2
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
            attributes.zIndex = Int(100 - abs(position * 10))
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
            
            attributes.transform3D = transform3D
            attributes.alpha = 1 - min(abs(position) * 0.5, 0.5)
            
        case .wave:  // 波浪效果
            var transform = CGAffineTransform.identity
            let phase = position * .pi * 2
            let y = waveHeight * sin(phase)
            let scale = 1 - abs(position) * 0.2
            
            transform = transform
                .translatedBy(x: 0, y: y)
                .scaledBy(x: scale, y: scale)
            
            switch scrollDirection {
            case .horizontal:
                transform = transform.translatedBy(x: position * itemSpacing, y: 0)
            case .vertical:
                transform = transform.translatedBy(x: 0, y: position * itemSpacing)
            }
            
            attributes.transform = transform
            attributes.alpha = 1 - abs(position) * 0.3
            attributes.zIndex = Int(100 - abs(position * 10))
        case .windmill:  // 风车旋转效果
            var transform = CGAffineTransform.identity
            let angle = position * .pi * windmillSpeed
            transform = transform.rotated(by: angle)
            
            switch scrollDirection {
            case .horizontal:
                transform = transform.translatedBy(x: position * itemSpacing, y: 0)
            case .vertical:
                transform = transform.translatedBy(x: 0, y: position * itemSpacing)
            }
            
            attributes.transform = transform
            attributes.alpha = 1 - min(abs(position) * 0.6, 0.6)
            attributes.zIndex = Int(10 - abs(position))
        case .accordion:  // 手风琴折叠效果
            var transform = CGAffineTransform.identity
            let scale = max(1 - abs(position) * accordionFactor, 0.2)
            
            switch scrollDirection {
            case .horizontal:
                transform = transform.scaledBy(x: scale, y: 1.0)
                transform = transform.translatedBy(x: position * itemSpacing, y: 0)
            case .vertical:
                transform = transform.scaledBy(x: 1.0, y: scale)
                transform = transform.translatedBy(x: 0, y: position * itemSpacing)
            }
            
            attributes.transform = transform
            attributes.alpha = 1 - min(abs(position) * 0.5, 0.5)
            
        case .carousel:  // 旋转木马效果
            var transform3D = CATransform3DIdentity
            transform3D.m34 = perspective
            
            let angle = position * .pi / 3
            let radius = carouselRadius
            let translateZ = -radius * cos(angle)
            
            switch scrollDirection {
            case .horizontal:
                let translateX = radius * sin(angle)
                transform3D = CATransform3DTranslate(transform3D, translateX, 0, translateZ)
            case .vertical:
                let translateY = radius * sin(angle)
                transform3D = CATransform3DTranslate(transform3D, 0, translateY, translateZ)
            }
            
            attributes.transform3D = transform3D
            attributes.alpha = 1 - min(abs(position) * 0.7, 0.7)
            attributes.zIndex = Int(100 - abs(position * 20))
            
        case .stack:  // 堆叠效果
            var transform = CGAffineTransform.identity
            let offset = stackOffset * position
            
            switch scrollDirection {
            case .horizontal:
                transform = transform.translatedBy(x: offset, y: abs(offset))
            case .vertical:
                transform = transform.translatedBy(x: abs(offset), y: offset)
            }
            
            let scale = 1 - min(abs(position) * 0.1, 0.1)
            transform = transform.scaledBy(x: scale, y: scale)
            
            attributes.transform = transform
            attributes.alpha = 1 - min(abs(position) * 0.4, 0.4)
            attributes.zIndex = Int(10 - abs(position))
        case .grid:  // 网格布局效果
            // 网格模式下不需要特殊的变换效果
            attributes.alpha = 1.0
            attributes.transform = .identity
            attributes.zIndex = 0
        }
    }
    
    //由变压器类提出的项间间隔。这将覆盖页导航视图提供的默认interitemSpacing。
    open func proposedInteritemSpacing() -> CGFloat {
        guard let pagerView = self.pagerView else {
            return 0
        }
        let scrollDirection = pagerView.scrollDirection
        switch self.type {
        case .overlap:
            guard scrollDirection == .horizontal else {
                return 0
            }
            return pagerView.itemSize.width * -self.minimumScale * 0.6
        case .linear:
            guard scrollDirection == .horizontal else {
                return 0
            }
            return pagerView.itemSize.width * -self.minimumScale * 0.2
        case .coverFlow:
            guard scrollDirection == .horizontal else {
                return 0
            }
            return -pagerView.itemSize.width * sin(.pi*0.25*0.25*3.0)
        case .ferrisWheel,.invertedFerrisWheel:
            guard scrollDirection == .horizontal else {
                return 0
            }
            return -pagerView.itemSize.width * 0.15
        case .cubic:
            return 0
        case .rotate3D:
            return scrollDirection == .horizontal ?
                -pagerView.itemSize.width * 0.2 :
                -pagerView.itemSize.height * 0.2
        case .parallax:
            return scrollDirection == .horizontal ?
                pagerView.itemSize.width * 0.1 :
                pagerView.itemSize.height * 0.1
        case .springy:
            return scrollDirection == .horizontal ?
                pagerView.itemSize.width * 0.3 :
                pagerView.itemSize.height * 0.3
        case .flip:
            return scrollDirection == .horizontal ?
                -pagerView.itemSize.width * 0.3 :
                -pagerView.itemSize.height * 0.3
        case .cards:
            return cardSpacing
        case .cylinder:
            return scrollDirection == .horizontal ?
                -pagerView.itemSize.width * 0.2 :
                -pagerView.itemSize.height * 0.2
        case .wave:
            return scrollDirection == .horizontal ?
                pagerView.itemSize.width * 0.1 :
                pagerView.itemSize.height * 0.1
        case .windmill:
            return scrollDirection == .horizontal ?
                pagerView.itemSize.width * 0.15 :
                pagerView.itemSize.height * 0.15
        case .accordion:
            return scrollDirection == .horizontal ?
                -pagerView.itemSize.width * 0.5 :
                -pagerView.itemSize.height * 0.5
        case .carousel:
            return scrollDirection == .horizontal ?
                pagerView.itemSize.width * 0.2 :
                pagerView.itemSize.height * 0.2
        case .stack:
            return scrollDirection == .horizontal ?
                -pagerView.itemSize.width * 0.8 :
                -pagerView.itemSize.height * 0.8
        case .grid:
            return scrollDirection == .horizontal ?
                (pagerView.itemSize.width + gridSpacing) / CGFloat(gridColumns) :
                (pagerView.itemSize.height + gridSpacing) / CGFloat(gridRows)
        default:
            break
        }
        return pagerView.interitemSpacing
    }
}
