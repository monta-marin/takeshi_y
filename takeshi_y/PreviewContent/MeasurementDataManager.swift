import SwiftUI
import HealthKit

struct MeasurementData: Identifiable {
    var id = UUID()
    var userId: String
    var iconName: String
    var title: String
    var value: String = ""
    var unit: String
}

enum DataSource {
    case mock
    case real
}

class MeasurementDataManager: ObservableObject {
    @Published var dataSource: DataSource = .mock
    @Published var measurements: [MeasurementData] = []
    @Published var birthDate: String = ""

    private let healthStore = HKHealthStore()

    init() {
        loadMockData(for: "user_001")
    }

    func loadMockData(for userId: String) {
        self.birthDate = "1985-06-14" // 任意のモック生年月日
        measurements = [
            MeasurementData(userId: userId, iconName: "heart", title: "心拍数", unit: "bpm"),
            MeasurementData(userId: userId, iconName: "waveform.path.ecg", title: "最高血圧", unit: "mmHg"),
            MeasurementData(userId: userId, iconName: "waveform.path.ecg", title: "最低血圧", unit: "mmHg"),
            MeasurementData(userId: userId, iconName: "moon", title: "睡眠時間", unit: "時間"),
            MeasurementData(userId: userId, iconName: "figure.walk", title: "歩数", unit: "歩"),
            MeasurementData(userId: userId, iconName: "thermometer", title: "体温", unit: "℃"),
            MeasurementData(userId: userId, iconName: "flame", title: "消費カロリー", unit: "kcal"),
            MeasurementData(userId: userId, iconName: "lungs", title: "血中酸素濃度", unit: "%")
        ]
    }

    func fetchHealthData() {
        let types: [HKQuantityTypeIdentifier] = [
            .stepCount,
            .heartRate,
            .bodyTemperature,
            .activeEnergyBurned,
            .oxygenSaturation,
            .bloodPressureSystolic,
            .bloodPressureDiastolic
        ]

        let quantityTypes = types.compactMap { HKQuantityType.quantityType(forIdentifier: $0) }
        let displayNames: [HKQuantityTypeIdentifier: (title: String, icon: String, unit: String)] = [
            .stepCount: ("歩数", "figure.walk", "歩"),
            .heartRate: ("心拍数", "heart", "bpm"),
            .bodyTemperature: ("体温", "thermometer", "℃"),
            .activeEnergyBurned: ("消費カロリー", "flame", "kcal"),
            .oxygenSaturation: ("血中酸素濃度", "lungs", "%"),
            .bloodPressureSystolic: ("最高血圧", "waveform.path.ecg", "mmHg"),
            .bloodPressureDiastolic: ("最低血圧", "waveform.path.ecg", "mmHg")
        ]

        // 読み取り対象に生年月日を追加
        let readTypes: Set<HKObjectType> = Set(quantityTypes + [HKObjectType.characteristicType(forIdentifier: .dateOfBirth)!])

        healthStore.requestAuthorization(toShare: [], read: readTypes) { success, error in
            guard success else {
                print("❌ 認証失敗: \(error?.localizedDescription ?? "不明なエラー")")
                return
            }

            DispatchQueue.main.async {
                do {
                    let date = try self.healthStore.dateOfBirthComponents()
                    let formatter = DateFormatter()
                    formatter.dateFormat = "yyyy-MM-dd"
                    if let dob = Calendar.current.date(from: date) {
                        self.birthDate = formatter.string(from: dob)
                        print("🎂 生年月日: \(self.birthDate)")
                    }
                } catch {
                    print("⚠️ 生年月日取得エラー: \(error.localizedDescription)")
                    self.birthDate = "不明"
                }
            }

            let now = Date()
            let startOfDay = Calendar.current.startOfDay(for: now)
            let predicate = HKQuery.predicateForSamples(withStart: startOfDay, end: now, options: .strictStartDate)

            var results: [MeasurementData] = []
            let group = DispatchGroup()

            for id in types {
                guard let type = HKQuantityType.quantityType(forIdentifier: id),
                      let display = displayNames[id] else { continue }
                group.enter()

                let options: HKStatisticsOptions = (id == .stepCount || id == .activeEnergyBurned) ? .cumulativeSum : .discreteAverage

                let query = HKStatisticsQuery(quantityType: type, quantitySamplePredicate: predicate, options: options) { _, stat, _ in
                    defer { group.leave() }

                    guard let quantity = (options == .cumulativeSum ? stat?.sumQuantity() : stat?.averageQuantity()) else {
                        print("⚠️ \(id.rawValue) データなし")
                        return
                    }

                    let value: String
                    switch id {
                    case .stepCount:
                        value = String(Int(quantity.doubleValue(for: .count())))
                    case .heartRate:
                        value = String(format: "%.1f", quantity.doubleValue(for: .init(from: "count/min")))
                    case .bodyTemperature:
                        value = String(format: "%.1f", quantity.doubleValue(for: .degreeCelsius()))
                    case .activeEnergyBurned:
                        value = String(Int(quantity.doubleValue(for: .kilocalorie())))
                    case .oxygenSaturation:
                        value = String(format: "%.1f", quantity.doubleValue(for: .percent()) * 100)
                    case .bloodPressureSystolic, .bloodPressureDiastolic:
                        value = String(format: "%.0f", quantity.doubleValue(for: .millimeterOfMercury()))
                    default:
                        value = "N/A"
                    }

                    DispatchQueue.main.async {
                        results.append(MeasurementData(userId: "user_healthkit", iconName: display.icon, title: display.title, value: value, unit: display.unit))
                    }
                }

                self.healthStore.execute(query)
            }

            group.notify(queue: .main) {
                self.dataSource = .real
                self.measurements = results
            }
        }
    }
}

struct MeasurementView: View {
    @ObservedObject var dataManager = MeasurementDataManager()

    var body: some View {
        VStack(spacing: 16) {
            HStack {
                Button(action: {
                    dataManager.fetchHealthData()
                }) {
                    Label("データ取得（HealthKit）", systemImage: "arrow.down.circle")
                }

                Toggle("モックデータ", isOn: Binding<Bool>(
                    get: { dataManager.dataSource == .mock },
                    set: { isMock in
                        if isMock {
                            dataManager.loadMockData(for: "user_001")
                            dataManager.dataSource = .mock
                        } else {
                            dataManager.fetchHealthData()
                        }
                    }
                ))
            }
            .padding()

            Text("現在のデータ: \(dataManager.dataSource == .mock ? "モック" : "リアル")")
                .font(.caption)
                .foregroundColor(.gray)

            // 生年月日入力欄
            HStack {
                Text("🎂 生年月日:")
                    .font(.footnote)
                    .foregroundColor(.blue)

                TextField("YYYY-MM-DD", text: $dataManager.birthDate)
                    .keyboardType(.numbersAndPunctuation)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .frame(width: 150)
            }
            .padding()

            Spacer()
        }
        //.frame(maxWidth: .infinity, maxHeight: .infinity) // コメントアウト

    }
}








