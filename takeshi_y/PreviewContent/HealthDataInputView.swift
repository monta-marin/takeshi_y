//
//  HealthDataInputView.swift
//  takeshi_y

import SwiftUI

struct ValidationError: Identifiable {
    let id = UUID()
    let message: String
}

struct HealthData: Codable {
    var user_id: String = "test_user_1"
    var age: Double = 0.0
    var height: Double = 0.0
    var weight: Double = 0.0
    var body_fat: Double = 0.0
    var exercise_habit: Bool = false
    var exercise_kcal: Double = 0.0
    var steps: Double = 0.0
    var sleep_duration: Double = 0.0
    var systolic_bp: Double = 0.0
    var diastolic_bp: Double = 0.0
    var body_temperature: Double = 0.0
    var heart_rate: Double = 0.0
    var source_type: String = "direct"
    var date: String = getCurrentDate()

    static func getCurrentDate() -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        // タイムゾーンを設定
        formatter.timeZone = TimeZone.current
        return formatter.string(from: Date())
    }

    // バリデーションチェック
    func validateData() -> [ValidationError] {
        var errors = [ValidationError]()

        // 各フィールドのバリデーションチェック
        if age < 0 || age > 120 {
            errors.append(ValidationError(message: "年齢は0〜120歳の範囲で入力してください。"))
        }
        if height < 50 || height > 250 {
            errors.append(ValidationError(message: "身長は50〜250cmの範囲で入力してください。"))
        }
        if weight < 10 || weight > 300 {
            errors.append(ValidationError(message: "体重は10〜300kgの範囲で入力してください。"))
        }
        if body_fat < 0 || body_fat > 100 {
            errors.append(ValidationError(message: "体脂肪率は0〜100%の範囲で入力してください。"))
        }
        if exercise_kcal < 0 || exercise_kcal > 10000 {
            errors.append(ValidationError(message: "運動消費カロリーは0〜10000kcalの範囲で入力してください。"))
        }
        if steps < 0 || steps > 100000 {
            errors.append(ValidationError(message: "歩数は0〜100000の範囲で入力してください。"))
        }
        if sleep_duration < 0 || sleep_duration > 24 {
            errors.append(ValidationError(message: "睡眠時間は0〜24時間の範囲で入力してください。"))
        }
        if systolic_bp < 50 || systolic_bp > 250 {
            errors.append(ValidationError(message: "最高血圧は50〜250mmHgの範囲で入力してください。"))
        }
        if diastolic_bp < 30 || diastolic_bp > 150 {
            errors.append(ValidationError(message: "最低血圧は30〜150mmHgの範囲で入力してください。"))
        }
        if body_temperature < 30 || body_temperature > 45 {
            errors.append(ValidationError(message: "体温は30〜45℃の範囲で入力してください。"))
        }
        if heart_rate < 30 || heart_rate > 220 {
            errors.append(ValidationError(message: "心拍数は30〜220bpmの範囲で入力してください。"))
        }

        return errors
    }
}

struct HealthDataInputView: View {
    @State private var healthData = HealthData()
    @State private var errorMessages: [ValidationError] = []
    @State private var showAlert = false

    var body: some View {
        NavigationView {
            ZStack {
                LinearGradient(gradient: Gradient(colors: [.pink.opacity(0.3), .purple.opacity(0.3)]), startPoint: .top, endPoint: .bottom)
                    .edgesIgnoringSafeArea(.all)

                ScrollView {
                    VStack {
                        Text("ヘルスデータ情報")
                            .font(.title)
                            .frame(maxWidth: .infinity, alignment: .top)
                            .padding(.top, -35)
                            .padding(.bottom, 10)

                        Group {
                            healthDataInputField(label: "身長 (cm)", value: $healthData.height)
                            healthDataInputField(label: "体重 (kg)", value: $healthData.weight)
                            healthDataInputField(label: "体脂肪率 (%)", value: $healthData.body_fat)
                            healthDataInputField(label: "心拍数 (bpm)", value: $healthData.heart_rate)
                            healthDataInputField(label: "歩数", value: $healthData.steps)
                            healthDataInputField(label: "睡眠時間 (時間)", value: $healthData.sleep_duration)
                            healthDataInputField(label: "体温 (℃)", value: $healthData.body_temperature)
                            healthDataInputField(label: "運動消費カロリー (kcal)", value: $healthData.exercise_kcal)
                            healthDataInputField(label: "最高血圧", value: $healthData.systolic_bp)
                            healthDataInputField(label: "最低血圧", value: $healthData.diastolic_bp)
                            healthDataInputField(label: "年齢", value: $healthData.age)
                        }
                        .padding(.bottom, 10)
                        .background(Color.white.opacity(1))
                        .cornerRadius(1)
                        .frame(height: 49)

                        Toggle("運動習慣あり", isOn: $healthData.exercise_habit)
                            .padding()
                            .background(Color.white.opacity(1))
                            .cornerRadius(1)

                        Button(action: validateAndSendData) {
                            Text("送信")
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(Color.blue)
                                .foregroundColor(.white)
                                .cornerRadius(10)
                        }
                        .padding(.top, 10)

                        Spacer()
                    }
                    .padding()
                    .alert("入力エラー", isPresented: $showAlert, actions: {
                        Button("OK", role: .cancel) {}
                    }, message: {
                        Text(errorMessages.map { $0.message }.joined(separator: "\n"))
                    })
                }
            }
        }
    }

    private func healthDataInputField(label: String, value: Binding<Double>) -> some View {
        HStack {
            Text(label)
            TextField("0.0", value: value, format: .number)
                .keyboardType(.decimalPad)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .onChange(of: value.wrappedValue) { _ in
                    errorMessages = healthData.validateData()
                }
        }
        .padding()
    }

    private func validateAndSendData() {
        // 入力データをバリデーション
        errorMessages = healthData.validateData()
        showAlert = !errorMessages.isEmpty
        
        // バリデーションエラーがない場合、データ送信
        if errorMessages.isEmpty {
            // 最新の日時を設定
            healthData.date = HealthData.getCurrentDate()
            sendHealthDataToServer()
        }
    }

    private func sendHealthDataToServer() {
        guard let url = URL(string: "http://192.168.0.59:8000/healthdata") else { return }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        let healthDataArray: [String: Any] =
           
                [
                    "systolic_bp": healthData.systolic_bp,
                    "steps": healthData.steps,
                    "diastolic_bp": healthData.diastolic_bp,
                    "height": healthData.height,
                    "heart_rate": healthData.heart_rate,
                    "date": healthData.date,
                    "exercise_kcal": healthData.exercise_kcal,
                    "body_temperature": healthData.body_temperature,
                    "age": healthData.age,
                    "exercise_habit": healthData.exercise_habit,
                    "sleep_duration": healthData.sleep_duration,
                    "body_fat": healthData.body_fat,
                    "source_type": healthData.source_type,
                    "weight": healthData.weight,
                    "user_id": healthData.user_id
                ]
        

        do {
            let jsonData = try JSONSerialization.data(withJSONObject: healthDataArray, options: [])
            request.httpBody = jsonData
        } catch {
            print("❌ JSONエンコードエラー: \(error.localizedDescription)")
            return
        }

        URLSession.shared.dataTask(with: request) { _, response, error in
            if let error = error {
                print("❌ 通信エラー: \(error.localizedDescription)")
            } else if let response = response as? HTTPURLResponse {
                if response.statusCode == 200 {
                    print("✅ 送信成功")
                    print("アプリデータ取得完了")
                } else {
                    print("❌ エラー: \(response.statusCode)")
                }
            }
        }.resume()
    }
}












// 2025/2/18

