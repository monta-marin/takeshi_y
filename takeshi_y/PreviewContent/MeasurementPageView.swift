//
//  MeasurementPageView.swift
//  takeshi_y
//
//  Created by 山崎猛 on 2025/02/13.
//

import SwiftUI
import HealthKit

// MARK: - モデル

struct Measurement: Identifiable {
    var id = UUID()
    var userId: String
    var iconName: String
    var title: String
    var value: String
    var unit: String
}

// MARK: - ビューモデル

class MeasurementDataViewModel: ObservableObject {
    @Published var measurements: [Measurement] = []
    @Published var birthdate: Date = Date()

    func loadMockData(for userId: String) {
        birthdate = Calendar.current.date(from: DateComponents(year: 1985, month: 6, day: 15)) ?? Date()

        measurements = [
            Measurement(userId: userId, iconName: "heart", title: "心拍数", value: "75", unit: "bpm"),
            Measurement(userId: userId, iconName: "waveform.path.ecg", title: "最高血圧", value: "120", unit: "mmHg"),
            Measurement(userId: userId, iconName: "waveform.path.ecg", title: "最低血圧", value: "80", unit: "mmHg"),
            Measurement(userId: userId, iconName: "moon", title: "睡眠時間", value: "7.5", unit: "時間"),
            Measurement(userId: userId, iconName: "figure.walk", title: "歩数", value: "8000", unit: "歩"),
            Measurement(userId: userId, iconName: "thermometer", title: "体温", value: "36.5", unit: "℃"),
            Measurement(userId: userId, iconName: "flame", title: "消費カロリー", value: "500", unit: "kcal"),
            Measurement(userId: userId, iconName: "lungs", title: "血中酸素濃度", value: "98", unit: "%")
        ]
    }
}

// MARK: - メインビュー

struct MeasurementPageView: View {
    @StateObject private var viewModel = MeasurementDataViewModel()
    @State private var isManualMode = true

    func sendDataToPython() {
        guard !viewModel.measurements.isEmpty else {
            print("❌ データがないため、送信をスキップします")
            return
        }

        guard let url = URL(string: "http://192.168.0.59:8000/healthdata"),
              let userId = viewModel.measurements.first?.userId else {
            print("❌ URLまたはユーザーIDの取得に失敗しました")
            return
        }

        let dataDict = Dictionary(uniqueKeysWithValues: viewModel.measurements.map { ($0.title, $0.value) })

        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        let birthdateString = dateFormatter.string(from: viewModel.birthdate)

        let payload: [String: Any] = [
            "user_id": userId,
            "birthdate": birthdateString,
            "data": dataDict
        ]

        guard let jsonData = try? JSONSerialization.data(withJSONObject: payload) else {
            print("❌ JSONエンコードに失敗しました")
            return
        }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = jsonData

        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                print("❌ 送信エラー: \(error.localizedDescription)")
                return
            }

            if let data = data, let responseString = String(data: data, encoding: .utf8) {
                print("✅ Pythonサーバーからの応答: \(responseString)")
            }
        }.resume()
    }

    func fetchHealthData() {
        print("📡 HealthKitからデータを取得予定です")
    }

    var body: some View {
        NavigationView {
            ZStack {
                LinearGradient(gradient: Gradient(colors: [.pink.opacity(0.3), .purple.opacity(0.3)]),
                               startPoint: .top,
                               endPoint: .bottom)
                    .edgesIgnoringSafeArea(.all)

                VStack(spacing: 15) {
                    Text("ウェアラブルデータ")
                        .font(.system(size: 25, weight: .bold))

                    Toggle(isOn: $isManualMode) {
                        Text(isManualMode ? "手動入力モード" : "HealthKitモード")
                            .font(.headline)
                    }
                    .padding()
                    .background(Color.white.opacity(0.8))
                    .cornerRadius(10)

                    if isManualMode {
                        HStack(spacing: 20) {
                            Button(action: {
                                viewModel.loadMockData(for: "user_001")
                            }) {
                                Text("ユーザー001")
                                    .padding(.horizontal)
                                    .padding(.vertical, 8)
                                    .background(Color.green)
                                    .foregroundColor(.white)
                                    .cornerRadius(8)
                            }

                            Button(action: {
                                viewModel.loadMockData(for: "user_002")
                            }) {
                                Text("ユーザー002")
                                    .padding(.horizontal)
                                    .padding(.vertical, 8)
                                    .background(Color.orange)
                                    .foregroundColor(.white)
                                    .cornerRadius(8)
                            }
                        }

                        ManualInputView(measurements: $viewModel.measurements, birthdate: $viewModel.birthdate)
                    } else {
                        Button(action: {
                            fetchHealthData()
                        }) {
                            Text("HealthKitデータ取得")
                                .padding()
                                .frame(maxWidth: .infinity)
                                .background(Color.blue)
                                .foregroundColor(.white)
                                .cornerRadius(10)
                        }
                    }

                    Button(action: {
                        sendDataToPython()
                    }) {
                        Text("ウェアラブルデータを送信")
                            .font(.system(size: 20, weight: .bold))
                            .padding()
                            .frame(maxWidth: .infinity)
                            .background(Color.blue)
                            .foregroundColor(.white)
                            .cornerRadius(10)
                    }
                    .padding(.horizontal)
                }
                .padding()
            }
        }
    }
}

// MARK: - 手動入力ビュー

struct ManualInputView: View {
    @Binding var measurements: [Measurement]
    @Binding var birthdate: Date

    var body: some View {
        ScrollView {
            VStack(spacing: 10) {
                VStack(alignment: .leading) {
                    Text("生年月日")
                        .font(.headline)
                    DatePicker("生年月日", selection: $birthdate, displayedComponents: [.date])
                        .datePickerStyle(CompactDatePickerStyle())
                        .padding(.horizontal)
                        .background(Color.white.opacity(0.9))
                        .cornerRadius(10)
                        .shadow(radius: 3)
                }
                .padding(.horizontal)

                ForEach($measurements) { $measurement in
                    HStack {
                        Image(systemName: measurement.iconName)
                            .foregroundColor(.purple)
                            .frame(width: 30)

                        Text(measurement.title)
                            .font(.headline)
                            .frame(width: 100, alignment: .leading)

                        TextField("値を入力", text: $measurement.value)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                            .keyboardType(measurement.title.contains("血圧") ? .default : .decimalPad)
                            .frame(width: 100)

                        Text(measurement.unit)
                            .foregroundColor(.gray)
                    }
                    .padding()
                    .background(Color.white.opacity(0.9))
                    .cornerRadius(10)
                    .shadow(radius: 3)
                    .padding(.horizontal)
                }
            }
            .padding(.top)
        }
    }
}


// MARK: - プレビュー

struct MeasurementPageView_Previews: PreviewProvider {
    static var previews: some View {
        MeasurementPageView()
    }
}







