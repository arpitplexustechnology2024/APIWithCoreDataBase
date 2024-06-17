//
//  ViewController.swift
//  APIWithCoreDataBase
//
//  Created by Arpit iOS Dev. on 15/06/24.
//

import UIKit
import TTGSnackbar

class ViewController: UIViewController {
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    var viewModel = CommentsViewModel()
    var noInternetView: NoInternetView!
    var noDataView: NoDataView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        tableView.delegate = self
        tableView.dataSource = self
        activityIndicator.style = .large
        fetchComment()
        setupNoDataView()
        checkInternetConnection()
    }
    
    func setupNoDataView() {
        noDataView = NoDataView()
        noDataView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(noDataView)
        
        NSLayoutConstraint.activate([
            noDataView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            noDataView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            noDataView.topAnchor.constraint(equalTo: view.topAnchor),
            noDataView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
        
        noDataView.isHidden = true
    }
    
    func fetchComment() {
        viewModel.onStateChange = { [weak self] state in
            guard let self = self else { return }
            switch state {
            case .loading(let isLoading):
                DispatchQueue.main.async {
                    if isLoading {
                        self.activityIndicator.startAnimating()
                        self.tableView.isHidden = true
                    } else {
                        self.activityIndicator.stopAnimating()
                    }
                }
            case .success:
                DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                    self.activityIndicator.stopAnimating()
                    self.tableView.isHidden = false
                    self.tableView.reloadData()
                }
            case .failure(let error):
                DispatchQueue.main.async {
                    self.activityIndicator.stopAnimating()
                    print("Error fetching comments: \(error)")
                    self.showNoDataView()
                }
            }
        }
        viewModel.onNoInternetConnection = { [weak self] in
            DispatchQueue.main.async {
                if AppRunTracker.shared.hasRunBefore {
                    self?.viewModel.fetchCommentsFromCoreData()
                    self?.showCachedDataSnackbar()
                } else {
                    self?.showNoInternetLayout()
                }
            }
        }
    }
    
    func checkInternetConnection() {
        if Reachability.shared.isConnectedToNetwork() {
            viewModel.fetchData()
        } else {
            if AppRunTracker.shared.hasRunBefore {
                viewModel.fetchCommentsFromCoreData()
                showCachedDataSnackbar()
                print("No Internet Connection. Showing cached data.")
            } else {
                showNoInternetLayout()
            }
        }
    }
    
    func showNoInternetLayout() {
        if noInternetView == nil {
            noInternetView = NoInternetView(frame: view.bounds)
            noInternetView?.retryButton.addTarget(self, action: #selector(retryConnection), for: .touchUpInside)
            view.addSubview(noInternetView!)
        }
        noInternetView?.isHidden = false
        tableView.isHidden = true
    }
    
    @objc private func retryConnection() {
        if Reachability.shared.isConnectedToNetwork() {
            noInternetView?.isHidden = true
            tableView.isHidden = false
            viewModel.fetchData()
        } else {
            showNoInternetSnackbar()
        }
    }
    
    deinit {
        Reachability.shared.stopMonitoring()
    }
    
    func showNoDataView() {
        noDataView.isHidden = false
        tableView.isHidden = true
    }
    
    func showNoInternetSnackbar() {
        let snackbar = TTGSnackbar(message: "No Internet Connection. Please try again.", duration: .middle)
        snackbar.show()
    }
    
    func showCachedDataSnackbar() {
        let snackbar = TTGSnackbar(message: "No Internet Connection. Showing cached data.", duration: .middle)
        snackbar.show()
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
