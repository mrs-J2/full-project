from pydantic import BaseModel, Field
from typing import Optional, List
from datetime import datetime


class UserCreate(BaseModel):
    username: str = Field(..., min_length=3, max_length=255)
    password: str = Field(..., min_length=6)


class UserLogin(BaseModel):
    username: str
    password: str


class UserResponse(BaseModel):
    id: str
    username: str
    token: str


class TodoCreate(BaseModel):
    title: str = Field(..., min_length=1, max_length=255)
    description: Optional[str] = None


class TodoUpdate(BaseModel):
    title: Optional[str] = Field(None, min_length=1, max_length=255)
    description: Optional[str] = None
    completed: Optional[bool] = None


class TodoResponse(BaseModel):
    id: str
    title: str
    description: Optional[str]
    completed: bool
    createdAt: datetime
    updatedAt: Optional[datetime] = None
    
    class Config:
        orm_mode = True
        from_attributes = True
    
    @classmethod
    def from_orm(cls, obj):
        return cls(
            id=obj.id,
            title=obj.title,
            description=obj.description,
            completed=obj.completed,
            createdAt=obj.created_at,
            updatedAt=obj.updated_at
        )


class TodoListResponse(BaseModel):
    todos: List[TodoResponse]
    total: int
