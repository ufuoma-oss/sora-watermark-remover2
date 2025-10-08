import os
from sqlalchemy import create_engine
from sqlalchemy.ext.declarative import declarative_base
from sqlalchemy.orm import sessionmaker
from dotenv import load_dotenv

load_dotenv()

if os.path.exists("/secrets/db-password"):
    with open("/secrets/db-password", "r") as f:
        DATABASE_URL = f.read().strip()
else:
    DATABASE_URL = os.getenv("DATABASE_URL", "postgresql://user:password@localhost/sora_watermark_remover")

engine = create_engine(DATABASE_URL) if DATABASE_URL else None
SessionLocal = sessionmaker(autocommit=False, autoflush=False, bind=engine) if engine else None
Base = declarative_base()

def get_db():
    db = SessionLocal()
    try:
        yield db
    finally:
        db.close()
