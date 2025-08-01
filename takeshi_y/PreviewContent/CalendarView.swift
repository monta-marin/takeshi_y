//  CalendarView.swift
//  takeshi_y

import SwiftUI

struct CalendarView: View {
    @AppStorage("lastSelectedDate") private var lastSelectedDateString: String = ""

    @State private var selectedDate: Date = {
        let jst = TimeZone(identifier: "Asia/Tokyo")!
        let calendar = Calendar(identifier: .gregorian)
        let now = Date()
        let components = calendar.dateComponents(in: jst, from: now)
        return calendar.date(from: components) ?? now
    }()

    @State private var isFetchingData = false
    @State private var errorMessage: String? = nil
    @State private var noDataForSelectedDate = false

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
            if let savedDate = ISO8601DateFormatter().date(from: lastSelectedDateString) {
                selectedDate = savedDate
            }
            fetchData(for: selectedDate)
        }
        .onChange(of: selectedDate) { newDate in
            lastSelectedDateString = ISO8601DateFormatter().string(from: newDate)
            fetchData(for: newDate)
        }
    }

    private func fetchData(for date: Date) {
        let formattedDateString = formattedDate(date: date)
        guard !isFetchingData else { return }
        isFetchingData = true
        errorMessage = nil
        noDataForSelectedDate = false

        let urlString = "https://takeshi-y.onrender.com/healthdata/calendar?date=\(formattedDateString)"
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
        formatter.timeZone = TimeZone(identifier: "Asia/Tokyo")
        return formatter.string(from: date)
    }

    private func saveData(for date: Date) {
        let formattedDateString = formattedDate(date: date)
        if let data = healthDataByDate[formattedDateString] {
            print("保存しました: \(formattedDateString) - エストロゲン: \(data.estrogen), コルチゾール: \(data.cortisol), 免疫力: \(data.immunity)")
        } else {
            errorMessage = "❌ 保存するデータがありません"
        }
    }
}

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
