// Global state management for microfrontends
import { create } from 'zustand'
import { persist, createJSONStorage } from 'zustand/middleware'

// Global state interface
interface GlobalState {
  // User state
  user: {
    isAuthenticated: boolean
    profile: any | null
    preferences: Record<string, any>
  }
  
  // Cart state
  cart: {
    items: any[]
    total: number
    currency: string
  }
  
  // UI state
  ui: {
    theme: 'light' | 'dark' | 'system'
    sidebarOpen: boolean
    notifications: any[]
  }
  
  // Actions
  setUser: (user: any) => void
  logout: () => void
  addToCart: (item: any) => void
  removeFromCart: (itemId: string) => void
  clearCart: () => void
  setTheme: (theme: 'light' | 'dark' | 'system') => void
  setSidebarOpen: (open: boolean) => void
  addNotification: (notification: any) => void
  removeNotification: (id: string) => void
}

export const useGlobalStore = create<GlobalState>()(
  persist(
    (set, get) => ({
      // Initial state
      user: {
        isAuthenticated: false,
        profile: null,
        preferences: {}
      },
      cart: {
        items: [],
        total: 0,
        currency: 'USD'
      },
      ui: {
        theme: 'system',
        sidebarOpen: false,
        notifications: []
      },
      
      // User actions
      setUser: (user) => set((state) => ({
        user: { ...state.user, ...user, isAuthenticated: true }
      })),
      
      logout: () => set((state) => ({
        user: { isAuthenticated: false, profile: null, preferences: {} },
        cart: { items: [], total: 0, currency: state.cart.currency }
      })),
      
      // Cart actions
      addToCart: (item) => set((state) => {
        const existingItem = state.cart.items.find(i => i.id === item.id)
        let newItems
        
        if (existingItem) {
          newItems = state.cart.items.map(i => 
            i.id === item.id ? { ...i, quantity: i.quantity + 1 } : i
          )
        } else {
          newItems = [...state.cart.items, { ...item, quantity: 1 }]
        }
        
        const total = newItems.reduce((sum, i) => sum + (i.price * i.quantity), 0)
        
        return {
          cart: { ...state.cart, items: newItems, total }
        }
      }),
      
      removeFromCart: (itemId) => set((state) => {
        const newItems = state.cart.items.filter(i => i.id !== itemId)
        const total = newItems.reduce((sum, i) => sum + (i.price * i.quantity), 0)
        
        return {
          cart: { ...state.cart, items: newItems, total }
        }
      }),
      
      clearCart: () => set((state) => ({
        cart: { ...state.cart, items: [], total: 0 }
      })),
      
      // UI actions
      setTheme: (theme) => set((state) => ({
        ui: { ...state.ui, theme }
      })),
      
      setSidebarOpen: (open) => set((state) => ({
        ui: { ...state.ui, sidebarOpen: open }
      })),
      
      addNotification: (notification) => set((state) => ({
        ui: {
          ...state.ui,
          notifications: [...state.ui.notifications, { ...notification, id: Date.now().toString() }]
        }
      })),
      
      removeNotification: (id) => set((state) => ({
        ui: {
          ...state.ui,
          notifications: state.ui.notifications.filter(n => n.id !== id)
        }
      }))
    }),
    {
      name: 'ecommerce-global-state',
      storage: createJSONStorage(() => localStorage),
      partialize: (state) => ({
        user: state.user,
        cart: state.cart,
        ui: { theme: state.ui.theme }
      })
    }
  )
)

// Helper hooks for specific state slices
export const useAuth = () => {
  const { user, setUser, logout } = useGlobalStore()
  return { user, setUser, logout }
}

export const useCart = () => {
  const { cart, addToCart, removeFromCart, clearCart } = useGlobalStore()
  return { cart, addToCart, removeFromCart, clearCart }
}

export const useTheme = () => {
  const { ui: { theme }, setTheme } = useGlobalStore()
  return { theme, setTheme }
}