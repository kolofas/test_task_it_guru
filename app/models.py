from datetime import datetime
from decimal import Decimal
from typing import List

from sqlalchemy import (
    ForeignKey,
    Integer,
    Numeric,
    String,
    Text,
    DateTime, CheckConstraint,
)
from sqlalchemy.orm import Mapped, mapped_column, relationship

from app.db.base import Base


class Category(Base):
    __tablename__ = "categories"

    id: Mapped[int] = mapped_column(primary_key=True)
    name: Mapped[str] = mapped_column(String(255), nullable=False)
    parent_id: Mapped[int | None] = mapped_column(ForeignKey("categories.id"), index=True, nullable=True)

    parent: Mapped["Category | None"] = relationship(
        "Category", remote_side="Category.id", back_populates="children"
    )
    children: Mapped[list["Category"]] = relationship("Category", back_populates="parent")


class Product(Base):
    __tablename__ = "products"
    __table_args__ = (
        CheckConstraint("qty >= 0", name="ck_products_qty_non_negative"),
    )


    id: Mapped[int] = mapped_column(primary_key=True)
    name: Mapped[str] = mapped_column(String(255), nullable=False)
    qty: Mapped[int] = mapped_column(Integer, nullable=False, default=0)
    price: Mapped[Decimal] = mapped_column(Numeric(12, 2), nullable=False)
    category_id: Mapped[int] = mapped_column(ForeignKey("categories.id"), index=True, nullable=False)

    category: Mapped[Category] = relationship()

    order_items: Mapped[List["OrderItem"]] = relationship(
        "OrderItem",
        back_populates="product",
    )

class Customer(Base):
    __tablename__ = "customers"

    id: Mapped[int] = mapped_column(primary_key=True)
    name: Mapped[str] = mapped_column(String(255), nullable=False)
    address: Mapped[str] = mapped_column(Text, nullable=False)


class Order(Base):
    __tablename__ = "orders"

    id: Mapped[int] = mapped_column(primary_key=True)
    customer_id: Mapped[int] = mapped_column(ForeignKey("customers.id"), index=True, nullable=False)
    created_at: Mapped[datetime] = mapped_column(DateTime(timezone=True), index=True, default=datetime.utcnow, nullable=False)

    customer: Mapped[Customer] = relationship()

    items: Mapped[List["OrderItem"]] = relationship(
        "OrderItem",
        back_populates="order",
        cascade="all, delete-orphan",
    )


class OrderItem(Base):
    __tablename__ = "order_items"
    __table_args__ = (
        CheckConstraint("qty > 0", name="ck_order_items_qty_positive"),
    )

    order_id: Mapped[int] = mapped_column(ForeignKey("orders.id"), primary_key=True)
    product_id: Mapped[int] = mapped_column(ForeignKey("products.id"), primary_key=True, index=True)
    qty: Mapped[int] = mapped_column(Integer, nullable=False)

    order: Mapped["Order"] = relationship(
        "Order",
        back_populates="items",
    )
    product: Mapped["Product"] = relationship(
        "Product",
        back_populates="order_items",
    )
