//
//  Food.swift
//  SampleApp
//
//  Created by Joseph Szymanski on 8/5/24.
//

import Combine
import Foundation

struct Food: Codable, Identifiable {
    var id: Int
    var brand: String
    var name: String
    var calories: Int
    var portion: Int
}

class FoodModel {
    @Published var foodArray: [Food]?
    @Published var searchString: String = ""
    @Published var loading = false
    private var subscribers = Set<AnyCancellable>()

    init(foodArray: [Food]? = nil, searchString: String = "") {
        self.foodArray = foodArray
        self.searchString = searchString

        $searchString
            .debounce(for: .milliseconds(300), scheduler: RunLoop.main)
            .sink { [weak self] output in
                Task { [weak self] in
                    guard let self else { return }
                    await self.search(for: output)
                }
            }
            .store(in: &subscribers)
    }

    private func search(for searchString: String) async {
        foodArray = nil
        guard searchString.count >= 3 else { return }
        let URLString = "https://uih0b7slze.execute-api.us-east-1.amazonaws.com/dev/search?kv=\(searchString)"
        guard let URL = URL(string: URLString) else { return }
        loading = true
        defer { loading = false }
        let response = try? await URLSession.shared.data(from: URL)
        guard let response else { return }
        if let foodAsArray = try? JSONDecoder().decode([Food].self, from: response.0) {
            foodArray = foodAsArray
        }
    }
}
