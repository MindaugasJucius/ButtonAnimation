import UIKit

fileprivate let AnimationDuration = 0.8

enum FillState {
    case initial
    case altered
    
    var oppositeState: FillState {
        switch self {
        case .initial:
            return .altered
        case .altered:
            return .initial
        }
    }
    
}

class FillableView: UIView {

    private var startShape: CAShapeLayer = CAShapeLayer()
    private var state: FillState = .initial
    private var diameter: CGFloat = 0.0
    private var controlFrame: CGRect = .zero
    
    var initialColor: UIColor = .gray {
        didSet {
            backgroundColor = initialColor
        }
    }
    
    var filledColor: UIColor = .black {
        didSet {
            label.textColor = filledColor
        }
    }

    @IBOutlet weak var fillButton: UIButton?
    @IBOutlet weak var fillSwitch: UISwitch?
    @IBOutlet weak var label: UILabel!
    
    static func switchFillable() -> FillableView? {
        return Bundle.main.loadNibNamed("FillableViewSwitch", owner: self, options: nil)?.first as? FillableView
    }

    static func buttonFillable() -> FillableView? {
        return Bundle.main.loadNibNamed("FillableViewButton", owner: self, options: nil)?.first as? FillableView
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        setupLabel()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        setupControl(control: fillSwitch)
        setupControl(control: fillButton)
    }
    
    private func color(forState state: FillState) -> UIColor {
        return state == .initial ? initialColor : filledColor
    }
    
    private func setupControl(control: UIControl?) {
        guard let control = control else { return }
        controlFrame = control.frame
        diameter = control.frame.height
        startShape = createCircle(ofDiameter: diameter)
        layer.insertSublayer(startShape, below: label.layer)
        if control is UISwitch, let fillControl = control as? UISwitch {
            setupAppearance(forSwitch: fillControl)
        }
        if control is UIButton, let fillControl = control as? UIButton {
            setupAppearance(forButton: fillControl)
        }
    }
    
    private func setupLabel() {
        label.font = UIFont.systemFont(ofSize: 15, weight: UIFontWeightMedium)
        label.text = "Tap and watch".uppercased()
    }
    
    // MARK: - Paths
    
    private func createCircle(ofDiameter diameter: CGFloat) -> CAShapeLayer {
        let circleShape = CAShapeLayer()
        circleShape.bounds = CGRect(x: 0, y: 0, width: diameter, height: diameter)
        circleShape.path = UIBezierPath(ovalIn: circleShape.bounds).cgPath
        circleShape.position = CGPoint(x: controlFrame.midX,
                                       y: controlFrame.midY)
        circleShape.fillColor = color(forState: state.oppositeState).cgColor
        return circleShape
    }
    
    // MARK: - Button
    
    private func setupAppearance(forButton button: UIButton) {
        button.contentEdgeInsets = UIEdgeInsets(top: 10, left: 50, bottom: 10, right: 50)
        button.setTitleColor(.white, for: .normal)
        button.backgroundColor = .clear
        button.layer.cornerRadius = 18
        button.layer.borderWidth = 2
        button.titleLabel?.font = UIFont.systemFont(ofSize: 14, weight: UIFontWeightThin)
        button.setTitle("Night mode".uppercased(), for: .normal)
        button.backgroundColor = color(forState: state.oppositeState)
        button.layer.borderColor = UIColor.white.cgColor
        button.addTarget(self, action: #selector(changedControl), for: .touchUpInside)
    }

    // MARK: - Switch
    
    private func setupAppearance(forSwitch switchControl: UISwitch) {
        switchControl.addTarget(self, action: #selector(changedControl), for: .valueChanged)
        switchControl.layer.borderWidth = 1
        switchControl.layer.borderColor = UIColor.white.cgColor
        switchControl.layer.cornerRadius = 16
        switchControl.onTintColor = color(forState: state.oppositeState)
        switchControl.backgroundColor = color(forState: state)
        switchControl.isOn = false
    }

    @objc private func changedControl() {
        fillButton?.backgroundColor = color(forState: state)
        state = state.oppositeState
        scalePath(toState: state)
        updateLabelColor()
    }
    
    // MARK: - Animations
    
    func scalePath(toState state: FillState) {
        let animation = CABasicAnimation(keyPath: "transform")
        var transform = CATransform3DIdentity
        if state == .altered {
            let scale = (bounds.height / diameter) *                                           3.1
            transform = CATransform3DMakeScale(scale, scale, 1)
        }
        animation.toValue = transform
        animation.duration = AnimationDuration
        animation.timingFunction = CAMediaTimingFunction(name:         kCAMediaTimingFunctionEaseIn)
        startShape.add(animation, forKey: animation.keyPath)
        startShape.transform = transform
    }
    
    func updateLabelColor() {
        UIView.transition(
            with: label,
            duration: 0.2,
            options: .transitionCrossDissolve,
            animations: { [unowned self] in
                self.label.textColor = self.color(forState: self.state.oppositeState)
        },
            completion: nil)
    }
}

extension UIColor {
    static func from(hex:String) -> UIColor {
        var cString:String = hex.trimmingCharacters(in: .whitespacesAndNewlines).uppercased()
        
        if (cString.hasPrefix("#")) {
            cString.remove(at: cString.startIndex)
        }
        
        if ((cString.characters.count) != 6) {
            return UIColor.gray
        }
        
        var rgbValue:UInt32 = 0
        Scanner(string: cString).scanHexInt32(&rgbValue)
        
        return UIColor(
            red: CGFloat((rgbValue & 0xFF0000) >> 16) / 255.0,
            green: CGFloat((rgbValue & 0x00FF00) >> 8) / 255.0,
            blue: CGFloat(rgbValue & 0x0000FF) / 255.0,
            alpha: CGFloat(1.0)
        )
    }
}
