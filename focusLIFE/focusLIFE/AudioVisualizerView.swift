import UIKit

class AudioVisualizerView: UIView {
    private var waveLayer: CAShapeLayer!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setup()
    }
    
    private func setup() {
        waveLayer = CAShapeLayer()
        waveLayer.strokeColor = UIColor.white.cgColor
        waveLayer.lineWidth = 2.0
        waveLayer.fillColor = UIColor.clear.cgColor
        layer.addSublayer(waveLayer)
    }
    
    func update(with power: Float) {
        let normalizedPower = max(0.2, CGFloat(power) + 50) / 50
        let wavePath = UIBezierPath()
        let midY = bounds.midY
        let amplitude = bounds.height * 0.02 * normalizedPower // 调整振幅范围
        
        wavePath.move(to: CGPoint(x: 0, y: midY))
        for x in stride(from: 0, through: bounds.width, by: 5) {
            let scaling = -pow(1 / midY * (x - midY), 2) + 1
            let frequency: CGFloat = 8 // 調整頻率的值
            let y = scaling * amplitude * sin(x / frequency) + midY
            wavePath.addLine(to: CGPoint(x: x, y: y))
        }

        
        waveLayer.path = wavePath.cgPath
    }

}
