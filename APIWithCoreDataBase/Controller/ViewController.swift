//
//  ViewController.swift
//  APIWithCoreDataBase
//
//  Created by Arpit iOS Dev. on 15/06/24.
//

import UIKit

class ViewController: UIViewController {
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    var viewModel = CommentsViewModel()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        tableView.delegate = self
        tableView.dataSource = self
        tableView.isHidden = true
        activityIndicator.style = .large
        fetchComment()
    }
    
    func fetchComment() {
        viewModel.onStateChange = { [weak self] state in
            guard let self = self else { return }
            switch state {
            case .loading(let isLoading):
                DispatchQueue.main.async {
                    if isLoading {
                        self.activityIndicator.startAnimating()
                    } else {
                        self.activityIndicator.stopAnimating()
                    }
                }
            case .success:
                DispatchQueue.main.async {
                    self.activityIndicator.stopAnimating()
                    self.tableView.isHidden = false
                    self.tableView.reloadData()
                }
            case .failure(let error):
                DispatchQueue.main.async {
                    self.activityIndicator.stopAnimating()
                    print("Error fetching comments: \(error)")
                }
            }
        }
        viewModel.fetchData()
    }
}

// MARK: - TableView Dalegate & Datasource
extension ViewController: UITableViewDelegate, UITableViewDataSource{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.comments.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "TableViewCell") as! TableViewCell
        cell.postIdLbl.text = "\(viewModel.comments[indexPath.row].postId)"
        cell.idLbl.text = "\(viewModel.comments[indexPath.row].id)"
        cell.nameLbl.text = viewModel.comments[indexPath.row].name
        cell.emailLbl.text = viewModel.comments[indexPath.row].email
        cell.bodyLbl.text = viewModel.comments[indexPath.row].body
        return cell
    }
}
