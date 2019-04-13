//
//  SignupViewController.swift
//  defy
//
//  Created by Evgeny Yurtaev on 4/12/19.
//  Copyright © 2019 Zerion. All rights reserved.
//

import UIKit

enum SignupItem {
    
    case simple(String, String), phone, birthday
    
    var title: String {
        switch self {
        case .simple(let label, let _):
            return label
        case .phone:
            return "Phone"
        case .birthday:
            return "Birthday"
        }
    }
    
    var placeholder: String {
        switch self {
        case .simple(let _, let placeholder):
            return placeholder
        case .phone:
            return "+1 123 456 7890"
        case .birthday:
            return "Birthday"
        }
    }
}

class SignupViewController: UIViewController {

    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var subtitleLabel: UILabel!
    @IBOutlet weak var tableView: UITableView!
    
    var title_: String = ""
    var subtitle: String = ""
    var items: [SignupItem] = []
    
    let flowController = SignupFlowController.shared
    
    var nextButton: UIButton?
    
    var step: Int = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.isScrollEnabled = false
        tableView.backgroundColor = .backgroundColor
        tableView.dataSource = self
        tableView.delegate = self
        tableView.register(cellClass: SimpleInputCell.self)
        tableView.tableFooterView = UIView()
        
        // Set up a line above the table view
        let px = 1 / UIScreen.main.scale
        let frame = CGRect(x: 0, y: 0, width: self.tableView.frame.size.width, height: px)
        let lineFrame = CGRect(x: 16, y: 0, width: self.tableView.frame.size.width - 16, height: px)
        let view = UIView(frame: frame)
        let line = UIView(frame: lineFrame)
        view.addSubview(line)
        tableView.tableHeaderView = view
        line.backgroundColor = self.tableView.separatorColor
        
        setupViewController()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.reloadInputViews()
    }
    
    func configure(step: Int) {
        self.step = step
        let (title, subtitle, items) = flowController.getConfig(step: step)
        self.title_ = title
        self.subtitle = subtitle
        self.items = items
    }
    
    func setupViewController() {
        self.titleLabel.text = title_
        self.subtitleLabel.text = subtitle
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.reloadInputViews()
    }
    
    @objc func nextButtonTapped(_ sender: UIButton) {
        proceed()
    }
    
    func proceed() {
        if let navigationController = self.navigationController {
            if flowController.isLastStep(step: self.step) {
                let vc = UIStoryboard.init(name: "Main", bundle: Bundle.main).instantiateViewController(withIdentifier: "ViewController") as! ViewController
                navigationController.pushViewController(vc, animated: true)
            } else {
                let vc = UIStoryboard.init(name: "Main", bundle: Bundle.main).instantiateViewController(withIdentifier: "SignupViewController") as! SignupViewController
                vc.configure(step: self.step + 1)
                navigationController.pushViewController(vc, animated: true)
            }
        }
    }
}

extension SignupViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        proceed()
        return true
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        self.nextButton?.backgroundColor = UIColor.init(red: 36/255, green: 31/255, blue: 30/255, alpha: 1)
        return true
    }
}

extension SignupViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return items.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: SimpleInputCell = tableView.dequeueReusableCell(for: indexPath)
        let item = self.items[indexPath.row]
        
        cell.textField.delegate = self
        let nextButtonView = Bundle.main.loadNibNamed("NextButtonView", owner: self, options: nil)?.first as! UIView?
        cell.textField.inputAccessoryView = nextButtonView
        let button = nextButtonView?.subviews.first as! UIButton
        self.nextButton = button
        button.addTarget(self, action: #selector(nextButtonTapped), for: .touchUpInside)
        
        switch item {
        case .simple(let label, let placeholder):
            cell.textField.keyboardType = .default
            cell.label.text = label
            cell.textField.placeholder = placeholder
        case .phone:
            cell.textField.keyboardType = .phonePad
            cell.label.text = item.title
        case .birthday:
            cell.label.text = item.title
        }
        
        if indexPath.row == 0 {
            cell.textField.becomeFirstResponder()
        }
        return cell
    }
    
    
}
