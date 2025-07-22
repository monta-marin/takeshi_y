import joblib
import numpy as np
from sklearn.linear_model import LinearRegression
from sklearn.ensemble import RandomForestRegressor

# ダミーデータ（100サンプル × 4特徴量）
X = np.random.rand(100, 4) * 100
y_estrogen = np.random.rand(100) * 50
y_cortisol = np.random.rand(100) * 20
y_immunity = np.random.randint(50, 100, 100)

# モデルの定義（ダミーの回帰モデル）
estrogen_model = LinearRegression()
cortisol_model = RandomForestRegressor()
immunity_model = RandomForestRegressor()

# モデルの学習
estrogen_model.fit(X, y_estrogen)
cortisol_model.fit(X, y_cortisol)
immunity_model.fit(X, y_immunity)

# モデルの保存（FastAPI サーバーと同じディレクトリに保存）
joblib.dump(estrogen_model, "estrogen_model.pkl")
joblib.dump(cortisol_model, "cortisol_model.pkl")
joblib.dump(immunity_model, "immunity_model.pkl")

print("✅ モデルの保存が完了しました！")

