# Student Exam Score Predictor

## Mission
Millions of students underperform not because of ability, but due to preventable factors; poor attendance, lack of resources, or limited parental support. This project predicts student exam scores from behavioral and socioeconomic indicators to help educators identify at-risk students early and intervene before it is too late.

## Dataset
**Source:** [Student Performance Factors — Kaggle (lainguyn123)](https://www.kaggle.com/datasets/lainguyn123/student-performance-factors)
**Size:** 6,607 students × 20 features
**Features include:** Hours studied, attendance rate, parental involvement, access to resources, tutoring sessions, family income, teacher quality, motivation level, internet access, and more.
**Target:** `Exam_Score` — a continuous score ranging from 55 to 101 points.

---

## API Endpoint
> 🔗 _Public URL (added after deployment in Task 2)_

Swagger UI: `<public-url>/docs`

---

## Video Demo
> 🎥 _YouTube link (added after recording in Task 4)_

---

## Project Structure
```
linear_regression_model/
│
├── summative/
│   ├── linear_regression/
│   │   ├── multivariate.ipynb      # Full model notebook
│   │   ├── best_model.pkl          # Saved best-performing model
│   │   └── scaler.pkl              # Fitted StandardScaler
│   ├── API/
│   │   ├── prediction.py           # FastAPI application
│   │   └── requirements.txt
│   └── FlutterApp/                 # Mobile app source
```

---

## How to Run the Mobile App
> _Instructions added after Flutter app is complete (Task 3)_

---

## Model Performance Summary

| Model | Test MSE | Test RMSE | R² |
|---|---|---|---|
| **Linear Regression (SGD)** | **4.55** | **2.13 pts** | **0.68** |
| Random Forest | 4.84 | 2.20 pts | 0.66 |
| Decision Tree | 6.43 | 2.54 pts | 0.54 |

**Best model:** Linear Regression — lowest test MSE, strongest generalization.
