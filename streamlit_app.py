import streamlit as st
import requests
import json
from datetime import datetime
import pandas as pd
import plotly.graph_objects as go
from PIL import Image
import io

# Page config
st.set_page_config(
    page_title="DiaRisk AI - Diabetes Prediction",
    page_icon="🏥",
    layout="wide",
    initial_sidebar_state="expanded"
)

# Custom CSS for professional styling
st.markdown("""
    <style>
    .main {
        padding-top: 0rem;
    }
    .stTabs [data-baseweb="tab-list"] button {
        font-weight: 600;
    }
    </style>
    """, unsafe_allow_html=True)

# Initialize session state
if 'chat_history' not in st.session_state:
    st.session_state.chat_history = []
if 'auth_token' not in st.session_state:
    st.session_state.auth_token = "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ1c2VySWQiOjEsInVzZXJuYW1lIjoic3RyZWFtbGl0dXNlciIsImlhdCI6MTczNzI0NTEyMX0.demo_token"

# Header
st.markdown("# 🏥 DiaRisk AI - Diabetes Risk Prediction Platform")
st.markdown("*Advanced AI-powered diabetes risk assessment and health management*")
st.divider()

# Sidebar navigation
with st.sidebar:
    st.markdown("### Navigation")
    page = st.radio(
        "Select a feature:",
        ["Risk Prediction", "AI Health Assistant", "Food Scanner", "Health Calculators", "Education"]
    )
    
    st.divider()
    st.markdown("### About")
    st.info(
        "🎯 **DiaRisk AI** is a comprehensive platform for diabetes prevention and management.\n\n"
        "✨ Features:\n"
        "- ML-based risk assessment\n"
        "- AI health assistant\n"
        "- Food nutritition scanner\n"
        "- Health calculators\n"
        "- Educational resources"
    )

# =================== RISK PREDICTION PAGE ===================
if page == "Risk Prediction":
    st.markdown("## AI Risk Prediction")
    st.markdown("Enter your health parameters to get an AI-powered diabetes risk assessment")
    
    col1, col2 = st.columns(2)
    
    with col1:
        pregnancies = st.number_input("Pregnancies", min_value=0, max_value=20, value=2)
        glucose = st.number_input("Glucose (mg/dL)", min_value=0, max_value=300, value=120)
        blood_pressure = st.number_input("Blood Pressure (mmHg)", min_value=0, max_value=200, value=70)
        skin_thickness = st.number_input("Skin Thickness (mm)", min_value=0, max_value=100, value=20)
    
    with col2:
        insulin = st.number_input("Insulin (mU/ml)", min_value=0, max_value=900, value=80)
        bmi = st.number_input("BMI (kg/m²)", min_value=10.0, max_value=60.0, value=25.5)
        diabetes_pedigree = st.number_input("Diabetes Pedigree Function", min_value=0.0, max_value=2.5, value=0.5)
        age = st.number_input("Age (years)", min_value=18, max_value=120, value=30)
    
    if st.button("🔮 Predict Risk", key="predict_btn", use_container_width=True):
        try:
            prediction_data = {
                "Pregnancies": pregnancies,
                "Glucose": glucose,
                "BloodPressure": blood_pressure,
                "SkinThickness": skin_thickness,
                "Insulin": insulin,
                "BMI": bmi,
                "DiabetesPedigreeFunction": diabetes_pedigree,
                "Age": age
            }
            
            response = requests.post(
                "http://localhost:5000/predict",
                json=prediction_data,
                timeout=5
            )
            
            if response.status_code == 200:
                result = response.json()
                
                col1, col2, col3 = st.columns(3)
                
                with col1:
                    st.metric("Prediction", result.get("prediction", "N/A"))
                
                with col2:
                    prob = result.get("probability", 0) * 100
                    st.metric("Risk Probability", f"{prob:.1f}%")
                
                with col3:
                    risk_level = "🔴 High" if prob >= 70 else "🟡 Medium" if prob >= 40 else "🟢 Low"
                    st.metric("Risk Level", risk_level)
                
                st.divider()
                
                # Display recommendations
                if result.get("prediction") == "Diabetic":
                    st.warning("⚠️ Based on the analysis, you have elevated diabetes risk. Please consult with a healthcare professional.")
                    st.markdown("**Recommended Actions:**")
                    st.markdown("""
                    - Schedule a consultation with an endocrinologist
                    - Monitor your glucose levels regularly
                    - Adopt a balanced, low-sugar diet
                    - Increase physical activity (150+ min/week)
                    - Maintain a healthy weight
                    """)
                else:
                    st.success("✅ Your diabetes risk is relatively low. Continue maintaining healthy habits!")
                    st.markdown("**Preventive Measures:**")
                    st.markdown("""
                    - Maintain regular exercise routine
                    - Keep a balanced diet
                    - Monitor your BMI
                    - Schedule annual health checkups
                    - Manage stress levels
                    """)
            else:
                st.error("Error getting prediction. Please try again.")
        except Exception as e:
            st.error(f"Connection error: {str(e)}")
            st.info("💡 Make sure the Python prediction service is running on port 5000.")

# =================== AI HEALTH ASSISTANT PAGE ===================
elif page == "AI Health Assistant":
    st.markdown("## 🤖 AI Health Assistant")
    st.markdown("Chat with our AI powered by Google Gemini. Get answers to your health questions 24/7.")
    
    # Display chat history
    for message in st.session_state.chat_history:
        with st.chat_message(message["role"]):
            st.markdown(message["content"])
    
    # Chat input
    user_input = st.chat_input("Ask a health-related question...")
    
    if user_input:
        st.session_state.chat_history.append({"role": "user", "content": user_input})
        
        with st.chat_message("user"):
            st.markdown(user_input)
        
        try:
            response = requests.post(
                "http://localhost:3000/api/chat",
                json={
                    "sessionId": "streamlit-session",
                    "message": user_input
                },
                headers={
                    "Authorization": f"Bearer {st.session_state.auth_token}",
                    "Content-Type": "application/json"
                },
                timeout=10
            )
            
            if response.status_code == 200:
                result = response.json()
                assistant_message = result.get("response", "I couldn't generate a response. Please try again.")
                st.session_state.chat_history.append({"role": "assistant", "content": assistant_message})
                
                with st.chat_message("assistant"):
                    st.markdown(assistant_message)
            else:
                st.error("Error communicating with AI. Please try again.")
        except Exception as e:
            st.error(f"Connection error: {str(e)}")
            st.info("💡 Make sure the backend server is running on port 3000.")

# =================== FOOD SCANNER PAGE ===================
elif page == "Food Scanner":
    st.markdown("## 📸 Food Scanner")
    st.markdown("Upload a food image to get instant nutrition information")
    
    uploaded_file = st.file_uploader("Choose a food image", type=["jpg", "jpeg", "png"])
    
    if uploaded_file is not None:
        col1, col2 = st.columns([1, 1])
        
        with col1:
            image = Image.open(uploaded_file)
            st.image(image, caption="Uploaded Image", use_column_width=True)
        
        if st.button("📊 Analyze Nutrition", key="food_btn", use_container_width=True):
            try:
                # Send image to backend
                files = {'file': uploaded_file.getvalue()}
                response = requests.post(
                    "http://localhost:3000/api/food-scanner/analyze",
                    files=files,
                    headers={"Authorization": f"Bearer {st.session_state.auth_token}"},
                    timeout=10
                )
                
                if response.status_code == 200:
                    nutrition = response.json()
                    
                    with col2:
                        st.markdown("### Nutrition Facts")
                        st.metric("Calories", f"{nutrition.get('calories', 0):.0f} kcal")
                        st.metric("Protein", f"{nutrition.get('protein', 0):.1f}g")
                        st.metric("Carbs", f"{nutrition.get('carbs', 0):.1f}g")
                        st.metric("Fat", f"{nutrition.get('fat', 0):.1f}g")
                    
                    st.divider()
                    st.markdown("### Detailed Breakdown")
                    
                    df = pd.DataFrame({
                        'Nutrient': ['Calories', 'Protein', 'Carbs', 'Fat', 'Fiber', 'Sugar'],
                        'Amount': [
                            nutrition.get('calories', 0),
                            nutrition.get('protein', 0),
                            nutrition.get('carbs', 0),
                            nutrition.get('fat', 0),
                            nutrition.get('fiber', 0),
                            nutrition.get('sugar', 0)
                        ]
                    })
                    
                    st.dataframe(df, use_container_width=True)
                else:
                    st.error("Error analyzing image. Please try again.")
            except Exception as e:
                st.error(f"Connection error: {str(e)}")

# =================== HEALTH CALCULATORS PAGE ===================
elif page == "Health Calculators":
    st.markdown("## 🧮 Health Calculators")
    st.markdown("Use our collection of health calculators for better health insights")
    
    calc_tab1, calc_tab2, calc_tab3, calc_tab4 = st.tabs(["BMI Calculator", "Calorie Calculator", "Daily Risk", "Sugar Tracker"])
    
    # BMI Calculator
    with calc_tab1:
        st.subheader("BMI Calculator")
        col1, col2 = st.columns(2)
        
        with col1:
            height = st.number_input("Height (cm)", min_value=100, max_value=250, value=170)
        with col2:
            weight = st.number_input("Weight (kg)", min_value=30, max_value=200, value=70)
        
        if st.button("Calculate BMI", key="bmi_btn", use_container_width=True):
            bmi = weight / ((height / 100) ** 2)
            
            if bmi < 18.5:
                category = "🔵 Underweight"
            elif bmi < 25:
                category = "🟢 Normal Weight"
            elif bmi < 30:
                category = "🟡 Overweight"
            else:
                category = "🔴 Obese"
            
            col1, col2, col3 = st.columns(3)
            with col1:
                st.metric("Your BMI", f"{bmi:.1f}")
            with col2:
                st.metric("Category", category)
            with col3:
                st.info(f"BMI Range: 18.5 - 24.9")
    
    # Calorie Calculator
    with calc_tab2:
        st.subheader("Calorie & TDEE Calculator")
        
        col1, col2 = st.columns(2)
        with col1:
            age = st.number_input("Age", min_value=18, max_value=100, value=30, key="calorie_age")
            weight = st.number_input("Weight (kg)", min_value=30, max_value=200, value=70, key="calorie_weight")
            height = st.number_input("Height (cm)", min_value=100, max_value=250, value=170, key="calorie_height")
        
        with col2:
            gender = st.selectbox("Gender", ["Male", "Female"])
            activity = st.selectbox("Activity Level", 
                ["Sedentary", "Lightly Active", "Moderately Active", "Very Active"])
        
        if st.button("Calculate TDEE", key="calorie_btn", use_container_width=True):
            if gender == "Male":
                bmr = 88.362 + (13.397 * weight) + (4.799 * height) - (5.677 * age)
            else:
                bmr = 447.593 + (9.247 * weight) + (3.098 * height) - (4.330 * age)
            
            activity_multipliers = {
                "Sedentary": 1.2,
                "Lightly Active": 1.375,
                "Moderately Active": 1.55,
                "Very Active": 1.725
            }
            
            tdee = bmr * activity_multipliers[activity]
            
            st.metric("Daily Calorie Needs (TDEE)", f"{tdee:.0f} kcal/day")
            st.metric("BMR", f"{bmr:.0f} kcal/day")
    
    # Daily Risk Calculator
    with calc_tab3:
        st.subheader("Daily Risk Assessment")
        
        col1, col2 = st.columns(2)
        with col1:
            sleep = st.slider("Hours of Sleep", 0, 12, 7, key="sleep")
            exercise = st.slider("Minutes of Exercise", 0, 180, 30, key="exercise")
        with col2:
            water = st.slider("Glasses of Water", 0, 12, 8, key="water")
            stress = st.slider("Stress Level (1-10)", 1, 10, 5, key="stress")
        
        sugar = st.slider("Grams of Added Sugar", 0, 200, 25, key="sugar")
        
        if st.button("Assess Daily Risk", key="daily_risk_btn", use_container_width=True):
            risk_score = 0
            reasons = []
            
            if sleep < 6:
                risk_score += 15
                reasons.append("❌ Insufficient sleep")
            else:
                reasons.append("✅ Good sleep")
            
            if exercise < 30:
                risk_score += 10
                reasons.append("❌ Low exercise")
            else:
                reasons.append("✅ Good exercise")
            
            if water < 6:
                risk_score += 10
                reasons.append("❌ Low water intake")
            else:
                reasons.append("✅ Good hydration")
            
            if sugar > 50:
                risk_score += 15
                reasons.append("❌ High sugar intake")
            else:
                reasons.append("✅ Good sugar control")
            
            if stress > 7:
                risk_score += 10
                reasons.append("❌ High stress")
            else:
                reasons.append("✅ Good stress management")
            
            col1, col2 = st.columns(2)
            with col1:
                st.metric("Daily Risk Score", f"{risk_score}%")
            with col2:
                if risk_score < 25:
                    st.success("🟢 Low Risk - Keep up the good habits!")
                elif risk_score < 50:
                    st.info("🟡 Moderate Risk - Room for improvement")
                else:
                    st.warning("🔴 High Risk - Make some lifestyle changes")
            
            st.markdown("### Breakdown:")
            for reason in reasons:
                st.markdown(f"- {reason}")
    
    # Sugar Tracker
    with calc_tab4:
        st.subheader("Daily Sugar Intake Tracker")
        
        st.markdown("**Recommended Daily Sugar Limit:**")
        st.info("Men: 36g | Women: 25g | Children: 12-25g")
        
        col1, col2 = st.columns(2)
        with col1:
            breakfast_sugar = st.number_input("Breakfast Sugar (g)", min_value=0, max_value=100, value=10)
            lunch_sugar = st.number_input("Lunch Sugar (g)", min_value=0, max_value=100, value=15)
        with col2:
            dinner_sugar = st.number_input("Dinner Sugar (g)", min_value=0, max_value=100, value=10)
            snacks_sugar = st.number_input("Snacks Sugar (g)", min_value=0, max_value=100, value=5)
        
        total_sugar = breakfast_sugar + lunch_sugar + dinner_sugar + snacks_sugar
        
        col1, col2, col3 = st.columns(3)
        with col1:
            st.metric("Total Sugar Today", f"{total_sugar}g")
        with col2:
            st.metric("Recommended", "36g (male)")
        with col3:
            status = "✅ Within" if total_sugar <= 36 else "⚠️ Exceeded"
            st.metric("Status", status)

# =================== EDUCATION PAGE ===================
elif page == "Education":
    st.markdown("## 📚 Educational Resources")
    st.markdown("Learn about diabetes, prevention, and healthy lifestyle management")
    
    edu_tab1, edu_tab2, edu_tab3, edu_tab4, edu_tab5 = st.tabs([
        "What is Diabetes?",
        "Symptoms & Signs",
        "Prevention Methods",
        "Diet Guidelines",
        "Exercise Tips"
    ])
    
    with edu_tab1:
        st.subheader("What is Diabetes?")
        st.markdown("""
        Diabetes is a metabolic disorder characterized by high blood sugar levels. 
        The body either doesn't produce enough insulin or can't use insulin effectively.
        
        **Types of Diabetes:**
        1. **Type 1**: Autoimmune condition where the pancreas doesn't produce insulin
        2. **Type 2**: Most common; body becomes resistant to insulin
        3. **Gestational**: Develops during pregnancy; usually resolves after birth
        
        **Stats:**
        - 422 million people worldwide have diabetes
        - 1.5 million deaths directly caused by diabetes annually
        - Complications include heart disease, stroke, kidney failure, blindness
        """)
    
    with edu_tab2:
        st.subheader("Symptoms & Warning Signs")
        st.markdown("""
        **Early Warning Signs:**
        - Increased thirst
        - Frequent urination
        - Fatigue and weakness
        - Blurred vision
        - Numbness or tingling in extremities
        - Unexplained weight loss
        - Slow-healing cuts or sores
        - Dark patches on skin
        
        **When to See a Doctor:**
        If you experience any of these symptoms, consult a healthcare provider for testing.
        Early detection can prevent complications.
        """)
    
    with edu_tab3:
        st.subheader("Diabetes Prevention Methods")
        st.markdown("""
        **Lifestyle Changes:**
        1. **Weight Management**: Lose 5-10% of body weight if overweight
        2. **Physical Activity**: 150 minutes of moderate exercise per week
        3. **Healthy Diet**: Reduce refined carbs, increase fiber intake
        4. **Stress Management**: Practice meditation, yoga, or relaxation
        5. **Sleep**: Get 7-9 hours of quality sleep daily
        6. **Avoid Smoking**: Quit smoking to reduce risk
        7. **Moderate Alcohol**: Limit alcohol consumption
        
        **Regular Monitoring:**
        - Get blood glucose tested annually
        - Monitor blood pressure
        - Check cholesterol levels
        - Have regular health checkups
        """)
    
    with edu_tab4:
        st.subheader("Diet Guidelines for Diabetes Prevention")
        st.markdown("""
        **Foods to Eat:**
        ✅ Whole grains and fiber-rich foods
        ✅ Lean proteins (chicken, fish, legumes)
        ✅ Non-starchy vegetables (broccoli, spinach, peppers)
        ✅ Healthy fats (nuts, olive oil, avocados)
        ✅ Low-sugar fruits (berries, apples)
        
        **Foods to Avoid:**
        ❌ Sugary drinks and sodas
        ❌ Refined carbohydrates (white bread, pastries)
        ❌ Processed foods high in sodium
        ❌ Red and processed meats
        ❌ Sweets and desserts
        ❌ Alcohol (excessive consumption)
        
        **Meal Planning Tips:**
        - Eat smaller, frequent meals
        - Balance carbs, proteins, and fats
        - Control portion sizes
        - Reduce added sugars
        - Stay hydrated with water
        """)
    
    with edu_tab5:
        st.subheader("Exercise Tips for Diabetes Prevention")
        st.markdown("""
        **Exercise Types:**
        
        1. **Cardiovascular Exercise** (150 min/week)
           - Brisk walking, jogging, cycling, swimming
           - Improves heart health and insulin sensitivity
        
        2. **Resistance Training** (2-3 times/week)
           - Weight lifting, bodyweight exercises
           - Builds muscle mass, improves glucose metabolism
        
        3. **Flexibility and Balance** (daily)
           - Yoga, stretching, tai chi
           - Reduces stress and improves mobility
        
        **Getting Started:**
        - Start slowly and gradually increase intensity
        - Aim for consistency over intensity
        - Find activities you enjoy
        - Exercise with a friend for motivation
        - Check with doctor before starting new exercise
        
        **Benefits:**
        ✅ Lowers blood sugar levels
        ✅ Improves insulin sensitivity
        ✅ Helps weight management
        ✅ Reduces cardiovascular risk
        ✅ Improves mental health
        """)

# Footer
st.divider()
st.markdown("""
    <div style='text-align: center; color: #666; padding: 20px;'>
        <p>© 2026 DiaRisk AI | Advanced Diabetes Risk Prediction Platform</p>
        <p>⚕️ For educational and informational purposes only. Not a substitute for professional medical advice.</p>
    </div>
    """, unsafe_allow_html=True)
