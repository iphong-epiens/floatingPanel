//
//  ContentViewController.swift
//  floatingPannel
//
//  Created by Inpyo Hong on 2021/06/15.
//

import UIKit
import Combine

class ContentViewController: UIViewController {
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
    @IBOutlet weak var tableView: UITableView!
  //  @IBOutlet weak var contentWidthConstraint: NSLayoutConstraint!
    @IBOutlet weak var contentHeightConstraint: NSLayoutConstraint!
    var subscriptions = Set<AnyCancellable>()

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        setDeviceOrientation()
        
    }
    
    
    func setDeviceOrientation() {
        NotificationCenter.default.publisher(for: UIDevice.orientationDidChangeNotification)
          .sink(receiveValue: {[weak self] _ in
            guard let self = self else { return }

            DispatchQueue.main.async {
              switch UIDevice.current.orientation {
              case .portrait:
              //  self.contentWidthConstraint.constant = UIScreen.main.bounds.width
                self.contentHeightConstraint.constant = 100
                
              case .portraitUpsideDown, .landscapeLeft, .landscapeRight:
               // self.contentWidthConstraint.constant = UIScreen.main.bounds.width
                self.contentHeightConstraint.constant = UIScreen.main.bounds.height
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
