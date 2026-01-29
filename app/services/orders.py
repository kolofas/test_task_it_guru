from __future__ import annotations

from fastapi import HTTPException, status
from sqlalchemy import select, update
from sqlalchemy.ext.asyncio import AsyncSession

from app.models import Order, OrderItem, Product


async def _get_order_or_404(db: AsyncSession, order_id: int) -> Order:
    order = await db.scalar(select(Order).where(Order.id == order_id))
    if not order:
        raise HTTPException(status_code=404, detail="Order not found")
    return order


async def _lock_product_or_404(db: AsyncSession, product_id: int) -> Product:
    product = await db.scalar(
        select(Product)
        .where(Product.id == product_id)
        .with_for_update()
    )
    if not product:
        raise HTTPException(status_code=404, detail="Product not found")
    return product


def _ensure_stock_or_409(product: Product, qty: int) -> None:
    if product.qty < qty:
        raise HTTPException(
            status_code=status.HTTP_409_CONFLICT,
            detail="Not enough product in stock",
        )


async def _upsert_order_item(
    db: AsyncSession,
    *,
    order_id: int,
    product_id: int,
    qty: int,
) -> OrderItem:
    res = await db.execute(
        update(OrderItem)
        .where(
            OrderItem.order_id == order_id,
            OrderItem.product_id == product_id,
        )
        .values(qty=OrderItem.qty + qty)
        .returning(OrderItem)
    )
    item = res.scalar_one_or_none()
    if item:
        return item


    item = OrderItem(order_id=order_id, product_id=product_id, qty=qty)
    db.add(item)
    return item


def _decrease_stock(product: Product, qty: int) -> None:
    product.qty -= qty


async def add_product_to_order(
    *,
    db: AsyncSession,
    order_id: int,
    product_id: int,
    qty: int,
) -> OrderItem:
    async with db.begin():
        await _get_order_or_404(db, order_id)

        product = await _lock_product_or_404(db, product_id)
        _ensure_stock_or_409(product, qty)

        item = await _upsert_order_item(
            db,
            order_id=order_id,
            product_id=product_id,
            qty=qty,
        )

        _decrease_stock(product, qty)

    await db.refresh(item)
    return item