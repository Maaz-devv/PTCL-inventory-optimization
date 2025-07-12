# PTCL Inventory Forecasting & Optimization  🚚📈

This project presents a real-world, end-to-end inventory analysis and forecasting solution built for PTCL’s field operations. It integrates advanced analytics, machine learning, and interactive BI dashboards to tackle stockout risks, optimize safety stock, and improve demand responsiveness across regional warehouses.

---

## 🧠 Business Problem

PTCL’s field teams often face stockouts and overstocking of critical materials due to:
- Inconsistent demand patterns
- Unreliable stock transfer times
- Lack of real-time decision support

**Objective**: Build a robust, data-driven system to:
- Forecast future material demand at a plant level
- Calculate optimal safety stock & reorder points
- Visualize inventory performance dynamically
- Help reduce costs and improve service reliability

---

## 🧰 Tools & Stack Used (and Why)

| Tool          | Purpose & Impact |
|---------------|------------------|
| **Python (Pandas, NumPy, XGBoost)** | For ETL, feature engineering, forecasting models (incl. Croston, TSB, ML-based models) |
| **MySQL** | Stores cleaned & structured inventory data, serves as central query layer |
| **Power BI** | Builds interactive dashboards for plant-level decision-making |
| **Jupyter Notebooks** | Analysis experimentation, forecasting, backtesting logic |
| **ETL Pipeline (CSV → Python → MySQL)** | Automates data ingestion, transformation, and update cycle |

> 🔁 I built a custom ETL pipeline to clean raw CSV data, handle date formatting, deduplication, and transform it into analysis-ready structure, then load into MySQL for querying and Power BI use.

---

## 📦 End-to-End Workflow

1. **Raw Data Cleaning & Transformation**
   - Fix date formats, remove duplicates, filter invalid entries
   - Simulate ERP-style material movement and transit logic
2. **Load to MySQL**
   - Normalize tables (Sheet1, STO1 logic)
   - Generate calculated columns (lead time, entry/posting delays)
3. **Exploratory Data Analysis (EDA)**
   - Identify consumption trends, critical materials, seasonal behavior
4. **Forecasting Module**
   - Apply Croston, TSB, and XGBoost models for intermittent & spiky demand
   - Weekly forecasting with model evaluation (MAPE, MAE, RMSE)
5. **Inventory Control KPIs**
   - Compute:
     - Average daily demand
     - Safety stock (based on z-score & lead time)
     - Reorder points
     - Items below safety threshold
6. **Power BI Dashboard**
   - Unified slicers by plant/material
   - Visualize:
     - Actual vs Forecast consumption
     - Critical materials below safety
     - Recommended reorder signals
     - Weekly forecast vs safety & reorder thresholds

---

## 📊 Key Impact 

- 📉 Estimated **10–15% reduction** in material stockouts across plants
- 🕒 Better demand anticipation for 4-week rolling windows
- 🛠️ Field engineers get **proactive visibility** on when/what to reorder
- 🔄 Reduces excess stock holding and improves **inventory turnover**

---

## 📁 Files Breakdown

| File/Table | Description |
|------------|-------------|
| `forecast_croston.xlsx` | Weekly forecast data per plant/material (from Croston model) |
| `historical_inventory_stats.xlsx` | Historical demand, std dev, lead time, safety stock, reorder point |
| `forecast_inventory_control.xlsx` | Combined forecast-based inventory KPIs for critical items |
| Power BI Dashboard | Dynamic interface with filters, charts, KPI cards |

---

## 🔮 Future Improvements

- Add **live API integration** to pull daily stock/consumption data
- Introduce **ABC classification** for inventory prioritization
- Enhance model retraining pipeline for automation

---

## 🤝 Real-World Value

This project showcases how domain-driven analytics, forecasting, and dashboarding can empower large-scale operations like PTCL’s to:
- Reduce uncertainty
- Improve planning
- Drive operational efficiency
---
