//
//  MypageViewController.swift
//  Digin
//
//  Created by jinho jeong on 2021/04/11.
//

import UIKit

class MypageViewController: UIViewController {

    @IBOutlet weak var logoImageView: UIImageView!
    @IBOutlet weak var nicknameLabel: UILabel!

    @IBOutlet weak var backView: UIView!
    @IBOutlet weak var favoriteCompanyLabel: UILabel!
    @IBOutlet weak var gameCountLabel: UILabel!

    @IBOutlet weak var tableView: UITableView!

    let tableViewList = ["공지사항", "약관 및 정책"]

    //networking data
    var companyList = [CompanyResult]()

    override func viewDidLoad() {
        super.viewDidLoad()
        setup()

            self.getCompanyList()

    }

    private func setup() {
        setNavigationBar()
        logoImageView.makeCircle()
        backView.makeRounded(cornerRadius: 20)

        tableView.delegate = self
        tableView.dataSource = self
        tableView.tableFooterView = UIView(frame: .zero)

        let nibName = UINib(nibName: MyPageMainTableViewCell.reuseIdentifier, bundle: nil)
        tableView.register(nibName, forCellReuseIdentifier: MyPageMainTableViewCell.reuseIdentifier)
    }

    @IBAction func editAction(_ sender: UIButton) {

    }

    @IBAction func favoriteCompanyAction(_ sender: UITapGestureRecognizer) {
    }

}

// MARK: - TableView
extension MypageViewController: UITableViewDelegate, UITableViewDataSource {

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tableViewList.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: MyPageMainTableViewCell.reuseIdentifier) as? MyPageMainTableViewCell else {
            return UITableViewCell()
        }

        cell.titleLabel.text = tableViewList[indexPath.row]
        cell.accessoryType = .disclosureIndicator

        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let vc = UIStoryboard(name: "MyPage", bundle: nil).instantiateViewController(identifier: NoticeViewController.reuseIdentifier) as NoticeViewController
        vc.type = indexPath.row
        self.navigationController?.pushViewController(vc, animated: true)
    }

}

// MARK: - Networking
extension MypageViewController {

    // GET - /accounts/favorites (관심 기업)
    func getCompanyList() {
        NewsfeedService.getFavorites { (result) in
            self.companyList = result

            DispatchQueue.main.async {
                self.favoriteCompanyLabel.text = self.companyList.count.description
                print(self.companyList)
            }
        }
    }
}
