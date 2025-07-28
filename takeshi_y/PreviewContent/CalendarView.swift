//  CalendarView.swift
//  takeshi_y

import SwiftUI

struct CalendarView: View {
    @State private var selectedDate = Date()
    @State private var isFetchingData = false
    @State private var errorMessage: String? = nil
    @State private var noDataForSelectedDate = false

    // 日付ごとのデータを保持する辞書
    @State private var healthDataByDate: [String: CalendarData] = [:]

    var body: some View {
        VStack {
            Text("calendar")
                .font(.largeTitle)
                .padding()

            DatePicker("日付を選択", selection: $selectedDate, displayedComponents: .date)
                .datePickerStyle(GraphicalDatePickerStyle())
                .padding()


            if let errorMessage = errorMessage {
                Text(errorMessage)
                    .foregroundColor(.red)
                    .padding()
            }

            if isFetchingData {
                ProgressView("データを取得中...")
                    .progressViewStyle(CircularProgressViewStyle(tint: .blue))
                    .padding()
            }

            if noDataForSelectedDate {
                Text("データがありません")
                    .foregroundColor(.gray)
                    .padding()
            } else {
                VStack {
                    Text("エストロゲン: \(healthDataByDate[formattedDate(date: selectedDate)]?.estrogen ?? 0.0, specifier: "%.1f")")
                    Text("コルチゾール: \(healthDataByDate[formattedDate(date: selectedDate)]?.cortisol ?? 0.0, specifier: "%.1f")")
                    Text("免疫力: \(healthDataByDate[formattedDate(date: selectedDate)]?.immunity ?? 0.0, specifier: "%.1f")")
                }
                .font(.title2)
                .padding()
            }

            // 保存ボタン
            Button(action: { saveData(for: selectedDate) }) {
                Text("データを保存")
                    .font(.headline)
                    .padding()
                    .background(Color.green)
                    .foregroundColor(.white)
                    .cornerRadius(10)
            }
            .padding()
        }
        .onAppear {
            fetchData(for: selectedDate)
        }
    }

    private func fetchData(for date: Date) {
        let formattedDateString = formattedDate(date: date)
        guard !isFetchingData else { return }
        isFetchingData = true
        errorMessage = nil
        noDataForSelectedDate = false

        let urlString = "https://takeshi-y.onrender.com/calendar?date=\(formattedDateString)"
        guard let url = URL(string: urlString) else {
            errorMessage = "❌ 無効なURLです"
            isFetchingData = false
            return
        }

        URLSession.shared.dataTask(with: url) { data, response, error in
            DispatchQueue.main.async {
                isFetchingData = false

                if let error = error {
                    errorMessage = "❌ ネットワークエラー: \(error.localizedDescription)"
                    noDataForSelectedDate = true
                    return
                }

                guard let httpResponse = response as? HTTPURLResponse, (200...299).contains(httpResponse.statusCode) else {
                    errorMessage = "❌ サーバーエラー"
                    noDataForSelectedDate = true
                    return
                }

                guard let data = data else {
                    errorMessage = "❌ データなし"
                    noDataForSelectedDate = true
                    return
                }

                do {
                    let decodedData = try JSONDecoder().decode(CalendarData.self, from: data)
                    // データを保存
                    healthDataByDate[formattedDateString] = decodedData
                } catch {
                    errorMessage = "❌ JSON解析エラー: \(error.localizedDescription)"
                    noDataForSelectedDate = true
                }
            }
        }.resume()
    }

    private func formattedDate(date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        formatter.timeZone = TimeZone(identifier: "Asia/Tokyo") // JST を指定
        return formatter.string(from: date)  // ✅ ここでStringを返している
    }


    // データを保存する関数
    private func saveData(for date: Date) {
        let formattedDateString = formattedDate(date: date)
        if let data = healthDataByDate[formattedDateString] {
            print("保存しました: \(formattedDateString) - エストロゲン: \(data.estrogen), コルチゾール: \(data.cortisol), 免疫力: \(data.immunity)")
            // 必要に応じてローカルに保存する処理を追加（例: UserDefaultsやCoreDataなど）
        } else {
            errorMessage = "❌ 保存するデータがありません"
        }
    }
}

// サーバーのJSONレスポンスに合わせた構造体
struct CalendarData: Codable {
    let estrogen: Double
    let cortisol: Double
    let immunity: Double

    enum CodingKeys: String, CodingKey {
        case estrogen = "estrogen_Level"
        case cortisol = "cortisol_Level"
        case immunity = "immunity_Score"
    }
}


// render： takeshi-y.onrender.com
// ローカル：192.168.0.59:8000
