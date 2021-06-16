//
//  ContentViewController.swift
//  floatingPannel
//
//  Created by Inpyo Hong on 2021/06/15.
//

import UIKit
import Combine
import AVKit
import VersaPlayer

class ContentViewController: UIViewController {
    @IBOutlet weak var playerView: VersaPlayerView!
    @IBOutlet weak var controls: VersaPlayerControls!
    
    @IBOutlet weak var tableView: UITableView!
  //  @IBOutlet weak var contentWidthConstraint: NSLayoutConstraint!
    @IBOutlet weak var contentHeightConstraint: NSLayoutConstraint!
    var subscriptions = Set<AnyCancellable>()

    @IBOutlet weak var headerTopConstraint: NSLayoutConstraint!
    
    var topConstraintVisible: Bool = false {
        didSet{
            print("topConstraintVisible", topConstraintVisible)
            if topConstraintVisible == true {
                self.headerTopConstraint.constant = 0
                self.contentHeightConstraint.constant = 100
            }
            else{
                self.headerTopConstraint.constant = 44
                self.contentHeightConstraint.constant = 250
            }
        }
    }
    

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        setDeviceOrientation()
        
        let audioSession = AVAudioSession.sharedInstance()
        do {
            //try audioSession.setCategory(.playback)
            try audioSession.setCategory(.playback, mode: .moviePlayback, options: [])
        } catch {
            print("Failed to set audio session category.")
        }
        
        playerView.layer.backgroundColor = UIColor.black.cgColor
        playerView.use(controls: controls)
        playerView.controls?.behaviour.showingControls = true
        
        if let url = URL.init(string: "https://bitdash-a.akamaihd.net/content/sintel/hls/playlist.m3u8") {
            let item = VersaPlayerItem(url: url)
            playerView.set(item: item)
        }
    }
    
    
    func setDeviceOrientation() {
        NotificationCenter.default.publisher(for: UIDevice.orientationDidChangeNotification)
          .sink(receiveValue: {[weak self] _ in
            guard let self = self else { return }

            DispatchQueue.main.async {
              switch UIDevice.current.orientation {
              case .portrait:
              //  self.contentWidthConstraint.constant = UIScreen.main.bounds.width
                self.contentHeightConstraint.constant = 250
                self.playerView.setFullscreen(enabled: false)

              case .portraitUpsideDown, .landscapeLeft, .landscapeRight:
               // self.contentWidthConstraint.constant = UIScreen.main.bounds.width
                self.playerView.setFullscreen(enabled: true)
              default:
                break
              }
            }
          })
          .store(in: &subscriptions)
    }
    
}

extension ContentViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        cell.textLabel?.text = "\(indexPath.row)"
        return cell
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 10
    }
}
