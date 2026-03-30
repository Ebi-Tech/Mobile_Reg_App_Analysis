# Student Exam Score Predictor

## Mission
Millions of students underperform not because of ability, but due to preventable factors — poor attendance, lack of resources, or limited parental support. This project predicts student exam scores from 18 behavioral and socioeconomic indicators to help educators identify at-risk students early and intervene before it is too late.

## Dataset
**Source:** [Student Performance Factors — Kaggle (lainguyn123)](https://www.kaggle.com/datasets/lainguyn123/student-performance-factors)
**Size:** 6,607 students × 20 features
**Features include:** Hours studied, attendance rate, parental involvement, access to resources, tutoring sessions, family income, teacher quality, motivation level, internet access, and more.
**Target:** `Exam_Score` — a continuous score ranging from 55 to 101 points.

---

## Live API
**Swagger UI:** https://mobile-reg-app-analysis.onrender.com/docs
**ReDoc:** https://mobile-reg-app-analysis.onrender.com/redoc
**Health check:** https://mobile-reg-app-analysis.onrender.com/health

> The API is kept alive 24/7 via a GitHub Actions workflow that pings `/health` every 14 minutes.

---

## Video Demo
> 🎥 _[YouTube link](https://youtu.be/jL8DSxOBXXc)_

---

## Project Structure
```
Mobile_Reg_App_Analysis/
│
├── .github/
│   └── workflows/
│       └── keep_alive.yml          # Pings API every 14 min to prevent Render sleep
│
├── linear_regression_model/
│   └── summative/
│       ├── linear_regression/
│       │   ├── multivariate.ipynb      # Full model notebook (Task 1)
│       │   ├── best_model.pkl          # Saved best-performing model
│       │   ├── scaler.pkl              # Fitted StandardScaler
│       │   └── StudentPerformanceFactors.csv
│       ├── API/
│       │   ├── prediction.py           # FastAPI application (Task 2)
│       │   └── requirements.txt
│       └── FlutterApp/                 # Mobile app (Task 3)
│           └── lib/
│               ├── main.dart
│               ├── models/
│               ├── screens/
│               ├── services/
│               └── widgets/
│
├── runtime.txt                         # Pins Python 3.11 for Render
└── README.md
```

---

## Model Performance Summary

| Model | Test MSE | Test RMSE | R² |
|---|---|---|---|
| **Linear Regression (SGD)** | **4.55** | **2.13 pts** | **0.68** |
| Random Forest | 4.84 | 2.20 pts | 0.66 |
| Decision Tree | 6.43 | 2.54 pts | 0.54 |

**Best model:** Linear Regression — lowest test MSE and strongest generalization on this dataset.
The near-linear relationship between study habits/attendance and exam scores makes SGD Linear Regression the most appropriate and efficient choice.

---

## How to Run the Flutter App

**Prerequisites:** Flutter SDK installed, Android emulator running or physical device connected.

```bash
cd linear_regression_model/summative/FlutterApp
flutter pub get
flutter run
```

The app connects to the live Render API automatically. No local API setup required.

---

## API Endpoints

| Method | Path | Description |
|---|---|---|
| `GET` | `/health` | Service status check |
| `POST` | `/predict` | Submit student profile → get predicted exam score |
| `POST` | `/retrain` | Upload new CSV data to retrain the model live |
