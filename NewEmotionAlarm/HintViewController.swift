import UIKit

class HintViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        print("HintViewController viewDidLoad") // デバッグプリントを追加
    }

    @IBAction func dismissHint(_ sender: Any) {
        print("dismissHint called") // デバッグプリントを追加
        self.dismiss(animated: true, completion: nil)
    }
}

