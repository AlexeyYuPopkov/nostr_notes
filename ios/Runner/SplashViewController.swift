import UIKit
import AVFoundation
#if canImport(Lottie)
import Lottie
#endif

struct EasySplashNativeConfig {
    let duration: TimeInterval
    let text: String?
    let backgroundLightHex: String
    let backgroundDarkHex: String
    let imageLightName: String?
    let imageDarkName: String?
    let lottieLightName: String?
    let lottieDarkName: String?
    let soundName: String?
    let textColorLightHex: String
    let textColorDarkHex: String
    let indicatorColorLightHex: String
    let indicatorColorDarkHex: String
    let showsIndicator: Bool
    let indicatorPosition: String
    let textPosition: String
    let flutterImageAssetLight: String?
    let flutterImageAssetDark: String?
    let flutterLottieAssetLight: String?
    let flutterLottieAssetDark: String?
    let flutterSoundAsset: String?
}

enum IndicatorPlacement: String {
    case auto
    case belowVisual = "below_visual"
    case aboveText = "above_text"
}

enum TextPlacement: String {
    case auto
    case belowVisual = "below_visual"
    case bottom
}

final class EasySplashCoordinator {
    private weak var window: UIWindow?
    private let config: EasySplashNativeConfig
    private var overlayWindow: UIWindow?

    init(window: UIWindow?, config: EasySplashNativeConfig) {
        self.window = window
        self.config = config
    }

    func presentIfNeeded() {
        guard overlayWindow == nil, let baseWindow = window else { return }
        let overlay = UIWindow(frame: baseWindow.bounds)
        overlay.accessibilityIdentifier = "EasySplashOverlay"
        overlay.windowLevel = baseWindow.windowLevel + 1
        let controller = SplashViewController(config: config) { [weak self] in
            self?.dismiss()
        }
        overlay.rootViewController = controller
        overlay.isHidden = false
        overlayWindow = overlay
    }

    private func dismiss() {
        overlayWindow?.isHidden = true
        overlayWindow = nil
    }
}

final class SplashViewController: UIViewController {
    private let config: EasySplashNativeConfig
    private let completion: () -> Void
    private var player: AVAudioPlayer?

    init(config: EasySplashNativeConfig, completion: @escaping () -> Void) {
        self.config = config
        self.completion = completion
        super.init(nibName: nil, bundle: nil)
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = SplashViewController.dynamicColor(
            lightHex: config.backgroundLightHex,
            darkHex: config.backgroundDarkHex
        )
        setupContent()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        scheduleCompletion()
        playSoundIfNeeded()
    }

    private func setupContent() {
        let safeArea = view.safeAreaLayoutGuide

        var visualView: UIView?

#if canImport(Lottie)
        if let lottieName = resolvedLottieName() {
            var animation: Animation? = Animation.named(lottieName, bundle: .main)
            if animation == nil,
               let fallback = resolvedLottieFallback(),
               let url = SplashViewController.fileURL(named: lottieName, fallback: fallback) {
                animation = try? Animation.filepath(url.path)
            }
            if let animation = animation {
                let animationView = LottieAnimationView(animation: animation)
                animationView.translatesAutoresizingMaskIntoConstraints = false
                animationView.loopMode = .loop
                animationView.contentMode = .scaleAspectFit
                animationView.play()
                view.addSubview(animationView)
                visualView = animationView
            }
        }
#endif

        if visualView == nil,
           let imageName = resolvedImageName(),
           let image = SplashViewController.loadImage(named: imageName, fallback: resolvedImageFallback()) {
            let imageView = UIImageView(image: image)
            imageView.translatesAutoresizingMaskIntoConstraints = false
            imageView.contentMode = .scaleAspectFit
            view.addSubview(imageView)
            visualView = imageView
        }

        let hasText = (config.text?.isEmpty == false)
        let indicatorPlacementRaw = IndicatorPlacement(rawValue: config.indicatorPosition) ?? .auto
        let textPlacementRaw = TextPlacement(rawValue: config.textPosition) ?? .auto

        let resolvedTextPlacement: TextPlacement = {
            switch textPlacementRaw {
            case .auto:
                return visualView != nil ? .belowVisual : .bottom
            default:
                return textPlacementRaw
            }
        }()

        let resolvedIndicatorPlacement: IndicatorPlacement = {
            switch indicatorPlacementRaw {
            case .auto:
                if visualView != nil { return .belowVisual }
                return hasText ? .aboveText : .belowVisual
            case .aboveText:
                return hasText ? .aboveText : .belowVisual
            case .belowVisual:
                return .belowVisual
            }
        }()

        var label: UILabel?
        if hasText, let text = config.text {
            let textLabel = UILabel()
            textLabel.translatesAutoresizingMaskIntoConstraints = false
            textLabel.text = text
            textLabel.textColor = SplashViewController.dynamicColor(
                lightHex: config.textColorLightHex,
                darkHex: config.textColorDarkHex
            )
            textLabel.font = UIFont.systemFont(ofSize: 16, weight: .medium)
            textLabel.numberOfLines = 0
            textLabel.textAlignment = .center
            view.addSubview(textLabel)
            label = textLabel
        }

        var indicatorView: UIActivityIndicatorView?
        if config.showsIndicator {
            let indicator = UIActivityIndicatorView(style: .medium)
            indicator.translatesAutoresizingMaskIntoConstraints = false
            indicator.hidesWhenStopped = false
            indicator.color = SplashViewController.dynamicColor(
                lightHex: config.indicatorColorLightHex,
                darkHex: config.indicatorColorDarkHex
            )
            indicator.startAnimating()
            view.addSubview(indicator)
            indicatorView = indicator
        }

        var effectiveIndicatorPlacement = resolvedIndicatorPlacement
        if indicatorView == nil {
            effectiveIndicatorPlacement = .belowVisual
        } else if label == nil && resolvedIndicatorPlacement == .aboveText {
            effectiveIndicatorPlacement = .belowVisual
        }

        var effectiveTextPlacement = resolvedTextPlacement
        if effectiveTextPlacement == .belowVisual,
           visualView == nil,
           effectiveIndicatorPlacement != .belowVisual {
            effectiveTextPlacement = .bottom
        }

        var constraints: [NSLayoutConstraint] = []

        if let visual = visualView {
            constraints.append(visual.centerXAnchor.constraint(equalTo: view.centerXAnchor))
            constraints.append(visual.centerYAnchor.constraint(equalTo: view.centerYAnchor))
            if visual is LottieAnimationView {
                constraints.append(visual.widthAnchor.constraint(equalToConstant: 200))
                constraints.append(visual.heightAnchor.constraint(equalToConstant: 200))
            } else {
                constraints.append(visual.widthAnchor.constraint(lessThanOrEqualToConstant: 240))
                constraints.append(visual.heightAnchor.constraint(lessThanOrEqualToConstant: 240))
            }
        }

        if let indicator = indicatorView {
            constraints.append(indicator.centerXAnchor.constraint(equalTo: view.centerXAnchor))
        }

        if let label = label {
            constraints.append(label.centerXAnchor.constraint(equalTo: view.centerXAnchor))
        }

        var previousAnchor: NSLayoutYAxisAnchor = visualView?.bottomAnchor ?? safeArea.topAnchor
        var isFirstItem = true
        var chain: [UIView] = []

        if let indicator = indicatorView {
            chain.append(indicator)
        }

        if let label = label, effectiveTextPlacement == .belowVisual {
            chain.append(label)
        }

        for view in chain {
            let spacing: CGFloat = isFirstItem ? 24 : 16
            constraints.append(view.topAnchor.constraint(equalTo: previousAnchor, constant: spacing))
            previousAnchor = view.bottomAnchor
            isFirstItem = false
        }

        if let indicator = indicatorView,
           chain.first === indicator,
           visualView == nil,
           label == nil {
            constraints.append(indicator.centerYAnchor.constraint(equalTo: view.centerYAnchor))
        }

        if let label = label {
            switch effectiveTextPlacement {
            case .bottom:
                constraints.append(label.bottomAnchor.constraint(equalTo: safeArea.bottomAnchor, constant: -32))
                if let indicator = indicatorView {
                    if effectiveIndicatorPlacement == .aboveText {
                        constraints.append(indicator.bottomAnchor.constraint(equalTo: label.topAnchor, constant: -16))
                    } else {
                        constraints.append(indicator.bottomAnchor.constraint(lessThanOrEqualTo: label.topAnchor, constant: -16))
                    }
                } else if let visual = visualView {
                    constraints.append(label.topAnchor.constraint(greaterThanOrEqualTo: visual.bottomAnchor, constant: 24))
                }
            case .belowVisual:
                constraints.append(label.bottomAnchor.constraint(lessThanOrEqualTo: safeArea.bottomAnchor, constant: -24))
                if visualView == nil && indicatorView == nil {
                    constraints.append(label.centerYAnchor.constraint(equalTo: view.centerYAnchor))
                }
            case .auto:
                break
            }
        }

        if let indicator = indicatorView,
           label == nil,
           visualView == nil,
           effectiveIndicatorPlacement == .belowVisual {
            constraints.append(indicator.centerYAnchor.constraint(equalTo: view.centerYAnchor))
        }

        if let indicator = indicatorView,
           let label = label,
           effectiveIndicatorPlacement == .aboveText {
            constraints.append(indicator.bottomAnchor.constraint(equalTo: label.topAnchor, constant: -16))
        }

        NSLayoutConstraint.activate(constraints)
    }

    private func resolvedImageName() -> String? {
        if #available(iOS 13.0, *) {
            if traitCollection.userInterfaceStyle == .dark {
                return config.imageDarkName ?? config.imageLightName
            }
        }
        return config.imageLightName ?? config.imageDarkName
    }

    private func resolvedImageFallback() -> String? {
        if #available(iOS 13.0, *) {
            if traitCollection.userInterfaceStyle == .dark {
                return config.flutterImageAssetDark ?? config.flutterImageAssetLight ?? config.flutterImageAssetDark
            }
        }
        return config.flutterImageAssetLight ?? config.flutterImageAssetDark
    }

    private func resolvedLottieName() -> String? {
        if #available(iOS 13.0, *) {
            if traitCollection.userInterfaceStyle == .dark {
                return config.lottieDarkName ?? config.lottieLightName
            }
        }
        return config.lottieLightName ?? config.lottieDarkName
    }

    private func resolvedLottieFallback() -> String? {
        if #available(iOS 13.0, *) {
            if traitCollection.userInterfaceStyle == .dark {
                return config.flutterLottieAssetDark ?? config.flutterLottieAssetLight ?? config.flutterLottieAssetDark
            }
        }
        return config.flutterLottieAssetLight ?? config.flutterLottieAssetDark
    }

    private func scheduleCompletion() {
        DispatchQueue.main.asyncAfter(deadline: .now() + config.duration) { [weak self] in
            self?.completion()
        }
    }

    private func playSoundIfNeeded() {
        guard let soundName = config.soundName,
              let url = SplashViewController.fileURL(named: soundName, fallback: config.flutterSoundAsset) else { return }
        do {
            player = try AVAudioPlayer(contentsOf: url)
            player?.play()
        } catch {
            print("EasySplash: could not play sound (soundName): \(error)")
        }
    }

    private static func dynamicColor(lightHex: String, darkHex: String) -> UIColor {
        let light = color(from: lightHex)
        let dark = color(from: darkHex)
        if #available(iOS 13.0, *) {
            return UIColor { traits in
                traits.userInterfaceStyle == .dark ? dark : light
            }
        }
        return light
    }

    private static func color(from hex: String) -> UIColor {
        var normalized = hex.trimmingCharacters(in: .whitespacesAndNewlines)
        if normalized.hasPrefix("#") {
            normalized.removeFirst()
        }
        guard normalized.count == 6,
              let value = UInt32(normalized, radix: 16) else {
            return .white
        }
        let red = CGFloat((value >> 16) & 0xFF) / 255.0
        let green = CGFloat((value >> 8) & 0xFF) / 255.0
        let blue = CGFloat(value & 0xFF) / 255.0
        return UIColor(red: red, green: green, blue: blue, alpha: 1.0)
    }

    private static func loadImage(named name: String, fallback: String?) -> UIImage? {
        guard let url = fileURL(named: name, fallback: fallback) else { return nil }
        return UIImage(contentsOfFile: url.path)
    }

    private static func textColor(from hex: String?) -> UIColor {
        if let hex = hex {
            return color(from: hex)
        }
        if #available(iOS 13.0, *) {
            return UIColor.label
        }
        return UIColor.white
    }

    private static func fileURL(named name: String, fallback: String?) -> URL? {
        if let direct = urlInMainBundle(for: name) {
            return direct
        }
        guard let fallback = fallback else { return nil }
        let normalized = fallback.hasPrefix("/") ? String(fallback.dropFirst()) : fallback
        let nsPath = normalized as NSString
        let directory = nsPath.deletingLastPathComponent
        let fileName = nsPath.lastPathComponent
        let components = fileName.split(separator: ".")
        let file = components.dropLast().joined(separator: ".")
        let ext = components.count > 1 ? String(components.last!) : nil
        let lookupDirectory = directory.isEmpty ? "flutter_assets" : "flutter_assets/(directory)"

        if let ext = ext,
           let path = Bundle.main.path(forResource: file, ofType: ext, inDirectory: lookupDirectory) {
            return URL(fileURLWithPath: path)
        }
        if let path = Bundle.main.path(forResource: fileName, ofType: nil, inDirectory: lookupDirectory) {
            return URL(fileURLWithPath: path)
        }
        return nil
    }

    private static func urlInMainBundle(for name: String) -> URL? {
        let components = name.split(separator: ".")
        if components.count > 1 {
            let file = components.dropLast().joined(separator: ".")
            let ext = String(components.last!)
            if let path = Bundle.main.path(forResource: file, ofType: ext) {
                return URL(fileURLWithPath: path)
            }
        }
        if let path = Bundle.main.path(forResource: name, ofType: nil) {
            return URL(fileURLWithPath: path)
        }
        return nil
    }
}
