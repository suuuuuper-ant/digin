//
//  SearchViewController.swift
//  Digin
//
//  Created by jinho jeong on 2021/04/11.
//

import UIKit
import CoreData

class SearchViewController: UIViewController {

    @IBOutlet weak var tableView: UITableView!

    @IBOutlet weak var lineView: UIView!
    @IBOutlet weak var lineViewLeadingC: NSLayoutConstraint!
    @IBOutlet weak var searchTextField: UITextField!
    @IBOutlet weak var textFieldLeadingC: NSLayoutConstraint!
    @IBOutlet weak var searchButton: UIButton!

    var isSearch = 0 //화면 전환 상태 (0: 메인, 1: 검색리스트, 2: 검색 결과)

    //networking data
    var searchData = SearchResult()

    //local data (core data)
    let request = NSFetchRequest<NSManagedObject>(entityName: "RecentCompany")
    var recentCompany: [NSManagedObject] = []

    override func viewDidLoad() {
        super.viewDidLoad()

        // MARK: CoreData - Fetch
        recentCompany =  PersistenceManager.shared.fetch(request: request)
        setup()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        self.navigationController?.navigationBar.barTintColor = .white
    }

    private func setup() {
        setNavigationBar()
        setBackButton()

        searchButton.isHidden = true
        searchTextField.delegate = self

        tableView.delegate = self
        tableView.dataSource = self
        tableView.tableFooterView = UIView(frame: .zero)
        tableView.estimatedSectionHeaderHeight = UITableView.automaticDimension

        let nibName = UINib(nibName: NoneResultTableViewCell.reuseIdentifier, bundle: nil)
        tableView.register(nibName, forCellReuseIdentifier: NoneResultTableViewCell.reuseIdentifier)
    }

    func setBackButton() {
        let backBTN = UIBarButtonItem(image: UIImage(named: "icon_navigation_back"),
                                      style: .plain,
                                      target: self,
                                      action: #selector(backAction))
        navigationItem.leftBarButtonItem = backBTN
        backBTN.tintColor = AppColor.darkgray62.color
        backBTN.imageInsets = UIEdgeInsets(top: 0, left: -5, bottom: 0, right: 0)
        navigationController?.interactivePopGestureRecognizer?.delegate = self as? UIGestureRecognizerDelegate
    }

    @objc func backAction() {
        if isSearch == 1 || isSearch == 2 { //메인으로 이동
            isSearch = 0
            self.tableView.reloadData()
            disableSearchAnimaion()
            searchTextField.resignFirstResponder()
            searchTextField.text = ""
        }
    }

    //검색 활성화
    @IBAction func startSearch(_ sender: UITextField) {
        // MARK: CoreData - Fetch
        recentCompany =  PersistenceManager.shared.fetch(request: request)

        isSearch = 1
        tableView.reloadData()
        enableSearchAnimation()
    }

    //검색
    @IBAction func searchAction(_ sender: UIButton) {
        if isTextEmpty() { return } //공백 체크

        guard let text = searchTextField.text else { return }
        if isSearch == 1 {
            // MARK: CoreData - Insert
            PersistenceManager.shared.insertCompany(name: text)

            //화면 전환 (검색 리스트, 1 -> 검색 결과, 2)
            isSearch = 2
            searchTextField.resignFirstResponder()
            getSearchData(keyword: text)
            disableSearchAnimaion()
        }

        getSearchData(keyword: text)
    }

    //검색 활성화
    private func enableSearchAnimation() {

        UIView.animate(withDuration: 2.0, delay: 1.0, options: .curveEaseIn, animations: {
            self.lineViewLeadingC.constant = -10
        }) { (_) in

            UIView.animate(withDuration: 2.0, delay: 1.0, animations: {
                self.textFieldLeadingC.constant = 20
                self.searchButton.isHidden = false
            })
        }
    }

    //검색 비활성화
    private func disableSearchAnimaion() {

        UIView.animate(withDuration: 2.0, delay: 1.0, options: .curveEaseIn, animations: {
            self.lineViewLeadingC.constant = 20
        }) { (_) in

            UIView.animate(withDuration: 2.0, delay: 2.0, animations: {
                self.textFieldLeadingC.constant = 30
            })
        }
    }

    private func isTextEmpty() -> Bool {
        if searchTextField.text == "" {
            self.alert(title: "", message: "검색어를 입력해주세요")
            return true
        }

        return false
    }

}

// MARK: - TextField
extension SearchViewController: UITextFieldDelegate {

    //FIXME : 동작 수정
    func textFieldShouldReturn(_ sender: UITextField) -> Bool {
        sender.resignFirstResponder()
        return true
    }
}

// MARK: - TableView
extension SearchViewController: UITableViewDelegate, UITableViewDataSource {

    func numberOfSections(in tableView: UITableView) -> Int {
        if isSearch == 1 { return 1 } //검색창
        if isSearch == 2 { //검색 결과
            if searchData.companies.isEmpty && searchData.news.isEmpty { return 1 }
            return 3
        }

        return 2 //메인
    }

    // - HEADER
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {

        switch isSearch {

        case 1: //검색창
            guard let cell = tableView.dequeueReusableCell(withIdentifier: SearchHeaderTableViewCell.reuseIdentifier) as? SearchHeaderTableViewCell else {
                return UITableViewCell()
            }

            cell.deleteClosure = { [weak self] in

                if let req = self?.request {
                    let cnt = PersistenceManager.shared.count(request: req) ?? 0

                    if cnt > 0 {
                        // MARK: CoreData - Delete All
                        PersistenceManager.shared.deleteAll(request: req)
                        // MARK: CoreData - Fetch
                        self?.recentCompany =  PersistenceManager.shared.fetch(request: req)
                    }
                }

                self?.tableView.reloadData()
            }

            return cell

        case 2: //검색 결과
            if searchData.companies.isEmpty && searchData.news.isEmpty { return UITableViewCell() }

            guard let cell = tableView.dequeueReusableCell(withIdentifier: CategoryHeaderTableViewCell.reuseIdentifier) as? CategoryHeaderTableViewCell else {
                return UITableViewCell()
            }

            if section == 0 {
                cell.titleLabel.text = "기업"
                cell.nextButton.isHidden = true
                cell.timeLabel.isHidden = true

            } else if section == 1 {
                if searchData.news.isEmpty {
                    cell.nextButton.isHidden = true
                } else {
                    cell.nextButton.isHidden = false
                }

                cell.titleLabel.text = "뉴스"
                cell.timeLabel.isHidden = true

                cell.nextClosure = { [weak self] in //뉴스 더보기
                    let newsVC = UIStoryboard(name: "Search", bundle: nil).instantiateViewController(identifier: SearchNewsfeedViewController.reuseIdentifier) as SearchNewsfeedViewController

                    guard let searchText = self?.searchTextField.text else { return }
                    newsVC.type = 0
                    newsVC.header = searchText

                    if let data = self?.searchData.news {
                        newsVC.newsData = data
                    }

                    self?.navigationController?.pushViewController(newsVC, animated: true)
                }

            } else {
                cell.titleLabel.text = "카테고리"
                cell.nextButton.isHidden = true
                cell.timeLabel.isHidden = true
            }

            return cell

        default: //메인
            guard let cell = tableView.dequeueReusableCell(withIdentifier: CategoryHeaderTableViewCell.reuseIdentifier) as? CategoryHeaderTableViewCell else {
                return UITableViewCell()
            }

            if section == 0 {
                cell.titleLabel.text = "카테고리"
                cell.timeLabel.isHidden = true
                cell.nextButton.isHidden = true

            } else {
                cell.titleLabel.text = "인기 검색 기업"
                cell.timeLabel.isHidden = false

                let today = NSDate()
                let dateFormatter = DateFormatter()
                dateFormatter.dateFormat = "HH:mm"
                let dateString = dateFormatter.string(from: today as Date)
                cell.timeLabel.text = dateString

                cell.nextButton.isHidden = true
            }

            return cell
        }
    }

    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return UITableView.automaticDimension
    }

    //- ROW
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {

        switch isSearch {
        case 1: return recentCompany.count //검색 리스트

        case 2: //검색 결과
            if searchData.companies.isEmpty && searchData.news.isEmpty { return 1 } //검색 결과 없음

            if section == 0 {
                if searchData.companies.isEmpty { return 1 }
                return searchData.companies.count
            } //기업
            if section == 1 { //뉴스
                if searchData.news.isEmpty { return 1 }
                if searchData.news.count >= 3 { return 3 }
                return searchData.news.count
            }
            return 1 //카테고리

        default: //메인
            if section == 0 { return 1 }
            return 5
        }
    }

    // swiftlint:disable all
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        switch isSearch {

        case 1: //검색 리스트
            guard let cell = tableView.dequeueReusableCell(withIdentifier: SearchTableViewCell.reuseIdentifier) as? SearchTableViewCell else { return UITableViewCell() }

            let company: NSManagedObject = recentCompany[indexPath.row]
            cell.titleLabel.text = company.value(forKey: "name") as? String
            cell.layer.borderColor = AppColor.darkgray62.color.cgColor

            cell.deleteClosure = { [weak self] in

                if let req = self?.request {
                    let cnt = PersistenceManager.shared.count(request: req) ?? 0

                    guard let value = self?.recentCompany[indexPath.row] else { return }
                    if cnt > 0 {
                        // MARK: CoreData - Delete
                        PersistenceManager.shared.delete(object: value)
                        // MARK: CoreData - Fetch
                        self?.recentCompany =  PersistenceManager.shared.fetch(request: req)
                    }
                }
                self?.tableView.reloadData()
            }

            return cell

        case 2: //검색 결과

            if indexPath.section == 0 { //기업

                if searchData.companies.isEmpty { //검색 결과 없음
                    guard let cell = tableView.dequeueReusableCell(withIdentifier: NoneResultTableViewCell.reuseIdentifier) as? NoneResultTableViewCell else { return UITableViewCell() }
                    cell.contentLabel.text =
                    """
                    일치하는 기업이 없습니다.
                    찾으시는 정보를 정확히 입력해 주세요!
                    """
                    return cell
                }

                guard let cell = tableView.dequeueReusableCell(withIdentifier: CompanyTableViewCell.reuseIdentifier) as? CompanyTableViewCell else { return UITableViewCell() }

                cell.titleLabel.text = searchData.companies[indexPath.row].name
                cell.categoryLabel.text = "커뮤니케이션 서비스"

                return cell
            }

            if indexPath.section == 1 { //뉴스
                if searchData.news.isEmpty { //검색 결과 없음
                    guard let cell = tableView.dequeueReusableCell(withIdentifier: NoneResultTableViewCell.reuseIdentifier) as? NoneResultTableViewCell else { return UITableViewCell() }
                    cell.contentLabel.text =
                    """
                    일치하는 뉴스가 없습니다.
                    찾으시는 정보를 정확히 입력해 주세요!
                    """
                    return cell
                }

                guard let cell = tableView.dequeueReusableCell(withIdentifier: CompanyNewsTableViewCell.reuseIdentifier) as? CompanyNewsTableViewCell else { return UITableViewCell() }

                cell.titleLabel.text = searchData.news[indexPath.row].title
                cell.dateLabel.text = searchData.news[indexPath.row].createdAt.setDate(format: "MM.dd. HH:mm")

                return cell
            }

            if indexPath.section == 2 { //카테고리
                guard let cell = tableView.dequeueReusableCell(withIdentifier: CategoryTableViewCell.reuseIdentifier) as? CategoryTableViewCell else { return UITableViewCell() }

                cell.collectionView.reloadData()
                cell.actionClosure = { [weak self] (result) in
                    //print(result)
                    guard let detailsVC = UIStoryboard(name: "Search", bundle: nil).instantiateViewController(withIdentifier: CategoryDetailsViewController.reuseIdentifier) as? CategoryDetailsViewController else {return}
                    detailsVC.categoryReult = result
                    self?.navigationController?.pushViewController(detailsVC, animated: true)
                }

                return cell
            }

        default: //메인
            if indexPath.section == 0 { //카테고리
                guard let cell = tableView.dequeueReusableCell(withIdentifier: CategoryTableViewCell.reuseIdentifier) as? CategoryTableViewCell else { return UITableViewCell() }

                cell.collectionView.reloadData()
                cell.actionClosure = { [weak self] (result) in
                    //print(result)
                    guard let detailsVC = UIStoryboard(name: "Search", bundle: nil).instantiateViewController(withIdentifier: CategoryDetailsViewController.reuseIdentifier) as? CategoryDetailsViewController else {return}
                    detailsVC.categoryReult = result
                    self?.navigationController?.pushViewController(detailsVC, animated: true)
                }

                return cell
            }

            //인기 검색 기업
            guard let cell = tableView.dequeueReusableCell(withIdentifier: CompanyTableViewCell.reuseIdentifier) as? CompanyTableViewCell else { return UITableViewCell() }

            cell.titleLabel.text = "카카오"
            cell.categoryLabel.text = "커뮤니케이션 서비스"

            return cell
        }

        return UITableViewCell()
    }
    // swiftlint:enable all

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let detailsVC = HomeDetailViewController()

        switch isSearch {
        case 1: //검색 리스트
            guard let name = recentCompany[indexPath.row].value(forKey: "name") as? String else { return }
            isSearch = 2
            searchTextField.resignFirstResponder()
            searchTextField.text = name
            getSearchData(keyword: name)

        case 2: //검색 결과
            if indexPath.section == 0 && !searchData.companies.isEmpty { //기업
                //TODO: 기업 상세보기에 기업 정보 전달하기
                detailsVC.title = searchData.companies[indexPath.row].name
                self.navigationController?.pushViewController(detailsVC, animated: true)
            }

            if indexPath.section == 1 && !searchData.news.isEmpty { //뉴스
                let newsVC = UIStoryboard(name: "NewsFeed", bundle: nil).instantiateViewController(identifier: NewsDetailsViewController.reuseIdentifier) as NewsDetailsViewController
                newsVC.newsURL = searchData.news[indexPath.row].link
                self.present(newsVC, animated: true, completion: nil)
            }

        default: //메인
            if indexPath.section == 1 {
                //TODO: 기업 상세보기에 기업 정보 전달하기 (API 아직 없음)
                self.navigationController?.pushViewController(detailsVC, animated: true)
            }
        }

    }

}

// MARK: - Networking
extension SearchViewController {

    // GET - /news
    func getSearchData(keyword: String) {

        SearchService.getSearchData(searchText: keyword) { (result) in
            self.searchData = result
            print(self.searchData)

            DispatchQueue.main.async(execute: {
                self.tableView.reloadData()
            })
        }
    }
}
