import UIKit
import AVFoundation

class ViewController: UIViewController {
    // 連接到 storyboard 的 UI 元素
    @IBOutlet weak var blurEffectView: UIVisualEffectView!
    @IBOutlet weak var timerLabel: UILabel!
    @IBOutlet weak var startButton: UIButton!
    @IBOutlet weak var playButton: UIButton!
    
    // 計時器和時間變數
    var timer: Timer?
    var secondsElapsed = 1800 // 設置初始時間為1800秒
    var lofiPlayer: AVAudioPlayer?
    var lofiIndex = 0
    let musicList = ["lofi1", "lofi2", "lofi3"]
    var displayLink: CADisplayLink?
    var audioVisualizerView: AudioVisualizerView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // 初始化時間標籤
        timerLabel.text = formatTime(seconds: secondsElapsed)
        // 設置 UIVisualEffectView 的圓角
        blurEffectView.layer.cornerRadius = 20
        blurEffectView.clipsToBounds = true
        // 設置播放按鈕
        setPlayButton()
        // 初始化 AudioVisualizerView
        setupAudioVisualizerView()
        // 初始化 CADisplayLink
        displayLink = CADisplayLink(target: self, selector: #selector(updateVisualizer))
        displayLink?.add(to: .current, forMode: .default)
    }
    
    func setupAudioVisualizerView() {
        audioVisualizerView = AudioVisualizerView(frame: CGRect(x: 26, y: 663, width: 341, height: 128))
                // 设置视图属性（例如颜色、线宽等）
                audioVisualizerView.backgroundColor = UIColor.clear // 如果需要透明背景
                // 添加到视图层次结构中
                view.addSubview(audioVisualizerView)
    }
    
    // 開始按鈕點擊事件處理
    @IBAction func startButtonTapped(_ sender: UIButton) {
        if timer == nil {
            // 如果計時器未運行，則開始計時
            startTimer()
            loadLofi(index: lofiIndex)
            startButton.setTitle("Stop", for: .normal)
            playButton.setImage(UIImage(systemName: "pause.circle"), for: .normal)
        } else {
            // 如果計時器正在運行，則停止計時
            stopTimer()
            startButton.setTitle("Start", for: .normal)
            stopPlay()
            playButton.setImage(UIImage(systemName: "play.circle"), for: .normal)
        }
    }
    
    @IBAction func playMusicButtonTapped(_ sender: UIButton) {
        // 檢查音樂播放器是否正在播放
        if lofiPlayer?.isPlaying == true {
            // 如果正在播放，則暫停播放
            lofiPlayer?.pause()
            playButton.setImage(UIImage(systemName: "play.circle"), for: .normal)
        } else {
            // 如果沒有播放，則開始或繼續播放
            lofiPlayer?.play()
            playButton.setImage(UIImage(systemName: "pause.circle"), for: .normal)
        }
    }
    
    @IBAction func nextMusicPlayButtonTapped(_ sender: Any) {
        nextMusic()
    }
    
    @IBAction func backMusicPlayButtonTapped(_ sender: Any) {
        backMusic()
    }
    
    @IBAction func infoShow(_ sender: Any) {
        showInfoAlert()
    }
    
    // 開始計時
    func startTimer() {
        timer = Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(updateTime), userInfo: nil, repeats: true)
    }
    
    // 停止計時
    func stopTimer() {
        timer?.invalidate()
        timer = nil
    }
    
    // 更新時間標籤
    @objc func updateTime() {
        if secondsElapsed > 0 {
            secondsElapsed -= 1
            timerLabel.text = formatTime(seconds: secondsElapsed)
        } else {
            // 時間到，停止計時器
            stopTimer()
            startButton.setTitle("Start", for: .normal)
            showAlert()
            initSetting()
        }
    }
    
    // 格式化時間顯示
    func formatTime(seconds: Int) -> String {
        let hours = seconds / 3600
        let minutes = (seconds % 3600) / 60
        let seconds = seconds % 60
        return String(format: "%02d:%02d:%02d", hours, minutes, seconds)
    }
    
    func showAlert() {
        let alertController = UIAlertController(title: "時間到！", message: "倒數計時已結束。", preferredStyle: .alert)
        let okAction = UIAlertAction(title: "確定", style: .default, handler: nil)
        alertController.addAction(okAction)
        present(alertController, animated: true, completion: nil)
    }
    
    func showInfoAlert() {
        let alertController = UIAlertController(title: "Notice!", message: "完整專注倒數才會計算\n 音樂目前只有lofi,可與倒數分軌進行", preferredStyle: .alert)
        let okAction = UIAlertAction(title: "確定", style: .default, handler: nil)
        alertController.addAction(okAction)
        present(alertController, animated: true, completion: nil)
    }
    
    func setPlayButton() {
        playButton.contentHorizontalAlignment = .fill
        playButton.contentVerticalAlignment = .fill
    }
    
    func loadLofi(index: Int) {
        // 停止當前歌曲的播放
        lofiPlayer?.stop()
        
        // 加載新的歌曲
        guard let lofiURL = Bundle.main.url(forResource: musicList[index], withExtension: "mp3") else {
            print("找不到音樂文件")
            return
        }
        
        do {
            lofiPlayer = try AVAudioPlayer(contentsOf: lofiURL)
            lofiPlayer?.isMeteringEnabled = true // 開啟音量計量
            lofiPlayer?.play()
        } catch {
            print("無法播放音樂: \(error.localizedDescription)")
        }
    }
    
    func stopPlay() {
        lofiPlayer?.stop()
    }
    
    func nextMusic() {
        lofiIndex += 1
        if lofiIndex >= musicList.count {
            // 如果索引超出了列表的範圍，將索引設置為 0，回到列表的開頭
            lofiIndex = 0
        }
        loadLofi(index: lofiIndex)
    }
    
    func backMusic() {
        lofiIndex -= 1
        if lofiIndex < 0 {
            // 如果索引小於 0，將索引設置為列表的最後一首歌的索引，回到列表的末尾
            lofiIndex = musicList.count - 1
        }
        loadLofi(index: lofiIndex)
    }
    
    func initSetting() {
        secondsElapsed = 1800
        timerLabel.text = formatTime(seconds: secondsElapsed)
        playButton.setImage(UIImage(systemName: "play.circle"), for: .normal)
        lofiIndex = 0
        stopPlay()
    }
    
    @objc func updateVisualizer() {
        guard let player = lofiPlayer else { return }
        player.updateMeters()
        let power = player.averagePower(forChannel: 0)
        audioVisualizerView.update(with: power)
    }
}
