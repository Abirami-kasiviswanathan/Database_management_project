from faker import Faker
import pandas as pd
import random
from sqlalchemy import create_engine

fake = Faker('en_IN')
random.seed(42)  # keeps data consistent every time you run

departments = ['Finance', 'HR', 'IT', 'Operations', 'Legal']
roles       = ['Analyst', 'Senior Analyst', 'Manager', 'Coordinator']
skills      = ['Excel', 'SQL', 'Python', 'Power BI', 'SAP',
               'Communication', 'Project Management', 'Data Modeling']


# table for employee_skills

rows = []
for emp_id in range(1, 501):
    dept = random.choice(departments)
    role = random.choice(roles)
    name = fake.name()
    for skill in random.sample(skills, k=random.randint(2, 5)):
        rows.append({
            'employee_id'   : emp_id,
            'employee_name' : name,
            'department'    : dept,
            'role'          : role,
            'skill_name'    : skill,
            'proficiency'   : random.randint(1, 5)
        })

df_employee_skills = pd.DataFrame(rows)
print(df_employee_skills.head(5))

#job_compentency table
job_competencies = []
for role in roles:
    for skill in random.sample(skills, k=5):
        job_competencies.append({
            'role_name'     : role,
            'skill_name'    : skill,
            'required_level': random.randint(2, 5)
        })

df_job_competencies = pd.DataFrame(job_competencies)
print(df_job_competencies.head(5))

#learning path table
courses = [
    ('Excel',              'Excel Mastery',               20, 30,  'Coursera'),
    ('SQL',                'SQL for Analysts',            25, 40,  'Udemy'),
    ('Python',             'Python for Data Science',     40, 50,  'Coursera'),
    ('Power BI',           'Power BI Essentials',         15, 35,  'LinkedIn Learning'),
    ('SAP',                'SAP Fundamentals',            30, 80,  'SAP Learning Hub'),
    ('Communication',      'Business Communication',      10, 20,  'Coursera'),
    ('Project Management', 'PMP Prep Course',             45, 100, 'PMI'),
    ('Data Modeling',      'Data Modeling Fundamentals',  20, 45,  'Udemy'),
]

df_paths = pd.DataFrame(courses, columns=[
    'skill_name', 'course_name', 'duration_hours', 'cost_usd', 'provider'
])
print(df_paths.head(5))

#save files
df_employee_skills.to_csv('employee_skills.csv',    index=False)
df_job_competencies.to_csv('job_competencies.csv', index=False)
df_paths.to_csv('learning_paths.csv',      index=False)



#importing data to postgress
import psycopg2
from sqlalchemy import create_engine

engine = create_engine(
    "postgresql+psycopg2://abiramikasiviswanathan@localhost:5432/skill_gap"
)
df_employee_skills.to_sql('employee_skills',    engine, if_exists='append', index=False)
df_job_competencies.to_sql('job_competencies', engine, if_exists='append', index=False)
df_paths.to_sql('learning_paths',      engine, if_exists='append', index=False)
