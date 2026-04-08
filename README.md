```markdown
# SaaS Freelancers Generate NDAs

[![Next.js](https://img.shields.io/badge/Next.js-13-blue?logo=next.js)](https://nextjs.org/)
[![FastAPI](https://img.shields.io/badge/FastAPI-0.95-green?logo=fastapi)](https://fastapi.tiangolo.com/)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](LICENSE)

A SaaS platform enabling freelancers to quickly generate Non-Disclosure Agreements (NDAs).

## Features

- Generate NDAs in PDF format
- Customizable templates
- User authentication
- Document history tracking
- Responsive web interface

## Quick Start

1. Clone the repo:
```bash
git clone https://github.com/your-repo/saas-freelancers-generate-ndas.git
```

2. Install dependencies:
```bash
cd saas-freelancers-generate-ndas
npm install  # Frontend
pip install -r requirements.txt  # Backend
```

## Environment Setup

Create `.env` files:

**Frontend (Next.js):**
```env
NEXT_PUBLIC_API_URL=http://localhost:8000
```

**Backend (FastAPI):**
```env
DATABASE_URL=sqlite:///./app.db
SECRET_KEY=your-secret-key
```

## Deployment

1. **Frontend:**
```bash
npm run build
npm start
```

2. **Backend:**
```bash
uvicorn main:app --reload
```

For production, use:
- Vercel/Netlify (Next.js)
- Docker/Heroku (FastAPI)

## License

MIT © 2023 Your Name
```