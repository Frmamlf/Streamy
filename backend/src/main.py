from fastapi import FastAPI, HTTPException
from fastapi.middleware.cors import CORSMiddleware
from pydantic import BaseModel
from typing import List, Optional, Dict, Any

app = FastAPI(title="Streamy API", description="Backend API for Streamy streaming app")

# Add CORS middleware
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],  # For development; restrict in production
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

# Define data models
class MediaSource(BaseModel):
    name: str
    url: str
    quality: str
    size: Optional[str] = None

class MediaItem(BaseModel):
    id: str
    title: str
    thumbnail: Optional[str] = None
    description: Optional[str] = None
    sources: List[MediaSource] = []
    metadata: Dict[str, Any] = {}

# Sample data - to be replaced with proper implementation
SAMPLE_MEDIA = [
    MediaItem(
        id="movie1",
        title="Sample Movie 1",
        thumbnail="https://example.com/sample1.jpg",
        description="This is a sample movie",
        sources=[
            MediaSource(name="Source 1", url="https://example.com/movie1.mp4", quality="720p")
        ],
        metadata={"year": "2023", "genre": "Action"}
    ),
    MediaItem(
        id="movie2",
        title="Sample Movie 2",
        thumbnail="https://example.com/sample2.jpg",
        description="This is another sample movie",
        sources=[
            MediaSource(name="Source 1", url="https://example.com/movie2.mp4", quality="1080p")
        ],
        metadata={"year": "2024", "genre": "Comedy"}
    )
]

@app.get("/")
async def root():
    return {"message": "Welcome to Streamy API"}

@app.get("/media", response_model=List[MediaItem])
async def get_media():
    return SAMPLE_MEDIA

@app.get("/media/{media_id}", response_model=MediaItem)
async def get_media_by_id(media_id: str):
    for media in SAMPLE_MEDIA:
        if media.id == media_id:
            return media
    raise HTTPException(status_code=404, detail="Media not found")

@app.get("/search/{query}", response_model=List[MediaItem])
async def search_media(query: str):
    # Simple search implementation - replace with proper search in the future
    results = []
    query = query.lower()
    for media in SAMPLE_MEDIA:
        if query in media.title.lower() or (media.description and query in media.description.lower()):
            results.append(media)
    return results
