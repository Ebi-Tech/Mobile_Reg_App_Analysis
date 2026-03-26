import io
import joblib
import numpy as np
import pandas as pd
from fastapi import Body, FastAPI, File, HTTPException, UploadFile
from fastapi.middleware.cors import CORSMiddleware
from fastapi.openapi.docs import get_swagger_ui_html
from fastapi.responses import HTMLResponse, RedirectResponse
from pydantic import BaseModel, Field
from sklearn.linear_model import SGDRegressor
from sklearn.model_selection import train_test_split
from sklearn.preprocessing import StandardScaler
from typing import Literal

# ---------------------------------------------------------------------------
# App metadata — renders at the top of Swagger UI
# ---------------------------------------------------------------------------
description = """
## Student Exam Score Predictor API

Predicts a student's **exam score (55–101 points)** from 18 behavioral and
socioeconomic factors using a Linear Regression model trained on 6,607 students.

**Mission:** Early identification of at-risk students to enable targeted
educational interventions before performance declines further.

---

### Endpoints

| Method | Path | Purpose |
|--------|------|---------|
| `POST` | `/predict` | Submit a student profile → receive predicted score |
| `POST` | `/retrain` | Upload new CSV data → retrain the model live |
| `GET`  | `/health`  | Check service and model status |

---

### Model Performance

| Model | RMSE | R² |
|-------|------|----|
| **Linear Regression** ✅ | **2.13** | **0.68** |
| Random Forest | 2.20 | 0.66 |
| Decision Tree | 2.54 | 0.54 |

### Input Categories
- **Numeric:** Hours studied, attendance, sleep, previous scores, tutoring, physical activity
- **Categorical:** Parental involvement, resources, motivation, income, school type, and more
"""

tags_metadata = [
    {
        "name": "Prediction",
        "description": "Submit a student profile and receive a predicted exam score.",
    },
    {
        "name": "Model Management",
        "description": "Upload new training data to retrain and update the live model.",
    },
    {
        "name": "System",
        "description": "Service health and status checks.",
    },
]

app = FastAPI(
    title="Student Exam Score Predictor",
    description=description,
    version="1.0.0",
    contact={
        "name": "Student Score Predictor",
        "url": "https://mobile-reg-app-analysis.onrender.com",
    },
    openapi_tags=tags_metadata,
    docs_url=None,   # Serve a custom /docs
    redoc_url="/redoc",
)


# CORS configuration to allow requests from local development environments and the deployed frontend

app.add_middleware(
    CORSMiddleware,
    allow_origins=[
        "http://localhost",
        "http://localhost:3000",
        "http://localhost:8080",
        "http://10.0.2.2",          # Android emulator 
        "http://10.0.2.2:8000",
        "https://mobile-reg-app-analysis.onrender.com",
    ],
    allow_credentials=True,
    allow_methods=["GET", "POST", "OPTIONS"],
    allow_headers=["Content-Type", "Authorization", "Accept", "Origin"],
)

# ---------------------------------------------------------------------------
# Load model and scaler
# ---------------------------------------------------------------------------
model: SGDRegressor    = joblib.load("best_model.pkl")
scaler: StandardScaler = joblib.load("scaler.pkl")

# ---------------------------------------------------------------------------
# Encoding maps — alphabetical order matching LabelEncoder from training
# ---------------------------------------------------------------------------
ENCODE = {
    "Parental_Involvement":       {"High": 0, "Low": 1, "Medium": 2},
    "Access_to_Resources":        {"High": 0, "Low": 1, "Medium": 2},
    "Extracurricular_Activities": {"No": 0, "Yes": 1},
    "Motivation_Level":           {"High": 0, "Low": 1, "Medium": 2},
    "Internet_Access":            {"No": 0, "Yes": 1},
    "Family_Income":              {"High": 0, "Low": 1, "Medium": 2},
    "Teacher_Quality":            {"High": 0, "Low": 1, "Medium": 2},
    "School_Type":                {"Private": 0, "Public": 1},
    "Peer_Influence":             {"Negative": 0, "Neutral": 1, "Positive": 2},
    "Learning_Disabilities":      {"No": 0, "Yes": 1},
    "Parental_Education_Level":   {"College": 0, "High School": 1, "Postgraduate": 2},
    "Distance_from_Home":         {"Far": 0, "Moderate": 1, "Near": 2},
}

FEATURE_ORDER = [
    "Hours_Studied", "Attendance", "Parental_Involvement",
    "Access_to_Resources", "Extracurricular_Activities", "Sleep_Hours",
    "Previous_Scores", "Motivation_Level", "Internet_Access",
    "Tutoring_Sessions", "Family_Income", "Teacher_Quality",
    "School_Type", "Peer_Influence", "Physical_Activity",
    "Learning_Disabilities", "Parental_Education_Level", "Distance_from_Home",
]

# ---------------------------------------------------------------------------
# Named request body examples
# ---------------------------------------------------------------------------
EXAMPLE_HIGH_PERFORMER = {
    "Hours_Studied": 35,
    "Attendance": 95,
    "Sleep_Hours": 8,
    "Previous_Scores": 90,
    "Tutoring_Sessions": 3,
    "Physical_Activity": 4,
    "Parental_Involvement": "High",
    "Access_to_Resources": "High",
    "Extracurricular_Activities": "Yes",
    "Motivation_Level": "High",
    "Internet_Access": "Yes",
    "Family_Income": "High",
    "Teacher_Quality": "High",
    "School_Type": "Private",
    "Peer_Influence": "Positive",
    "Learning_Disabilities": "No",
    "Parental_Education_Level": "Postgraduate",
    "Distance_from_Home": "Near",
}

EXAMPLE_AT_RISK = {
    "Hours_Studied": 5,
    "Attendance": 62,
    "Sleep_Hours": 5,
    "Previous_Scores": 52,
    "Tutoring_Sessions": 0,
    "Physical_Activity": 1,
    "Parental_Involvement": "Low",
    "Access_to_Resources": "Low",
    "Extracurricular_Activities": "No",
    "Motivation_Level": "Low",
    "Internet_Access": "No",
    "Family_Income": "Low",
    "Teacher_Quality": "Low",
    "School_Type": "Public",
    "Peer_Influence": "Negative",
    "Learning_Disabilities": "Yes",
    "Parental_Education_Level": "High School",
    "Distance_from_Home": "Far",
}

EXAMPLE_AVERAGE = {
    "Hours_Studied": 23,
    "Attendance": 84,
    "Sleep_Hours": 7,
    "Previous_Scores": 73,
    "Tutoring_Sessions": 0,
    "Physical_Activity": 3,
    "Parental_Involvement": "Low",
    "Access_to_Resources": "High",
    "Extracurricular_Activities": "No",
    "Motivation_Level": "Low",
    "Internet_Access": "Yes",
    "Family_Income": "Low",
    "Teacher_Quality": "Medium",
    "School_Type": "Public",
    "Peer_Influence": "Positive",
    "Learning_Disabilities": "No",
    "Parental_Education_Level": "High School",
    "Distance_from_Home": "Near",
}

# ---------------------------------------------------------------------------
# Pydantic models — input + response schemas (visible in Swagger UI)
# ---------------------------------------------------------------------------
class StudentInput(BaseModel):
    # Numeric fields with range constraints
    Hours_Studied:              int = Field(..., ge=1,  le=44,  description="Hours spent studying per week (1–44)")
    Attendance:                 int = Field(..., ge=60, le=100, description="Class attendance percentage (60–100)")
    Sleep_Hours:                int = Field(..., ge=4,  le=10,  description="Average daily sleep hours (4–10)")
    Previous_Scores:            int = Field(..., ge=50, le=100, description="Score from the previous exam (50–100)")
    Tutoring_Sessions:          int = Field(..., ge=0,  le=8,   description="Number of tutoring sessions per month (0–8)")
    Physical_Activity:          int = Field(..., ge=0,  le=6,   description="Hours of physical activity per week (0–6)")

    # Categorical fields with enforced string enumerations
    Parental_Involvement:       Literal["Low", "Medium", "High"] = Field(..., description="Level of parental involvement in the student's education")
    Access_to_Resources:        Literal["Low", "Medium", "High"] = Field(..., description="Student's access to educational resources (books, internet, etc.)")
    Extracurricular_Activities: Literal["Yes", "No"]             = Field(..., description="Whether the student participates in extracurricular activities")
    Motivation_Level:           Literal["Low", "Medium", "High"] = Field(..., description="Student's self-reported motivation level")
    Internet_Access:            Literal["Yes", "No"]             = Field(..., description="Whether the student has internet access at home")
    Family_Income:              Literal["Low", "Medium", "High"] = Field(..., description="Household income level")
    Teacher_Quality:            Literal["Low", "Medium", "High"] = Field(..., description="Quality rating of the student's primary teacher")
    School_Type:                Literal["Public", "Private"]     = Field(..., description="Type of school attended")
    Peer_Influence:             Literal["Positive", "Neutral", "Negative"] = Field(..., description="Influence of the student's peer group on academic performance")
    Learning_Disabilities:      Literal["Yes", "No"]             = Field(..., description="Whether the student has a diagnosed learning disability")
    Parental_Education_Level:   Literal["High School", "College", "Postgraduate"] = Field(..., description="Highest education level attained by parents")
    Distance_from_Home:         Literal["Near", "Moderate", "Far"] = Field(..., description="Distance from home to school")


class PredictionResponse(BaseModel):
    predicted_exam_score: float = Field(..., description="Predicted exam score in points", example=67.45)
    unit:                 str   = Field(default="points", description="Unit of the predicted score")
    score_range:          str   = Field(default="55–101", description="Valid score range for this model")


class HealthResponse(BaseModel):
    status: str = Field(..., description="Service status", example="ok")
    model:  str = Field(..., description="Active model class name", example="SGDRegressor")


class RetrainResponse(BaseModel):
    message:   str = Field(..., description="Result message")
    rows_used: int = Field(..., description="Number of training rows used")
    model:     str = Field(..., description="Model class used for retraining")


# ---------------------------------------------------------------------------
# Helper
# ---------------------------------------------------------------------------
def encode_input(data: StudentInput) -> np.ndarray:
    raw = {
        "Hours_Studied":               data.Hours_Studied,
        "Attendance":                  data.Attendance,
        "Parental_Involvement":        ENCODE["Parental_Involvement"][data.Parental_Involvement],
        "Access_to_Resources":         ENCODE["Access_to_Resources"][data.Access_to_Resources],
        "Extracurricular_Activities":  ENCODE["Extracurricular_Activities"][data.Extracurricular_Activities],
        "Sleep_Hours":                 data.Sleep_Hours,
        "Previous_Scores":             data.Previous_Scores,
        "Motivation_Level":            ENCODE["Motivation_Level"][data.Motivation_Level],
        "Internet_Access":             ENCODE["Internet_Access"][data.Internet_Access],
        "Tutoring_Sessions":           data.Tutoring_Sessions,
        "Family_Income":               ENCODE["Family_Income"][data.Family_Income],
        "Teacher_Quality":             ENCODE["Teacher_Quality"][data.Teacher_Quality],
        "School_Type":                 ENCODE["School_Type"][data.School_Type],
        "Peer_Influence":              ENCODE["Peer_Influence"][data.Peer_Influence],
        "Physical_Activity":           data.Physical_Activity,
        "Learning_Disabilities":       ENCODE["Learning_Disabilities"][data.Learning_Disabilities],
        "Parental_Education_Level":    ENCODE["Parental_Education_Level"][data.Parental_Education_Level],
        "Distance_from_Home":          ENCODE["Distance_from_Home"][data.Distance_from_Home],
    }
    row = [raw[f] for f in FEATURE_ORDER]
    return np.array(row, dtype=float).reshape(1, -1)


# ---------------------------------------------------------------------------
# Custom Swagger UI with branded CSS
# ---------------------------------------------------------------------------
CUSTOM_CSS = """
<style>
  /* ── Top bar ── */
  .swagger-ui .topbar {
    background: linear-gradient(135deg, #1a1a2e 0%, #16213e 50%, #0f3460 100%);
    padding: 12px 0;
    box-shadow: 0 2px 8px rgba(0,0,0,0.4);
  }
  .swagger-ui .topbar-wrapper img { display: none; }
  .swagger-ui .topbar-wrapper::before {
    content: '🎓  Student Exam Score Predictor';
    color: #e0e0e0;
    font-size: 1.3rem;
    font-weight: 700;
    letter-spacing: 0.5px;
    padding-left: 24px;
  }

  /* ── Info title ── */
  .swagger-ui .info .title { color: #0f3460; font-size: 2rem; }
  .swagger-ui .info a { color: #0f3460; }

  /* ── Tag section headers ── */
  .swagger-ui .opblock-tag {
    background: #f0f4ff;
    border-radius: 8px;
    border-left: 5px solid #0f3460;
    margin-bottom: 6px;
    font-size: 1.1rem;
  }

  /* ── POST blocks ── */
  .swagger-ui .opblock.opblock-post {
    border-color: #0f3460;
    background: rgba(15, 52, 96, 0.04);
    border-radius: 8px;
  }
  .swagger-ui .opblock.opblock-post .opblock-summary-method {
    background: #0f3460;
    border-radius: 4px;
    font-weight: 700;
  }
  .swagger-ui .opblock.opblock-post .opblock-summary {
    border-color: #0f3460;
  }

  /* ── GET blocks ── */
  .swagger-ui .opblock.opblock-get {
    border-color: #2d6a4f;
    background: rgba(45, 106, 79, 0.04);
    border-radius: 8px;
  }
  .swagger-ui .opblock.opblock-get .opblock-summary-method {
    background: #2d6a4f;
    border-radius: 4px;
    font-weight: 700;
  }

  /* ── Execute button ── */
  .swagger-ui .btn.execute {
    background: #0f3460 !important;
    border-color: #0f3460 !important;
    border-radius: 6px;
    font-weight: 600;
  }
  .swagger-ui .btn.execute:hover {
    background: #1a4a80 !important;
  }

  /* ── Response code badges ── */
  .swagger-ui .responses-inner h4,
  .swagger-ui .response-col_status { color: #0f3460; }

  /* ── Schema section ── */
  .swagger-ui section.models { border-radius: 8px; }
  .swagger-ui section.models h4 { color: #0f3460; }

  /* ── Example dropdown ── */
  .swagger-ui .examples-select select {
    border: 1px solid #0f3460;
    border-radius: 4px;
    color: #0f3460;
    font-weight: 600;
  }

  /* ── Load Sample button (injected via JS) ── */
  .load-sample-btn {
    background: #0f3460;
    color: white;
    border: none;
    padding: 8px 18px;
    border-radius: 6px;
    cursor: pointer;
    font-size: 13px;
    font-weight: 600;
    margin-bottom: 10px;
    display: inline-flex;
    align-items: center;
    gap: 6px;
    transition: background 0.2s;
  }
  .load-sample-btn:hover { background: #1a4a80; }

  /* ── Range hint box (injected via JS) ── */
  .range-hint-box {
    background: #f0f4ff;
    border: 1px solid #c7d4f0;
    border-left: 4px solid #0f3460;
    border-radius: 6px;
    padding: 12px 16px;
    margin-bottom: 12px;
    font-size: 12.5px;
    line-height: 1.7;
    color: #222;
  }
  .range-hint-box strong { color: #0f3460; }
  .range-hint-box table { width: 100%; border-collapse: collapse; margin-top: 6px; }
  .range-hint-box th {
    background: #0f3460; color: white;
    padding: 5px 10px; text-align: left; font-size: 12px;
  }
  .range-hint-box td { padding: 4px 10px; border-bottom: 1px solid #dde4f5; }
  .range-hint-box tr:last-child td { border-bottom: none; }

  /* ── General body ── */
  body { background: #f8f9fc; }
  .swagger-ui { font-family: 'Inter', 'Segoe UI', sans-serif; }
</style>
"""

CUSTOM_JS = """
<script>
const SAMPLE_DATA = {
  "Hours_Studied": 23,
  "Attendance": 84,
  "Sleep_Hours": 7,
  "Previous_Scores": 73,
  "Tutoring_Sessions": 2,
  "Physical_Activity": 3,
  "Parental_Involvement": "Medium",
  "Access_to_Resources": "High",
  "Extracurricular_Activities": "Yes",
  "Motivation_Level": "Medium",
  "Internet_Access": "Yes",
  "Family_Income": "Medium",
  "Teacher_Quality": "Medium",
  "School_Type": "Public",
  "Peer_Influence": "Positive",
  "Learning_Disabilities": "No",
  "Parental_Education_Level": "College",
  "Distance_from_Home": "Near"
};

const RANGE_HTML = `
<div class="range-hint-box">
  <strong>📋 Field Reference — Valid inputs for each field</strong>
  <table>
    <tr><th>Field</th><th>Type</th><th>Valid Values</th></tr>
    <tr><td>Hours_Studied</td><td>number</td><td>1 – 44</td></tr>
    <tr><td>Attendance</td><td>number</td><td>60 – 100 (%)</td></tr>
    <tr><td>Sleep_Hours</td><td>number</td><td>4 – 10</td></tr>
    <tr><td>Previous_Scores</td><td>number</td><td>50 – 100</td></tr>
    <tr><td>Tutoring_Sessions</td><td>number</td><td>0 – 8 (per month)</td></tr>
    <tr><td>Physical_Activity</td><td>number</td><td>0 – 6 (hrs/week)</td></tr>
    <tr><td>Parental_Involvement</td><td>string</td><td>"Low" | "Medium" | "High"</td></tr>
    <tr><td>Access_to_Resources</td><td>string</td><td>"Low" | "Medium" | "High"</td></tr>
    <tr><td>Extracurricular_Activities</td><td>string</td><td>"Yes" | "No"</td></tr>
    <tr><td>Motivation_Level</td><td>string</td><td>"Low" | "Medium" | "High"</td></tr>
    <tr><td>Internet_Access</td><td>string</td><td>"Yes" | "No"</td></tr>
    <tr><td>Family_Income</td><td>string</td><td>"Low" | "Medium" | "High"</td></tr>
    <tr><td>Teacher_Quality</td><td>string</td><td>"Low" | "Medium" | "High"</td></tr>
    <tr><td>School_Type</td><td>string</td><td>"Public" | "Private"</td></tr>
    <tr><td>Peer_Influence</td><td>string</td><td>"Positive" | "Neutral" | "Negative"</td></tr>
    <tr><td>Learning_Disabilities</td><td>string</td><td>"Yes" | "No"</td></tr>
    <tr><td>Parental_Education_Level</td><td>string</td><td>"High School" | "College" | "Postgraduate"</td></tr>
    <tr><td>Distance_from_Home</td><td>string</td><td>"Near" | "Moderate" | "Far"</td></tr>
  </table>
</div>`;

function loadSampleIntoTextarea(textarea) {
  const setter = Object.getOwnPropertyDescriptor(
    window.HTMLTextAreaElement.prototype, 'value'
  ).set;
  setter.call(textarea, JSON.stringify(SAMPLE_DATA, null, 2));
  textarea.dispatchEvent(new Event('input', { bubbles: true }));
}

function injectPredictHelpers() {
  document.querySelectorAll('.opblock').forEach(block => {
    const path = block.querySelector('.opblock-summary-path');
    if (!path || !path.textContent.trim().includes('/predict')) return;

    const textarea = block.querySelector('textarea.body-param__text');
    if (!textarea || textarea.dataset.helperAdded) return;
    textarea.dataset.helperAdded = 'true';

    // Range hint box
    const hintDiv = document.createElement('div');
    hintDiv.innerHTML = RANGE_HTML;

    // Load Sample button
    const btn = document.createElement('button');
    btn.className = 'load-sample-btn';
    btn.innerHTML = '📋 Load Sample Values';
    btn.type = 'button';
    btn.addEventListener('click', (e) => {
      e.preventDefault();
      loadSampleIntoTextarea(textarea);
    });

    const wrapper = document.createElement('div');
    wrapper.appendChild(hintDiv);
    wrapper.appendChild(btn);
    textarea.parentNode.insertBefore(wrapper, textarea);
  });
}

const observer = new MutationObserver(injectPredictHelpers);
observer.observe(document.body, { childList: true, subtree: true });
</script>
"""


@app.get("/docs", include_in_schema=False)
async def custom_swagger_ui_html():
    html = get_swagger_ui_html(
        openapi_url="/openapi.json",
        title="Student Exam Score Predictor — API Docs",
        swagger_ui_parameters={
            "docExpansion": "list",          # all endpoints expanded on load
            "filter": True,                  # search/filter bar
            "persistAuthorization": True,
            "defaultModelsExpandDepth": 2,   # show response schemas expanded
            "displayRequestDuration": True,  # show ms per request
            "tryItOutEnabled": True,         # "Try it out" enabled by default
        },
    )
    modified = html.body.decode("utf-8").replace("</head>", CUSTOM_CSS + "</head>")
    modified = modified.replace("</body>", CUSTOM_JS + "</body>")
    return HTMLResponse(content=modified)


# ---------------------------------------------------------------------------
# Endpoints
# ---------------------------------------------------------------------------
@app.get("/", include_in_schema=False)
def root():
    return RedirectResponse(url="/docs")


@app.get(
    "/health",
    tags=["System"],
    summary="Service health check",
    response_model=HealthResponse,
)
def health():
    """Returns the current service status and active model type."""
    return HealthResponse(status="ok", model=type(model).__name__)


@app.post(
    "/predict",
    tags=["Prediction"],
    summary="Predict student exam score",
    response_model=PredictionResponse,
    responses={
        200: {"description": "Predicted exam score returned successfully"},
        422: {"description": "Validation error — a field is out of range or has an invalid value"},
        500: {"description": "Internal server error during prediction"},
    },
)
def predict(
    student: StudentInput = Body(
        examples={
            "average_student": {
                "summary": "Average Student",
                "description": "Typical mid-range student — expected score ~67",
                "value": EXAMPLE_AVERAGE,
            },
            "high_performer": {
                "summary": "High Performer",
                "description": "Student with strong habits and high support — expected score ~90+",
                "value": EXAMPLE_HIGH_PERFORMER,
            },
            "at_risk_student": {
                "summary": "At-Risk Student",
                "description": "Struggling student with limited resources — expected score ~55",
                "value": EXAMPLE_AT_RISK,
            },
        }
    )
):
    """
    Submit a complete student profile and receive a predicted exam score.

    - All **numeric fields** are validated against realistic dataset ranges.
    - All **categorical fields** only accept the listed string values.
    - Returns a score clamped to the valid range of **55–101 points**.
    - Use the **Examples dropdown** above to load pre-built student profiles.
    """
    try:
        X        = encode_input(student)
        X_scaled = scaler.transform(X)
        score    = float(model.predict(X_scaled)[0])
        score    = round(max(55.0, min(101.0, score)), 2)
        return PredictionResponse(
            predicted_exam_score=score,
            unit="points",
            score_range="55–101",
        )
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))


@app.post(
    "/retrain",
    tags=["Model Management"],
    summary="Retrain model with new data",
    response_model=RetrainResponse,
    responses={
        200: {"description": "Model retrained and saved successfully"},
        400: {"description": "Invalid file format or missing required columns"},
        500: {"description": "Retraining failed due to a server error"},
    },
)
async def retrain(file: UploadFile = File(..., description="CSV file with the same column schema as the training dataset")):
    """
    Upload a new CSV file to retrain the model live.

    **Required columns:** All 18 feature columns + `Exam_Score`.
    The updated model is saved to disk and takes effect immediately —
    no restart required.

    **CSV schema must match:**
    `Hours_Studied, Attendance, Parental_Involvement, Access_to_Resources,
    Extracurricular_Activities, Sleep_Hours, Previous_Scores, Motivation_Level,
    Internet_Access, Tutoring_Sessions, Family_Income, Teacher_Quality,
    School_Type, Peer_Influence, Physical_Activity, Learning_Disabilities,
    Parental_Education_Level, Distance_from_Home, Exam_Score`
    """
    global model, scaler
    if not file.filename.endswith(".csv"):
        raise HTTPException(status_code=400, detail="Only CSV files are accepted.")
    try:
        contents = await file.read()
        df = pd.read_csv(io.BytesIO(contents))

        required = set(FEATURE_ORDER + ["Exam_Score"])
        missing  = required - set(df.columns)
        if missing:
            raise HTTPException(status_code=400, detail=f"Missing columns: {missing}")

        for col in ["Teacher_Quality", "Parental_Education_Level", "Distance_from_Home"]:
            if col in df.columns:
                df[col] = df[col].fillna(df[col].mode()[0])
        if "Gender" in df.columns:
            df.drop(columns=["Gender"], inplace=True)

        for col, mapping in ENCODE.items():
            if col in df.columns:
                df[col] = df[col].map(mapping)

        X = df[FEATURE_ORDER]
        y = df["Exam_Score"]
        X_train, _, y_train, _ = train_test_split(X, y, test_size=0.2, random_state=42)

        new_scaler   = StandardScaler()
        X_train_sc   = new_scaler.fit_transform(X_train)
        new_model    = SGDRegressor(max_iter=300, random_state=42)
        new_model.fit(X_train_sc, y_train)

        joblib.dump(new_model,  "best_model.pkl")
        joblib.dump(new_scaler, "scaler.pkl")
        model, scaler = new_model, new_scaler

        return RetrainResponse(
            message="Model retrained and saved successfully.",
            rows_used=len(df),
            model=type(new_model).__name__,
        )
    except HTTPException:
        raise
    except Exception as e:
        raise HTTPException(status_code=500, detail=f"Retraining failed: {str(e)}")
