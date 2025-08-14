# ＝＝＝＝＝＝＝＝＝＝＝＝＝＝＝＝＝＝＝＝＝＝＝＝＝＝＝＝＝＝＝＝＝＝＝＝＝＝＝＝＝＝＝＝＝＝＝＝＝＝＝＝＝＝＝＝＝＝＝＝＝＝＝＝

# 　　　　　　　　　　　　　　　　　　　　⭐️データ解析システム 機械学習モデル「Hanako😸」⭐️

# ＝＝＝＝＝＝＝＝＝＝＝＝＝＝＝＝＝＝＝＝＝＝＝＝＝＝＝＝＝＝＝＝＝＝＝＝＝＝＝＝＝＝＝＝＝＝＝＝＝＝＝＝＝＝＝＝＝＝＝＝＝＝＝＝

from fastapi import FastAPI, HTTPException, Request, BackgroundTasks
from pydantic import BaseModel
import pandas as pd
import json
import os
from datetime import datetime, timedelta, timezone
import numpy as np
from sklearn.linear_model import LinearRegression
from sklearn.preprocessing import StandardScaler, LabelEncoder
import joblib
import aiofiles
from typing import List, Any
import asyncio
import logging
from typing import Any
import pandas as pd

# FastAPIアプリケーションの初期化
app = FastAPI()

# ログ設定
logging.basicConfig(
    level=logging.INFO,
    format="%(asctime)s - %(levelname)s - %(message)s",
    filename="app.log",
    filemode='a'
)

console_handler = logging.StreamHandler()
console_handler.setLevel(logging.INFO)  # コンソールにもINFOレベルのログを出力
formatter = logging.Formatter('%(asctime)s - %(levelname)s - %(message)s')
console_handler.setFormatter(formatter)
logging.getLogger().addHandler(console_handler)

# ファイルパス定義
HEALTH_DATA_FILE = "health_data.json"
SAMPLE_DATA_FILE = "sample_data.json"
COMBINED_DATA_FILE = "combined_data.json"

# ロックオブジェクト
lock = asyncio.Lock()

# アプリケーション起動時に実行
async def on_app_start():
    await save_sample_data_to_combined()
# アプリケーション起動時にサンプルデータを保存
    asyncio.run(on_app_start())
# 非同期関数を呼び出して実行
async def main():
    await combine_data()
# 非同期タスク実行
if __name__ == "__main__":
    asyncio.run(main())
# 実行部分
if __name__ == "__main__":
    # asyncioのイベントループがすでに実行中でない場合に非同期関数を呼び出す
    loop = asyncio.get_event_loop()
    if loop.is_running():
        # 既存のイベントループが実行中の場合
        loop.create_task(combine_data())
    else:
        # イベントループが実行されていない場合は、直接実行
        asyncio.run(combine_data())
    
# ⭐️HealthDataクラスの定義⭐️
class HealthData(BaseModel):
   
    source_type: str            # データの取得元（例：ウェアラブルデバイス名など）
    age: int                    # 年齢
    height: float               # 身長
    weight: float               # 体重
    body_fat: float             # 体脂肪率
    heart_rate: int             # 心拍数
    steps: int                  # 歩数
    sleep_duration: float       # 睡眠時間（時間）
    body_temperature: float     # 体温（摂氏）
    exercise_kcal: float        # 消費カロリー（kcal）
    systolic_bp: int            # 最高血圧（収縮期）
    diastolic_bp: int           # 最低血圧（拡張期）
    exercise_habit: bool        # 運動習慣の有無
    date: str                   # データ取得日
    blood_oxygen: float         # 血中酸素濃度（％）

# データファイルのパス
HEALTH_DATA_FILE = "/path/to/health_data.json"
COMBINED_DATA_FILE = "/path/to/combined_data.json"

# ログを記録するための ロガー（logger）
# _____________________________________
logging.basicConfig(level=logging.INFO)
logger = logging.getLogger(__name__)
# _____________________________________
# 新しい健康データの送信エンドポイント
from fastapi import FastAPI, HTTPException
import requests
import json
import logging
import os
from datetime import datetime
import pandas as pd

# ===========================================🍎サーバーにhealthdataを保存🍎========================================
# 📄アプリからの最新ヘルスデータの送信エンドポイント
@app.post('/healthdata')
async def submit_healthdata(new_data: dict, background_tasks: BackgroundTasks):
    try:
        background_tasks.add_task(overwrite_health_data, new_data)
        logging.info(f"✅ 新しいヘルスデータ受信: {new_data}")
        return {"message": "新しい健康データが受信されました", "data": new_data}
    except Exception as e:
        logging.error(f"❌ 処理エラー: {e}")
        raise HTTPException(status_code=500, detail="データの保存に失敗しました")

# ===============================🍎「アプリからのデータを取得してcombined_data.jsonに追加保存する」🍎==========================
import json
import logging
from datetime import datetime
import requests

# ロギング設定
logging.basicConfig(level=logging.INFO)

def fetch_and_update_data_from_api(url, file_path="combined_data.json"):
    """APIから `health data` を取得し、リスト型でJSONファイルを追加保存後、最新データを返す"""
    try:
        # APIからデータを取得
        response = requests.get(url)
        response.raise_for_status()  # HTTPエラーがあれば例外を投げる
        
        data = response.json()  # JSONデータを取得

        # `health data` が含まれていれば処理を行う
        new_health_data = data.get("health_data", [])
        if new_health_data:
            # `new_health_data` がリスト型でない場合、リスト型に変換
            if not isinstance(new_health_data, list):
                new_health_data = [new_health_data]
            
            # 内側の二重ネストを解消する
            if isinstance(new_health_data[0], dict) and "health_data" in new_health_data[0]:
                new_health_data = new_health_data[0]["health_data"]

            # `combined_data.json` ファイルが存在するかを確認
            try:
                with open(file_path, 'r+', encoding='utf-8') as file:
                    # 既存のデータを読み込む
                    existing_data = json.load(file)

                    # `health_data` がリストでない場合、リストとして設定
                    if "health_data" not in existing_data:
                        existing_data["health_data"] = []
                    
                    # 新しいデータをリストに追加
                    existing_data["health_data"].extend(new_health_data)  # リスト型として追加

                    # 上書き保存
                    file.seek(0)  # ファイルの先頭に戻す
                    json.dump(existing_data, file, ensure_ascii=False, indent=4)

            except FileNotFoundError:
                # ファイルが存在しない場合は、新たに作成してデータを保存
                with open(file_path, 'w', encoding='utf-8') as file:
                    existing_data = {"health_data": new_health_data}  # 新たにリストを作成
                    json.dump(existing_data, file, ensure_ascii=False, indent=4)

            # 最新データを読み込む
            with open(file_path, 'r', encoding='utf-8') as file:
                updated_data = json.load(file)
            
            logging.info("✅ `health_data` をリスト型で追加保存し、最新データを読み込みました")
            return updated_data
        
        else:
            logging.error("❌ `health_data` が API レスポンスに含まれていません")
    
    except requests.exceptions.RequestException as e:
        logging.error(f"APIデータ取得エラー: {e}")
    except json.JSONDecodeError as e:
        logging.error(f"JSONデコードエラー: {e}")
    except Exception as e:
        logging.error(f"データ処理エラー: {e}")
    
    return None


def overwrite_health_data(new_health_data: list, file_path="combined_data.json"):
    """`health_data` セクションを追加保存する"""
    try:
        # 現在の日付・時刻を取得
        current_time = datetime.now().strftime('%Y-%m-%d %H:%M:%S')  # 日付と時間を取得（例: 2025-04-01 14:30:00）

        # 既存の JSON ファイルを読み込む
        try:
            with open(file_path, "r", encoding="utf-8") as file:
                data = json.load(file)
        except FileNotFoundError:
            # ファイルが存在しない場合、新規作成
            data = {"health_data": []}

        # `new_health_data` がリスト型でない場合、リストに変換
        if not isinstance(new_health_data, list):
            logging.warning(f"⚠ `new_health_data` がリスト型でないため、リストに変換します: {new_health_data}")
            new_health_data = [new_health_data]

        # `health_data` セクションを追加
        for entry in new_health_data:
            entry["date"] = current_time  # 各データに `date` を追加

        # 新しいデータを追加
        data["health_data"].extend(new_health_data)  # 既存のデータに追加

        # 更新後のデータを保存
        with open(file_path, "w", encoding="utf-8") as file:
            json.dump(data, file, ensure_ascii=False, indent=4)

        logging.info(f"✅ 最新の `health_data` と `date` を combined_data.json に追加保存🆗 ({current_time})")

        # 追加後にデータを再読み込み
        return load_combined_data(file_path)

    except Exception as e:
        logging.error(f"エラー: {e}")
        return None


def load_combined_data(file_path="combined_data.json"):
    """combined_data.json を読み込み、データを返す"""
    try:
        with open(file_path, "r", encoding="utf-8") as file:
            data = json.load(file)
            return data
    except FileNotFoundError:
        logging.warning(f"⚠ JSONファイルが見つかりません: {file_path}")
        return None
    except json.JSONDecodeError as e:
        logging.error(f"JSONデコードエラー: {e}")
        return None

# ===========================================❗️サーバー起動時には実行しない❗️=============================================
if __name__ == "__main__":
    logging.info("🔵 サーバー起動: データ更新は実行されません")

 
# =======================🍎 解析システムエリア　機械学習モデルSupport Vector Regression（SVR）　🍎===========================
import json
import logging
import numpy as np
from sklearn.preprocessing import MinMaxScaler
from sklearn.svm import SVR
from datetime import datetime
import joblib
from sklearn.preprocessing import StandardScaler

def setup_logging():
    logging.basicConfig(level=logging.INFO, format='%(asctime)s - %(levelname)s - %(message)s')

def load_combined_data(file_path="combined_data.json"):
    try:
        with open(file_path, 'r', encoding='utf-8') as file:
            combined_data = json.load(file)
            logging.info(f"✅ ファイル {file_path} を読み込み成功！")
            
            if not combined_data:
                logging.error("❌ データが空です。")
                return None
            
            estrogen_data = combined_data.get("Estrogen Data", [])
            cortisol_data = combined_data.get("Cortisol Data", [])
            immunity_data = combined_data.get("Immunity Data", [])
            health_data = combined_data.get("Health Data", {})
            
            return process_health_data(estrogen_data, cortisol_data, immunity_data, health_data)
    except (FileNotFoundError, json.JSONDecodeError) as e:
        logging.error(f"❌ ファイルエラー: {e}")
        return None

def smooth_data(data, alpha=0.2):
    smoothed = [data[0]]
    for i in range(1, len(data)):
        smoothed.append(alpha * data[i] + (1 - alpha) * smoothed[i-1])
    return np.array(smoothed)

def process_health_data(estrogen_data, cortisol_data, immunity_data, health_data, menstrual_cycle_phase=None):
    logging.info("✅ 健康データ解析開始")
    
    try:
        # 健康データ取得 & デフォルト値
        height = health_data.get("height", 170)
        weight = health_data.get("weight", 60)
        body_fat = health_data.get("body_fat", 20)
        current_heart_rate = health_data.get("heart_rate", 70)
        steps = health_data.get("steps", 5000)
        sleep_hours = health_data.get("sleep_duration", 7)
        systolic_bp = health_data.get("systolic_bp", 120)
        diastolic_bp = health_data.get("diastolic_bp", 80)
        age = health_data.get("age", 30)
        exercise_habit = int(health_data.get("exercise_habit", False))
        spo2 = health_data.get("spo2", 98)

        # 月経周期の影響考慮
        estrogen_multiplier = 1
        if menstrual_cycle_phase:
            if menstrual_cycle_phase == 'ovulation':
                estrogen_multiplier = 1.5
            elif menstrual_cycle_phase == 'menstruation':
                estrogen_multiplier = 0.5
        
        # BMI, 血圧比, 運動指数の計算
        bmi = weight / ((height / 100) ** 2)
        blood_pressure_ratio = systolic_bp / max(diastolic_bp, 1)
        exercise_index = exercise_habit * (steps / 10000)  # 運動習慣の指数化

        # 特徴量の重み付け調整
        health_features = np.array([
            height * 0.8,  # 身長
            weight * 0.8,  # 体重
            body_fat * 1.2,  # 体脂肪率（重要視）1.5~1.8
            current_heart_rate * 1.1,  # 心拍数（重要視）1.3~1.5
            steps * 1.0,  # 歩数
            sleep_hours * 1.2,  # 睡眠時間（免疫との関係が深いため）1.2 → 1.5
            systolic_bp * 1.1,  # 収縮期血圧
            diastolic_bp * 1.1,  # 拡張期血圧
            age * 1.5,  # 年齢（強調）1.8~2.0
            bmi * 1.3,  # BMI（健康指標として重要）
            blood_pressure_ratio * 1.2,  # 血圧比
            exercise_index * 1.3,  # 運動指数（運動の影響を強調）1.5~1.7
            spo2 * 0.9  # SpO₂（通常値が安定しているため影響は小さめ） 0.7~0.8
        ]).reshape(1, -1)

        scaler = StandardScaler()
        immunity_values = np.array([data.get('Immunity Score', 0) for data in immunity_data]).reshape(-1, 1)

        results = {}

        # エストロゲン推定
        if len(estrogen_data) > 5:
            estrogen_values = smooth_data(np.array([data['Estrogen'] for data in estrogen_data]), alpha=0.2)
            estrogen_values *= estrogen_multiplier
            X_train = np.hstack((estrogen_values.reshape(-1, 1), immunity_values, np.tile(health_features, (len(estrogen_values), 1))))
            X_train = scaler.fit_transform(X_train)
            model_estrogen = SVR(kernel='linear', C=10, epsilon=0.1)
            model_estrogen.fit(X_train, estrogen_values.reshape(-1))
            X_test = scaler.transform(np.hstack((estrogen_values[-1].reshape(1, -1), immunity_values[-1].reshape(1, -1), health_features)))
            results["estrogen_Level"] = round(model_estrogen.predict(X_test)[0], 1)
        else:
            results["estrogen_Level"] = "⚠ データ不足"

        # コルチゾール推定
        if len(cortisol_data) > 1:
            cortisol_values = np.array([data['Cortisol'] for data in cortisol_data]).reshape(-1, 1)
            X_train = np.hstack((cortisol_values, immunity_values, np.tile(health_features, (len(cortisol_values), 1))))
            X_train = scaler.fit_transform(X_train)
            model_cortisol = SVR(kernel='rbf', C=100, gamma='auto', epsilon=0.1)
            model_cortisol.fit(X_train, cortisol_values.reshape(-1))
            X_test = scaler.transform(np.hstack((cortisol_values[-1].reshape(1, -1), immunity_values[-1].reshape(1, -1), health_features)))
            results["cortisol_Level"] = round(float(model_cortisol.predict(X_test)[0]), 1)
        else:
            results["cortisol_Level"] = "⚠ データ不足"

        # 免疫スコア推定
        if immunity_values.size > 1:
            X_train = np.hstack((immunity_values, np.tile(health_features, (len(immunity_values), 1))))
            X_train = scaler.fit_transform(X_train)
            model_immunity = SVR(kernel='rbf', C=100, gamma='auto', epsilon=0.1)
            model_immunity.fit(X_train, immunity_values.reshape(-1))
            X_test = scaler.transform(np.hstack((immunity_values[-1].reshape(1, -1), health_features)))
            results["immunity_Score"] = round(model_immunity.predict(X_test)[0], 1)
        else:
            results["immunity_Score"] = "⚠ データ不足"

        save_analysis_results(results)
        return results

    except Exception as e:
        logging.error(f"❌ エラー発生: {e}")
        return {"エラー": str(e)}

# 解析結果のデータをgithubのanalysis_resultsに保存する　2025/7/28変更！

DATE = datetime.now().strftime('%Y-%m-%d')
FILE_PATH = f"analysis_results/{DATE}.json"

# 追加
import os
import json
import base64
import requests
from datetime import datetime

def save_analysis_results(results):
    # timestampを追加
    results["timestamp"] = datetime.now().strftime('%Y-%m-%d %H:%M:%S')

    GITHUB_TOKEN = os.environ.get("GITHUB_TOKEN")  # 環境変数にGitHubトークンを設定しておく
    REPO = "monta-marin/takeshi_y"
    BRANCH = "main"
    DATE = datetime.now().strftime('%Y-%m-%d')
    FILE_PATH = f"analysis_results/{DATE}.json"

    json_str = json.dumps(results, ensure_ascii=False, indent=2)
    b64_content = base64.b64encode(json_str.encode("utf-8")).decode("utf-8")

    url = f"https://api.github.com/repos/{REPO}/contents/{FILE_PATH}"
    headers = {
        "Authorization": f"token {GITHUB_TOKEN}",
        "Accept": "application/vnd.github.v3+json"
    }

    resp = requests.get(url, headers=headers)
    sha = resp.json().get("sha") if resp.status_code == 200 else None

    payload = {
        "message": f"Add analysis result for {DATE}",
        "content": b64_content,
        "branch": BRANCH
    }
    if sha:
        payload["sha"] = sha

    put_resp = requests.put(url, headers=headers, json=payload)
    if put_resp.status_code in [200, 201]:
        print(f"✅ GitHubに保存成功: {FILE_PATH}")
    else:
        print(f"❌ GitHub保存失敗: {put_resp.status_code}")
        print(put_resp.json())


if __name__ == "__main__":
    setup_logging()
    load_combined_data()

# =========================================📄サーバーからアプリにデータを渡す📄==========================================
# ✅解析結果を取得
from fastapi import FastAPI, HTTPException, Query
from datetime import datetime
import json
import os

@app.get("/")
def read_root():
    return {"message": "FastAPI is running"}


def validate_date_format(date_str: str):
    try:
        datetime.strptime(date_str, "%Y-%m-%d")
    except ValueError:
        raise HTTPException(status_code=400, detail="日付形式が不正です。YYYY-MM-DD 形式で指定してください。")


def fetch_real_health_data(date: str):
    """
    指定日付の JSON ファイルを読み込み、健康データを返す
    """
    file_path = f"analysis_results/{date}.json"

    if not os.path.isfile(file_path):
        raise ValueError(f"{file_path} が見つかりません")

    try:
        with open(file_path, "r", encoding="utf-8") as f:
            data = json.load(f)
    except json.JSONDecodeError as e:
        raise ValueError(f"{file_path} の読み込み中にエラー: {e}")

    required_keys = ["immunity_Score", "estrogen_Level", "cortisol_Level", "timestamp"]
    for key in required_keys:
        if key not in data:
            raise ValueError(f"{key} が {file_path} に存在しません")

    return {
        "immunity_Score": data["immunity_Score"],
        "estrogen_Level": data["estrogen_Level"],
        "cortisol_Level": data["cortisol_Level"],
        "timestamp": data["timestamp"]
    }


def analyze_health_data(date: str):
    """
    健康データを読み込み、整形された辞書を返す
    
    file_path = f"analyze_results/{date}.json"

    """
    try:
        validate_date_format(date)
        health_data = fetch_real_health_data(date)
        return {
            "date": date,
            "immunity_Score": health_data["immunity_Score"],
            "estrogen_Level": health_data["estrogen_Level"],
            "cortisol_Level": health_data["cortisol_Level"],
            "timestamp": health_data["timestamp"]
        }
    except Exception as e:
        print(f"[ERROR] analyze_health_data: {e}")
        raise e

# ✅ 総合データ取得（カレンダー等で使用）
@app.get("/healthdata/calendar")
async def get_analyzed_health_data(date: str = Query(..., description="取得する日付 (YYYY-MM-DD)")):
    try:
        return analyze_health_data(date)
    except Exception as e:
        raise HTTPException(status_code=500, detail=f"サーバーエラー: {str(e)}")


# ✅ エストロゲン取得
@app.get("/healthdata/estrogen")
async def estrogen_data(date: str = Query(..., description="取得する日付 (YYYY-MM-DD)")):
    try:
        result = analyze_health_data(date)
        return {"estrogen_Level": result.get("estrogen_Level", "データ不足")}
    except Exception as e:
        raise HTTPException(status_code=500, detail=f"サーバーエラー: {str(e)}")


# ✅ コルチゾール取得
@app.get("/healthdata/cortisol")
async def cortisol_data(date: str = Query(..., description="取得する日付 (YYYY-MM-DD)")):
    try:
        result = analyze_health_data(date)
        return {"cortisol_Level": result.get("cortisol_Level", "データ不足")}
    except Exception as e:
        raise HTTPException(status_code=500, detail=f"サーバーエラー: {str(e)}")


# ✅ 免疫スコア取得
@app.get("/healthdata/immunity")
async def immunity_data(date: str = Query(..., description="取得する日付 (YYYY-MM-DD)")):
    try:
        result = analyze_health_data(date)
        return {"immunity_Score": result.get("immunity_Score", "データ不足")}
    except Exception as e:
        raise HTTPException(status_code=500, detail=f"サーバーエラー: {str(e)}")


# ✅ 任意日付の全データ取得（GET用）
@app.get("/healthdata")
async def get_health_data(date: str = Query(..., description="取得する日付 (YYYY-MM-DD)")):
    try:
        result = analyze_health_data(date)
        return result
    except ValueError as e:
        raise HTTPException(status_code=404, detail=str(e))
    except Exception as e:
        print(f"[ERROR] get_health_data: {e}")
        raise HTTPException(status_code=500, detail=f"サーバーエラー: {str(e)}")

# =========================================🛜アプリケーションの処理＆起動🛜=================================================
from fastapi import FastAPI, Request
import logging
import uvicorn
import os
import asyncio
import json
from datetime import datetime

# ----------------- ログ設定 -----------------
logging.basicConfig(
    level=logging.INFO,
    format="%(asctime)s - %(levelname)s - %(message)s"
)

# ----------------- FastAPIアプリケーション -----------------
app = FastAPI()

# ----------------- データ結合・更新処理 -----------------
COMBINED_DATA_FILE = "combined_data.json"

async def combine_data():
    """
    起動時に呼ばれるデータ結合処理。
    必要に応じて fetch/update 関数を呼ぶことができます。
    """
    logging.info("combine_data is running (placeholder)")
    
    # 例: combined_data.json がなければ作成
    try:
        with open(COMBINED_DATA_FILE, "r", encoding="utf-8") as f:
            data = json.load(f)
    except FileNotFoundError:
        logging.info(f"{COMBINED_DATA_FILE} が見つかりません。新規作成します。")
        data = {"health_data": []}
        with open(COMBINED_DATA_FILE, "w", encoding="utf-8") as f:
            json.dump(data, f, ensure_ascii=False, indent=4)
    
    # 実際にここで overwrite_health_data や fetch_and_update_data_from_api を呼ぶことが可能
    # await overwrite_health_data(new_data) など
    await asyncio.sleep(0.1)  # プレースホルダー非同期処理

# ----------------- 起動時処理 -----------------
@app.on_event("startup")
async def startup_event():
    logging.info("アプリケーションの起動処理が完了！スタートできます！ 🆗")
    # データ結合処理を呼ぶ
    await combine_data()

# ----------------- ルートエンドポイント -----------------
@app.get("/")
def read_root():
    return {"message": "FastAPI is running on Cloud Run!"}

# ----------------- データ受信エンドポイント -----------------
@app.post("/send-data")
async def send_data(request: Request):
    data = await request.json()
    logging.info(f"受信データ: {data}")

    # 受信データを combined_data.json に追記する例
    try:
        with open(COMBINED_DATA_FILE, "r", encoding="utf-8") as f:
            combined = json.load(f)
    except FileNotFoundError:
        combined = {"health_data": []}

    # 日付を追加
    data["date"] = datetime.now().strftime("%Y-%m-%d %H:%M:%S")
    combined["health_data"].append(data)

    with open(COMBINED_DATA_FILE, "w", encoding="utf-8") as f:
        json.dump(combined, f, ensure_ascii=False, indent=4)

    return {"status": "success", "received": data}

# ----------------- アプリ起動 -----------------
if __name__ == "__main__":
    port = int(os.environ.get("PORT", 8080))
    uvicorn.run("takeshi:app", host="0.0.0.0", port=port)



# ===========================================       備考欄　　　　　　　==================================================
# true有効　False無効
# http://localhost:5000/healthdata にアクセスすると、仮データを使用します。
# http://192.168.0.59:8000/healthdata にアクセスすると、実データを使用します。

# 開発用テスト完了後、本番公開用に変更する　「WSGIサーバー」
