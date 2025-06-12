#!/bin/bash

# Check if a folder name is provided
if [ -z "$1" ]; then
    echo "Usage: $0 <folder_name>"
    exit 1
fi

# Set the folder name and module name, adding an 's' to the folder name
FOLDER_NAME="src/${1}s"
MODULE_NAME="$1"

# Capitalize the first letter of the module name
CAPITALIZED_MODULE_NAME="$(echo "$MODULE_NAME" | awk '{print toupper(substr($0, 1, 1)) tolower(substr($0, 2))}')"

# Convert the module name to lowercase for __tablename__
LOWER_MODULE_NAME="$(echo "$MODULE_NAME" | tr '[:upper:]' '[:lower:]')"

# Create the folder
if [ -d "$FOLDER_NAME" ]; then
    echo "Folder '$FOLDER_NAME' already exists!"
    exit 1
fi

mkdir -p "$FOLDER_NAME"
echo "Created folder: $FOLDER_NAME"

# Create router.py
ROUTER_FILE="$FOLDER_NAME/router.py"
cat <<EOL > "$ROUTER_FILE"
from fastapi import APIRouter

${MODULE_NAME}_router = APIRouter()


# Define your routes here
@${MODULE_NAME}_router.get("/")
async def example_route():
    return {"message": "Hello from ${MODULE_NAME} router"}
EOL
echo "Created file: $ROUTER_FILE"

# Create schemas.py
SCHEMAS_FILE="$FOLDER_NAME/schemas.py"
cat <<EOL > "$SCHEMAS_FILE"
from pydantic import BaseModel


class ${CAPITALIZED_MODULE_NAME}Create(BaseModel):
    pass


class ${CAPITALIZED_MODULE_NAME}Update(BaseModel):
    pass


class ${CAPITALIZED_MODULE_NAME}Response(BaseModel):
    pass
EOL
echo "Created file: $SCHEMAS_FILE"

# Create models.py
MODELS_FILE="$FOLDER_NAME/models.py"
cat <<EOL > "$MODELS_FILE"
from sqlalchemy import Column, Integer, String
from sqlalchemy.ext.declarative import declarative_base

Base = declarative_base()


class ${CAPITALIZED_MODULE_NAME}(Base):
    __tablename__ = "${LOWER_MODULE_NAME}s"

    id = Column(Integer, primary_key=True, index=True)
    name = Column(String, nullable=False)

    # Add other fields here
EOL
echo "Created file: $MODELS_FILE"

# Create service.py
SERVICE_FILE="$FOLDER_NAME/service.py"
cat <<EOL > "$SERVICE_FILE"
class ${CAPITALIZED_MODULE_NAME}Service:
    pass
EOL
echo "Created file: $SERVICE_FILE"

# Final confirmation
echo "Module '$MODULE_NAME' created successfully!"
