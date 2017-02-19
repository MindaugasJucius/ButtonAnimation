import UIKit

fileprivate let ReuseId = "FillableCell"
typealias FillColors = (initialColor: UIColor, fillColor: UIColor)

class ViewController: UIViewController {

    @IBOutlet weak var tableView: UITableView!
    fileprivate var fillColors: [FillColors] = []
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    override var preferredStatusBarUpdateAnimation: UIStatusBarAnimation {
        return .fade
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.title = "Fill modes"
        navigationController?.navigationBar.barTintColor = .black
        navigationController?.navigationBar.tintColor = .white
        fillColors = [(UIColor.from(hex: "89C4F4"), UIColor.from(hex: "2c3e50")),
                      (UIColor.from(hex: "1abc9c"), UIColor.from(hex: "34495e")),
                      (UIColor.from(hex: "446CB3"), UIColor.from(hex: "52B3D9")),
                      (UIColor.from(hex: "336E7B"), UIColor.from(hex: "22313F")),
        ]
        
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: ReuseId)
        tableView.delegate = self
        tableView.dataSource = self
        tableView.allowsSelection = false
        tableView.showsVerticalScrollIndicator = false
        tableView.separatorStyle = .none
        tableView.tableHeaderView = UIView()
        UIView.animate(
            withDuration: 0.2,
            animations: { [unowned self] in
                self.setNeedsStatusBarAppearanceUpdate()
            }
        )
    }
    
    fileprivate func addFullFrameConstraints(inView view: UIView, forSubview subview: UIView) {
        subview.translatesAutoresizingMaskIntoConstraints = false
        subview.leftAnchor.constraint(equalTo: view.leftAnchor).isActive = true
        subview.rightAnchor.constraint(equalTo: view.rightAnchor).isActive = true
        subview.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
        subview.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
        
    }
    
}

extension ViewController: UITableViewDataSource {

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 4
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: ReuseId, for: indexPath)
        let switchFill = indexPath.row % 2 == 0
        let view: FillableView?
        if switchFill {
            view = FillableView.switchFillable()
        } else {
            view = FillableView.buttonFillable()
        }
        guard let fillView = view else { return cell }
        let colors = fillColors[indexPath.row]
        fillView.initialColor = colors.initialColor
        fillView.filledColor = colors.fillColor
        cell.contentView.addSubview(fillView)
        cell.clipsToBounds = true
        addFullFrameConstraints(inView: cell.contentView, forSubview: fillView)
        return cell
    }

}

extension ViewController: UITableViewDelegate {

    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return CGFloat.leastNormalMagnitude
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return view.frame.height / 3
    }
}

extension UINavigationController {
    override open var preferredStatusBarStyle: UIStatusBarStyle {
        return self.topViewController?.preferredStatusBarStyle ?? .default
    }
}
