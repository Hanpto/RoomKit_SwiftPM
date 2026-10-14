import UIKit
import AtomicXCore

public final class JoinMeetingViewController: UIViewController, RouterContext {

    private lazy var rootView: JoinMeetingView = {
        let view = JoinMeetingView(mode: mode)
        view.routerContext = self
        view.onEnterRoom = { [weak self] roomID in
            self?.push(RoomConferenceViewController(roomID: roomID), animated: true)
        }
        return view
    }()

    private let mode: JoinMeetingView.Mode

    public convenience init() {
        self.init(mode: .default)
    }

    public init(mode: JoinMeetingView.Mode) {
        self.mode = mode
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    public override func loadView() {
        view = rootView
    }

    public override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: animated)
    }

    public override var supportedInterfaceOrientations: UIInterfaceOrientationMask { .portrait }
    public override var shouldAutorotate: Bool { false }
}
