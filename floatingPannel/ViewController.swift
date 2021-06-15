//
//  ViewController.swift
//  floatingPannel
//
//  Created by Inpyo Hong on 2021/06/15.
//

import UIKit
import FloatingPanel
import Combine

class ViewController: UIViewController, FloatingPanelControllerDelegate {
    @IBOutlet weak var tableView: UITableView!
    var fpc: FloatingPanelController!
    var subscriptions = Set<AnyCancellable>()
    private var floatingPanelEndDraggingSubject = PassthroughSubject<Bool,Never>()
    var floatingPanelEndDragging: AnyPublisher<Bool, Never> {
        return floatingPanelEndDraggingSubject.eraseToAnyPublisher()
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        setDeviceOrientation()
    }
    
    func setDeviceOrientation() {
        NotificationCenter.default.publisher(for: UIDevice.orientationDidChangeNotification)
          .sink(receiveValue: {[weak self] _ in
            guard let self = self else { return }
            guard self.fpc != nil else { return }
            self.fpc.move(to: .full, animated: true)

            DispatchQueue.main.async {
              switch UIDevice.current.orientation {
              case .portrait:
                self.fpc.panGestureRecognizer.isEnabled = true
              
              case .portraitUpsideDown, .landscapeLeft, .landscapeRight:
                self.fpc.panGestureRecognizer.isEnabled = false

              default:
                break
              }
            }
          })
          .store(in: &subscriptions)
    }
    
    func setupFpc() {
        fpc = FloatingPanelController()

        // Assign self as the delegate of the controller.
        fpc.delegate = self // Optional
        
        let contentVC =
            storyboard?.instantiateViewController(withIdentifier: "ContentViewController") as! ContentViewController
        
        floatingPanelEndDragging.assign(to: \.topConstraintVisible, on: contentVC).store(in: &subscriptions)
        // Create a new appearance.
        let appearance = SurfaceAppearance()

        appearance.shadows = []

        // Define corner radius and background color
        appearance.cornerRadius = 0.0
        appearance.backgroundColor = .clear

        // Set the new appearance
        fpc.surfaceView.appearance = appearance
        fpc.surfaceView.grabberHandle.isHidden = true
        fpc.layout = fpcLayout()
        fpc.set(contentViewController: contentVC)

        // Track a scroll view(or the siblings) in the content view controller.
        fpc.track(scrollView: contentVC.tableView)

        // Add and show the views managed by the `FloatingPanelController` object to self.view.
        fpc.addPanel(toParent: self)
        
//        fpc.isRemovalInteractionEnabled = true // Optional: Let it removable by a swipe-down
//        self.present(fpc, animated: true, completion: nil)
    }
    
    func floatingPanelDidMove(_ vc: FloatingPanelController) {
        print(#function)
        if vc.isAttracting == false {
            let loc = vc.surfaceLocation
            let minY = vc.surfaceLocation(for: .full).y - 6.0
            let maxY = vc.surfaceLocation(for: .tip).y + 6.0
            vc.surfaceLocation = CGPoint(x: loc.x, y: min(max(loc.y, minY), maxY))
        }
    }
    
    // Enable `surfaceTapGesture` only at `tip` state
    func floatingPanelDidChangeState(_ vc: FloatingPanelController) {
        print(#function)
    }
    
    
    func floatingPanelWillBeginDragging(_ vc: FloatingPanelController) {
        print(#function)

//          if vc.position == .full {
//              searchVC.searchBar.showsCancelButton = false
//              searchVC.searchBar.resignFirstResponder()
//          }
      }

      func floatingPanelWillEndDragging(_ vc: FloatingPanelController, withVelocity velocity: CGPoint, targetState: UnsafeMutablePointer<FloatingPanelState>) {
        print(#function)

          if targetState.pointee != .full {
             // searchVC.hideHeader()
            floatingPanelEndDraggingSubject.send(true)
          }
          else{
            floatingPanelEndDraggingSubject.send(false)
          }
        
        
      }
    
    override var preferredStatusBarStyle: UIStatusBarStyle{
        .lightContent
    }
}

class fpcLayout: FloatingPanelLayout {
    let position: FloatingPanelPosition = .bottom
    let initialState: FloatingPanelState = .full
    var anchors: [FloatingPanelState: FloatingPanelLayoutAnchoring] {
        return [
            .full: FloatingPanelLayoutAnchor(absoluteInset: 0.0, edge: .top, referenceGuide: .superview),
            .tip: FloatingPanelLayoutAnchor(absoluteInset: 100.0, edge: .bottom, referenceGuide: .safeArea),
        ]
    }
}

extension ViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        cell.backgroundColor = .red

        cell.textLabel?.text = "\(indexPath.row)"
        return cell
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 10
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        setupFpc()
    }
}
