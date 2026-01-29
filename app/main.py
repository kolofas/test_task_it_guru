from fastapi import FastAPI
from app.routers.orders import router as orders_router


app = FastAPI(title="Test Task")

@app.get("/health")
async def health():
    return {"status": "ok"}

app.include_router(orders_router)