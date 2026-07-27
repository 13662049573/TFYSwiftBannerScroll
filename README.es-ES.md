# TFYSwiftBannerScroll

<p align="center">
    <img src="banner.png" alt="TFYSwiftBannerScroll" title="TFYSwiftBannerScroll" width="557"/>
</p>

<p align="center">
    <a href="https://developer.apple.com/swift"><img src="https://img.shields.io/badge/language-Swift%205.0+-f48041.svg?style=flat"></a>
    <a href="https://developer.apple.com/ios"><img src="https://img.shields.io/badge/platform-iOS%2012.0+-blue.svg?style=flat"></a>
    <a href="https://github.com/13662049573/TFYSwiftBannerScroll/blob/main/LICENSE"><img src="https://img.shields.io/badge/license-MIT-blue.svg"></a>
    <a href="https://cocoapods.org/pods/TFYSwiftBannerScroll"><img src="https://img.shields.io/cocoapods/v/TFYSwiftBannerScroll.svg?style=flat"></a>
    <a href="https://github.com/13662049573/TFYSwiftBannerScroll"><img src="https://img.shields.io/github/stars/13662049573/TFYSwiftBannerScroll.svg?style=social&label=Star"></a>
</p>

## Introducción

TFYSwiftBannerScroll es un componente de carrusel (banner) para iOS potente y altamente personalizable. Ofrece una amplia gama de efectos de animación y formas de interacción, permitiendo crear fácilmente carruseles de imágenes elegantes, exhibiciones publicitarias y más. Soporta Cells personalizadas, indicadores de página personalizados e incluye múltiples efectos de animación de transición impactantes.

## Vista Previa

<p align="center">
<img src="preview1.gif" width="210"/>
<img src="preview2.gif" width="210"/>
<img src="preview3.gif" width="210"/>
</p>

## ✨ Características

- [x] Soporte para desplazamiento horizontal y vertical
- [x] Soporte para desplazamiento en bucle infinito
- [x] Múltiples efectos de animación de transición integrados:
  - 🌊 Efecto de desvanecimiento (crossFading)
  - 🔍 Efecto de zoom (zoomOut) 
  - 🌈 Efecto de profundidad (depth)
  - 🎭 Efecto de superposición (overlap)
  - ➡️ Efecto lineal (linear)
  - 📱 Efecto CoverFlow (coverFlow)
  - 🎡 Efecto Noria/Rueda de la fortuna (ferrisWheel)
  - 🎲 Efecto Cubo 3D (cubic)
- [x] Soporte para desplazamiento automático con intervalo personalizable
- [x] Estilos personalizados para el indicador de página
- [x] Soporte para Cells personalizadas
- [x] Métodos de delegado enriquecidos
- [x] Sistema de diseño completamente personalizable
- [x] Soporte para interacción gestual
- [x] Soporte para Interface Builder
- [x] Documentación completa y código de ejemplo

## 📋 Requisitos del Sistema

- iOS 15.0+
- Swift 5.0+
- Xcode 14.0+

## 📲 Instalación

### CocoaPods

```ruby
pod 'TFYSwiftBannerScroll'
```

### Swift Package Manager

```swift
dependencies: [
    .package(url: "https://github.com/13662049573/TFYSwiftBannerScroll.git", .upToNextMajor(from: "2.0.5"))
]
```

### Instalación Manual

Simplemente arrastra la carpeta `TFYSwiftBannerScrollKit` a tu proyecto.

## 🚀 Inicio Rápido

### Uso Básico

```swift
import TFYSwiftBannerScroll

class ViewController: UIViewController {
    
    @IBOutlet weak var pagerView: TFYSwiftPagerView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // 1. Registrar Cell
        pagerView.register(TFYSwiftPagerViewCell.self, forCellWithReuseIdentifier: "cell")
        
        // 2. Configurar fuente de datos y delegado
        pagerView.dataSource = self
        pagerView.delegate = self
        
        // 3. Configurar propiedades básicas
        pagerView.automaticSlidingInterval = 3.0  // Intervalo de desplazamiento automático
        pagerView.isInfinite = true              // Bucle infinito
        
        // 4. Configurar animación de transición
        pagerView.transformer = TFYSwiftPagerViewTransformer(type: .coverFlow)
    }
}

// MARK: - Métodos de fuente de datos
extension ViewController: TFYSwiftPagerViewDataSource {
    func numberOfItems(in pagerView: TFYSwiftPagerView) -> Int {
        return items.count
    }
    
    func pagerView(_ pagerView: TFYSwiftPagerView, cellForItemAt index: Int) -> TFYSwiftPagerViewCell {
        let cell = pagerView.dequeueReusableCell(withReuseIdentifier: "cell", at: index)
        cell.imageView?.image = items[index].image
        cell.textLabel?.text = items[index].title
        return cell
    }
}
```

### Indicador de Página Personalizado

```swift
let pageControl = TFYSwiftPageControl()
pageControl.numberOfPages = 5
pageControl.currentPage = 0

// Personalizar estilo
pageControl.setStrokeColor(.white, for: .normal)
pageControl.setFillColor(.white, for: .selected)
pageControl.setPath(UIBezierPath(roundedRect: CGRect(x: 0, y: 0, width: 8, height: 8), cornerRadius: 4), for: .normal)
pageControl.setPath(UIBezierPath(roundedRect: CGRect(x: 0, y: 0, width: 16, height: 8), cornerRadius: 4), for: .selected)
```

## 📖 Documentación Detallada

### Tipos de Animación de Transición

TFYSwiftBannerScroll ofrece múltiples efectos de transición integrados:

```swift
// Efecto básico
pagerView.transformer = TFYSwiftPagerViewTransformer(type: .crossFading)

// Parámetros personalizados
let transformer = TFYSwiftPagerViewTransformer(type: .zoomOut)
transformer.minimumScale = 0.8
transformer.minimumAlpha = 0.5
pagerView.transformer = transformer
```

### Métodos del Delegado

```swift
extension ViewController: TFYSwiftPagerViewDelegate {
    // Evento de clic
    func pagerView(_ pagerView: TFYSwiftPagerView, didSelectItemAt index: Int) {
        print("Se hizo clic en el ítem \(index)")
    }
    
    // Eventos de desplazamiento
    func pagerViewWillBeginDragging(_ pagerView: TFYSwiftPagerView) {
        print("Iniciando arrastre")
    }
    
    func pagerViewDidScroll(_ pagerView: TFYSwiftPagerView) {
        print("Desplazando")
    }
    
    func pagerViewDidEndDecelerating(_ pagerView: TFYSwiftPagerView) {
        print("Desplazamiento finalizado")
    }
}
```

## 🌟 Uso Avanzado

### Cell Personalizada

```swift
class CustomCell: TFYSwiftPagerViewCell {
    override func commonInit() {
        super.commonInit()
        // Personalizar UI
    }
}
```

### Desplazamiento Vertical

```swift
pagerView.scrollDirection = .vertical
```

## 📱 Proyecto de Ejemplo

Clona el proyecto y ejecuta el ejemplo:

```bash
git clone https://github.com/13662049573/TFYSwiftBannerScroll.git
cd TFYSwiftBannerScroll/Example
pod install
open TFYSwiftBannerScroll.xcworkspace
```

## 🔨 Registro de Cambios
### 2.0.6
- Corrección de problemas de desplazamiento automático
- Corrección de problemas de paginación
- Otras correcciones generales

### 2.0.5
- Lanzamiento de la versión inicial
- Soporte para funciones básicas de carrusel
- Adición de múltiples animaciones de transición:
  ```swift
  case crossFading       // Efecto de desvanecimiento
  case zoomOut           // Efecto de zoom out
  case depth             // Efecto de profundidad 3D
  case overlap           // Efecto de tarjetas superpuestas
  case linear            // Efecto de deslizamiento lineal
  case coverFlow         // Efecto CoverFlow
  case ferrisWheel       // Efecto Noria
  case invertedFerrisWheel // Efecto Noria invertida
  case cubic             // Efecto Cubo 3D
  case rotate3D          // Efecto de rotación 3D
  case parallax          // Efecto de desplazamiento parallax
  case springy           // Efecto de animación elástica
  case flip              // Efecto de giro de página
  case cards             // Efecto de tarjetas apiladas
  case cylinder          // Efecto de disposición cilíndrica
  case wave              // Efecto de onda
  case windmill          // Efecto de rotación de molino
  case accordion         // Efecto de plegado de acordeón
  case carousel          // Efecto carrusel clásico
  case stack             // Efecto de pila de tarjetas
  case grid              // Efecto de diseño de cuadrícula
  ```

### 2.0.5
- Lanzamiento de la versión inicial
- Soporte para funciones básicas de carrusel
- Adición de múltiples animaciones de transición

## ❤️ Contribución

Las Issues y Pull Requests son bienvenidas.

## 👨‍💻 Autor

Tianyou Tian (田风有)

## 📄 Licencia

TFYSwiftBannerScroll es código abierto bajo la licencia MIT. Para más detalles, consulta el archivo [LICENSE](LICENSE).
