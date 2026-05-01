from sqlalchemy import create_engine
from sqlalchemy.ext.declarative import declarative_base
from sqlalchemy.orm import sessionmaker
import os
from dotenv import load_dotenv

load_dotenv()
import boto3
import logging

logging.basicConfig(level=logging.INFO)
logger = logging.getLogger(__name__)
def get_db_password():
    param_path = os.getenv("SSM_DB_PASSWORD_PATH")
    region     = os.getenv("AWS_REGION", "us-east-1")

    if not param_path:
        raise ValueError("SSM_DB_PASSWORD_PATH environment variable is required")

    logger.info(f"Fetching password from SSM: {param_path}")

    client = boto3.client('ssm', region_name=region)
    response = client.get_parameter(
        Name=param_path,
        WithDecryption=True  
    )
    return response['Parameter']['Value']

# Database configuration (defaults can stay, but env vars will override)
DB_USER = os.getenv("DB_USER", "maissen")
DB_PASSWORD = os.getenv("DB_PASSWORD") 
DB_HOST = os.getenv("DB_HOST", "localhost")
DB_PORT = os.getenv("DB_PORT", "5432")          # ← changed default to 5432
DB_NAME = os.getenv("DB_NAME", "tododb")

# IMPORTANT: Changed to PostgreSQL + psycopg2 driver
SQLALCHEMY_DATABASE_URL = (
    f"postgresql+psycopg2://{DB_USER}:{DB_PASSWORD}@{DB_HOST}:{DB_PORT}/{DB_NAME}"
    "?sslmode=require"  # ← Add this! Forces SSL without needing a cert file
)

engine = create_engine(
    SQLALCHEMY_DATABASE_URL,
    pool_pre_ping=True,           # Good: helps detect broken connections
    pool_recycle=1800,            # Recycle connections every 30 min (RDS closes idle ones)
    pool_size=5,
    max_overflow=10
)

SessionLocal = sessionmaker(autocommit=False, autoflush=False, bind=engine)

Base = declarative_base()


# Dependency remains the same
def get_db():
    db = SessionLocal()
    try:
        yield db
    finally:
        db.close()