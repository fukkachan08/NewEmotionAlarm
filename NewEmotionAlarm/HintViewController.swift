import UIKit

class HintViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        print("HintViewController viewDidLoad")
    }

    @IBAction func dismissHint(_ sender: Any) {
        print("dismissHint called")
        self.dismiss(animated: true, completion: nil)
    }
}

