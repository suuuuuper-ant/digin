//
//  SlideOpenView.swift
//  Digin
//
//  Created by jinho jeong on 2021/04/29.
//

import UIKit

class SlideOpenView: UIView {

    let backgroundView: UIView = {
        let background = UIView()
        background.backgroundColor = UIColor.init(named: "main_color")
        return background
    }()

    let indicatorView: GradientView = {
        guard let start = UIColor.init(named: "slidebar_start_color"), let end = UIColor.init(named: "pull_indicator")  else {
            return GradientView(gradientStartColor: .purple, gradientEndColor: .purple)

        }

        return GradientView(gradientStartColor: start, gradientEndColor: end)
    }()
    let textLabel: UILabel = {
       let label = UILabel()
        label.text = "밀어서 잠금해제"
        label.textAlignment = .center
        label.textColor = .white
        return label
    }()

    let showMeView: UIImageView = {
        let showMe = UIImageView()
        let image = UIImage(named: "icon_bubble_start")
        showMe.image = image
        return showMe
    }()

    let showMeEndView: UIImageView = {
        let showMe = UIImageView()
        let image = UIImage(named: "icon_bubble_end")
        showMe.image = image
        return showMe
    }()

    let showMeTitle: UILabel = {
        let showMeTitle = UILabel()
        showMeTitle.text = "Show me"
        showMeTitle.textAlignment = .center
        showMeTitle.textColor = .blue
        showMeTitle.font = UIFont.boldSystemFont(ofSize: 12)
        return showMeTitle
    }()

    let showMeEndTitle: UILabel = {
        let showMeTitle = UILabel()
        showMeTitle.text = "Good!"
        showMeTitle.textAlignment = .center
        showMeTitle.textColor = .blue
        showMeTitle.font = UIFont.boldSystemFont(ofSize: 12)
        return showMeTitle
    }()

    public var sliderCornerRadius: CGFloat = 30.0 {
            didSet {
                backgroundView.layer.cornerRadius = sliderCornerRadius
                indicatorView.layer.cornerRadius = sliderCornerRadius - thumbnailViewStartingDistance
                indicatorView.gradient.cornerRadius = sliderCornerRadius - thumbnailViewStartingDistance
            }
        }
    private var panGestureRecognizer: UIPanGestureRecognizer!

    public var thumbnailViewStartingDistance: CGFloat = 0.0 {
        didSet {
            indicatorHeightAnchor?.constant = -thumbnailViewStartingDistance * 2
            indicatorLeadingAnchor?.constant =  thumbnailViewStartingDistance
            setNeedsLayout()
        }
    }

    private var xEndingPoint: CGFloat {
        return self.frame.width
    }

    private var initialWidth: CGFloat {
        return self.frame.width - self.backgroundView.frame.height
    }

    private var didSetup: Bool = false

    override init(frame: CGRect) {
        super.init(frame: frame)

        setupView()
        setupConstraints()
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        print(backgroundView.frame)
        let backBounds =  backgroundView.bounds
        indicatorView.gradient.frame = CGRect(origin: backBounds.origin, size: CGSize(width: backBounds.width - (thumbnailViewStartingDistance * 2), height: backBounds.height))

    }
    private func setupView() {

        addSubview(backgroundView)
        addSubview(showMeView)
        addSubview(showMeEndView)
        showMeView.addSubview(showMeTitle)
        showMeEndView.addSubview(showMeEndTitle)

        backgroundView.addSubview(textLabel)
        backgroundView.addSubview(indicatorView)
        showMeView.translatesAutoresizingMaskIntoConstraints = false
        backgroundView.translatesAutoresizingMaskIntoConstraints = false
        indicatorView.translatesAutoresizingMaskIntoConstraints = false
        textLabel.translatesAutoresizingMaskIntoConstraints = false
        showMeTitle.translatesAutoresizingMaskIntoConstraints = false
        showMeEndView.translatesAutoresizingMaskIntoConstraints = false
        showMeEndTitle.translatesAutoresizingMaskIntoConstraints = false
        panGestureRecognizer = UIPanGestureRecognizer(target: self, action: #selector(self.handlePanGesture(_:)))
        panGestureRecognizer.minimumNumberOfTouches = 1
        indicatorView.addGestureRecognizer(panGestureRecognizer)

        backgroundView.clipsToBounds = true
        indicatorView.clipsToBounds = true
        backgroundView.layer.cornerRadius = sliderCornerRadius
      //  indicatorView.layer.cornerRadius = sliderCornerRadius - 3

        showMeEndView.isHidden = true

        indicatorView.flatColor()

        UIDevice.current.beginGeneratingDeviceOrientationNotifications()
//        NotificationCenter.default.addObserver(
//            self,
//            selector: #selector(self.orientationChanged(notification:)),
//            name: NSNotification.Name.Devid
//            object: nil
//        )
      //  NotificationCenter.default.addObserver(self, selector: #selector(self.orientationChanged(notification:)), name: Notification.Name., object: nil)
        UIDevice.current.beginGeneratingDeviceOrientationNotifications()
                NotificationCenter.default.addObserver(self, selector: #selector(deviceOrientationDidChange), name: UIDevice.orientationDidChangeNotification, object: nil)
    }

    @objc func deviceOrientationDidChange() {
        switch UIDevice.current.orientation {

        case .portrait:
            print("portrai")
        case .portraitUpsideDown:
            print("portraitUpsideDown")
        case .landscapeLeft:
            print("landscapeLeft")
        case .landscapeRight:
            print("landscapeRight")
        case .faceUp:
            print("faceUp")
        case .faceDown:
            print("faceDown")
        @unknown default:
            print("default")
        }
        if UIDevice.current.orientation.rawValue < 4  && !UIDevice.current.orientation.isFlat {
            resetIndicator()
        }
        print("====")
    }

    deinit {
        NotificationCenter.default.removeObserver(self)
    }

    func resetIndicator() {
        let const = indicatorHeightAnchor?.constant ?? 0
        let map = const + (thumbnailViewStartingDistance * 2)
        indicatorWidthAnchor?.constant = map
        switchToBubleView(end: false)
        indicatorView.flatColor()

    }
    var indicatorWidthAnchor: NSLayoutConstraint?
    var indicatorHeightAnchor: NSLayoutConstraint?
    var indicatorLeadingAnchor: NSLayoutConstraint?
    private func setupConstraints() {

        backgroundView.leadingAnchor.constraint(equalTo: leadingAnchor).isActive = true
        backgroundView.trailingAnchor.constraint(equalTo: trailingAnchor).isActive = true
        backgroundView.heightAnchor.constraint(equalToConstant: 80).isActive = true
        backgroundView.bottomAnchor.constraint(equalTo: bottomAnchor).isActive = true

        textLabel.fittingView(backgroundView)

        indicatorLeadingAnchor = indicatorView.leadingAnchor.constraint(equalTo: backgroundView.leadingAnchor, constant: thumbnailViewStartingDistance)
        indicatorLeadingAnchor?.isActive = true
        indicatorView.centerYAnchor.constraint(equalTo: backgroundView.centerYAnchor).isActive = true
        indicatorHeightAnchor = indicatorView.heightAnchor.constraint(equalTo: backgroundView.heightAnchor, constant: -thumbnailViewStartingDistance)
        indicatorHeightAnchor?.isActive = true
        indicatorWidthAnchor = indicatorView.widthAnchor.constraint(equalTo: indicatorView.heightAnchor)
        indicatorWidthAnchor?.isActive = true

        showMeView.centerXAnchor.constraint(equalTo: indicatorView.trailingAnchor, constant: -20).isActive = true
        showMeView.bottomAnchor.constraint(equalTo: backgroundView.topAnchor, constant: -11).isActive = true
        //showMeView.widthAnchor.constraint(equalToConstant: 87).isActive = true
      //  showMeView.heightAnchor.constraint(equalToConstant: 36).isActive = true

        showMeTitle.leadingAnchor.constraint(equalTo: showMeView.leadingAnchor, constant: 16).isActive = true
        showMeTitle.trailingAnchor.constraint(equalTo: showMeView.trailingAnchor, constant: -16).isActive = true
        showMeTitle.topAnchor.constraint(equalTo: showMeView.topAnchor, constant: 6).isActive = true
        showMeTitle.bottomAnchor.constraint(equalTo: showMeView.bottomAnchor, constant: -11).isActive = true

        showMeEndView.leadingAnchor.constraint(equalTo: showMeView.leadingAnchor).isActive = true
        showMeEndView.bottomAnchor.constraint(equalTo: showMeView.bottomAnchor).isActive = true
        //showMeView.widthAnchor.constraint(equalToConstant: 87).isActive = true
      //  showMeView.heightAnchor.constraint(equalToConstant: 36).isActive = true

        showMeEndTitle.leadingAnchor.constraint(equalTo: showMeEndView.leadingAnchor, constant: 16).isActive = true
        showMeEndTitle.trailingAnchor.constraint(equalTo: showMeEndView.trailingAnchor, constant: -16).isActive = true
        showMeEndTitle.topAnchor.constraint(equalTo: showMeEndView.topAnchor, constant: 6).isActive = true
        showMeEndTitle.bottomAnchor.constraint(equalTo: showMeEndView.bottomAnchor, constant: -11).isActive = true

    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    @objc private func handlePanGesture(_ sender: UIPanGestureRecognizer) {

        let translatedPoint = sender.translation(in: backgroundView).x

        switch sender.state {
        case .began:
            break
        case .changed:
            let persent = (translatedPoint / initialWidth)

            self.textLabel.alpha = 1.0 - persent
            if translatedPoint  >= initialWidth {
                indicatorWidthAnchor?.constant = initialWidth
                switchToBubleView(end: true)

            } else if translatedPoint <= 0 {
                indicatorView.flatColor()
                break
            } else {
                switchToBubleView(end: false)
                indicatorWidthAnchor?.constant = translatedPoint
            }
            indicatorView.gradientColor()

        case .ended:
            var persent: CGFloat = 0.0
            if translatedPoint >= (initialWidth / 2) {
                indicatorWidthAnchor?.constant = initialWidth
                switchToBubleView(end: true)
            } else {
                let const = indicatorHeightAnchor?.constant ?? 0
                let map = const + (thumbnailViewStartingDistance * 2)
                persent = 1.0
                indicatorWidthAnchor?.constant = map
                switchToBubleView(end: false)
                indicatorView.flatColor()
            }

            UIView.animate(withDuration: 0.1, delay: 0.0, options: [.curveEaseIn]) {
                self.textLabel.alpha = persent
                self.layoutIfNeeded()
            } completion: { _ in

            }

        default:
            break
        }
    }

    private func switchToBubleView(end: Bool) {
        if end {
            showMeView.isHidden = true
            showMeEndView.isHidden = false
        } else {
            showMeView.isHidden = false
            showMeEndView.isHidden = true
        }
    }

}

class GradientView: UIView {

    let gradient: CAGradientLayer = CAGradientLayer()
    private let gradientStartColor: UIColor
    private let gradientEndColor: UIColor

    init(gradientStartColor: UIColor, gradientEndColor: UIColor) {
        self.gradientStartColor = gradientStartColor
        self.gradientEndColor = gradientEndColor
        super.init(frame: .zero)
    }

    required init?(coder aDecoder: NSCoder) { fatalError("init(coder:) has not been implemented") }

//    override func layoutSubviews() {
//        superview?.layoutSubviews()
//        refreshGradientLayer()
//    }
    override var frame: CGRect {
        didSet {
           setNeedsLayout()
        }
    }
    override public func draw(_ rect: CGRect) {
        gradient.frame = self.bounds
        //gradient.cornerRadius = self.bounds.height / 2
        gradient.masksToBounds = true
        layer.masksToBounds = true
        gradient.colors = [gradientStartColor.cgColor, gradientEndColor.cgColor]
        gradient.startPoint = CGPoint(x: 0, y: 0.5)
        gradient.endPoint = CGPoint(x: 1.0, y: 0.5)
        if gradient.superlayer == nil {
            layer.insertSublayer(gradient, at: 0)
        }
    }

    private func refreshGradientLayer() {
        gradient.frame = bounds
    }

     func flatColor() {
        gradient.locations = [1]
    }
     func gradientColor() {
        gradient.locations = [0.1]
    }
}
