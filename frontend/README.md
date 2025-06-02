# E-commerce Frontend

Modern e-commerce frontend built with Next.js 14 App Router, featuring server-side rendering, client-side state management, and comprehensive TypeScript support.

## 🚀 Features

- **Next.js 14 App Router** - Latest routing system with layouts, loading UI, and error handling
- **Server Components** - Optimal performance with server-side rendering
- **TanStack Query** - Powerful data fetching and caching
- **Zustand** - Lightweight state management
- **TypeScript** - Full type safety
- **Tailwind CSS** - Utility-first styling
- **Radix UI** - Accessible component primitives
- **Framer Motion** - Smooth animations
- **NextAuth.js** - Authentication
- **React Hook Form + Zod** - Form validation
- **Prisma** - Database ORM

## 📦 Installation

```bash
npm install
```

## 🛠️ Development

```bash
npm run dev          # Start development server
npm run build        # Build for production
npm run start        # Start production server
npm run lint         # Run ESLint
npm run type-check   # Run TypeScript check
npm run db:generate  # Generate Prisma client
```

## 🏗️ Project Structure

```
src/
├── app/             # App Router pages and layouts
├── components/      # Reusable UI components
├── hooks/           # Custom React hooks
├── lib/             # Utility functions and configurations
├── services/        # API service functions
├── store/           # Zustand stores
└── types/           # TypeScript type definitions
```

## 🔧 Configuration

Copy `.env.local` and update with your values:

```bash
cp .env.local .env.local.example
```

## 🐳 Docker

```bash
docker build -t ecommerce-frontend .
docker run -p 3000:3000 ecommerce-frontend
```

## 📱 Features Implemented

- [ ] Authentication (Login/Register)
- [ ] Product Catalog
- [ ] Shopping Cart
- [ ] Order Management
- [ ] User Profile
- [ ] Search & Filters
- [ ] Responsive Design
- [ ] Dark Mode
- [ ] PWA Support
