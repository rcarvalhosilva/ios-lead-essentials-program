//
//  FeedViewController.swift
//  Prototype
//
//  Created by Rodrigo Carvalho on 29/12/21.
//

import UIKit

struct FeedImageViewModel {
    let description: String?
    let location: String?
    let imageName: String
}

final class FeedViewController: UITableViewController {
    private var feed = [FeedImageViewModel]()

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        refresh()
        tableView.setContentOffset(.init(x: 0, y: -tableView.contentInset.top), animated: false)
    }

    @IBAction func refresh() {
        refreshControl?.beginRefreshing()
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
            if self.feed.isEmpty {
                self.feed = FeedImageViewModel.prototypeFeed
                self.tableView.reloadData()
            }
            self.refreshControl?.endRefreshing()
        }
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        feed.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "FeedImageCell", for: indexPath) as! FeedImageCell
        let model = feed[indexPath.row]
        cell.configure(with: model)
        return cell
    }
}

extension FeedImageCell {
    func configure(with viewModel: FeedImageViewModel) {
        locationLabel.text = viewModel.location
        locationContainer.isHidden = viewModel.location == nil

        descriptionLabel.text = viewModel.description
        descriptionLabel.isHidden = viewModel.description == nil

        fadeIn(UIImage(named: viewModel.imageName))

    }
}
