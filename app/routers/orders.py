from fastapi import APIRouter, Depends
from sqlalchemy.ext.asyncio import AsyncSession

from app.db.session import get_db
from app.schemas.orders import AddItemRequest, OrderItemResponse
from app.services.orders import add_product_to_order

router = APIRouter(prefix="/orders", tags=["orders"])


@router.post("/{order_id}/items", response_model=OrderItemResponse)
async def add_item_to_order(
    order_id: int,
    payload: AddItemRequest,
    db: AsyncSession = Depends(get_db),
) -> OrderItemResponse:
    item = await add_product_to_order(
        db=db,
        order_id=order_id,
        product_id=payload.product_id,
        qty=payload.qty,
    )
    return OrderItemResponse(
        order_id=item.order_id,
        product_id=item.product_id,
        qty=item.qty,
    )
