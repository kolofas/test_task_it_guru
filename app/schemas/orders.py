from pydantic import BaseModel, Field


class AddItemRequest(BaseModel):
    product_id: int
    qty: int = Field(gt=0)


class OrderItemResponse(BaseModel):
    order_id: int
    product_id: int
    qty: int
