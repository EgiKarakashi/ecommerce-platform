// Cross-microfrontend event bus for communication
type EventCallback = (data?: any) => void

interface EventSubscription {
  event: string
  callback: EventCallback
  id: string
}

class MicrofrontendEventBus {
  private subscriptions: Map<string, EventSubscription[]> = new Map()
  private eventHistory: Map<string, any> = new Map()

  // Subscribe to events
  subscribe(event: string, callback: EventCallback): () => void {
    const id = `${Date.now()}-${Math.random()}`
    const subscription: EventSubscription = { event, callback, id }

    if (!this.subscriptions.has(event)) {
      this.subscriptions.set(event, [])
    }
    
    this.subscriptions.get(event)!.push(subscription)

    // Return unsubscribe function
    return () => this.unsubscribe(event, id)
  }

  // Unsubscribe from events
  private unsubscribe(event: string, id: string): void {
    const eventSubscriptions = this.subscriptions.get(event)
    if (eventSubscriptions) {
      const filtered = eventSubscriptions.filter(sub => sub.id !== id)
      if (filtered.length === 0) {
        this.subscriptions.delete(event)
      } else {
        this.subscriptions.set(event, filtered)
      }
    }
  }

  // Emit events
  emit(event: string, data?: any): void {
    // Store event in history for late subscribers
    this.eventHistory.set(event, { data, timestamp: Date.now() })

    // Notify all subscribers
    const eventSubscriptions = this.subscriptions.get(event)
    if (eventSubscriptions) {
      eventSubscriptions.forEach(sub => {
        try {
          sub.callback(data)
        } catch (error) {
          console.error(`Error in event handler for ${event}:`, error)
        }
      })
    }
  }

  // Get last emitted data for an event
  getLastEvent(event: string): any {
    return this.eventHistory.get(event)?.data
  }

  // Clear event history
  clearHistory(): void {
    this.eventHistory.clear()
  }
}

// Global event bus instance
export const eventBus = new MicrofrontendEventBus()

// Pre-defined event types for type safety
export const MF_EVENTS = {
  // User events
  USER_LOGIN: 'user:login',
  USER_LOGOUT: 'user:logout',
  USER_PROFILE_UPDATE: 'user:profile:update',

  // Cart events
  CART_ADD_ITEM: 'cart:add:item',
  CART_REMOVE_ITEM: 'cart:remove:item',
  CART_UPDATE_QUANTITY: 'cart:update:quantity',
  CART_CLEAR: 'cart:clear',

  // Navigation events
  NAVIGATE_TO: 'navigation:navigate',
  ROUTE_CHANGE: 'navigation:route:change',

  // UI events
  THEME_CHANGE: 'ui:theme:change',
  MODAL_OPEN: 'ui:modal:open',
  MODAL_CLOSE: 'ui:modal:close',
  SIDEBAR_TOGGLE: 'ui:sidebar:toggle',

  // Product events
  PRODUCT_VIEW: 'product:view',
  PRODUCT_FAVORITE: 'product:favorite',
  PRODUCT_SHARE: 'product:share',

  // Order events
  ORDER_CREATED: 'order:created',
  ORDER_UPDATED: 'order:updated',
  ORDER_CANCELLED: 'order:cancelled',

  // Error events
  ERROR_OCCURRED: 'error:occurred',
  MF_ERROR: 'microfrontend:error'
} as const

// React hook for event bus
export const useEventBus = () => {
  const subscribe = (event: string, callback: EventCallback) => {
    return eventBus.subscribe(event, callback)
  }

  const emit = (event: string, data?: any) => {
    eventBus.emit(event, data)
  }

  const getLastEvent = (event: string) => {
    return eventBus.getLastEvent(event)
  }

  return { subscribe, emit, getLastEvent }
}

// Vue composable for event bus
export const useEventBusVue = () => {
  const { onUnmounted } = require('vue')
  const unsubscribers: (() => void)[] = []

  const subscribe = (event: string, callback: EventCallback) => {
    const unsubscribe = eventBus.subscribe(event, callback)
    unsubscribers.push(unsubscribe)
    return unsubscribe
  }

  const emit = (event: string, data?: any) => {
    eventBus.emit(event, data)
  }

  const getLastEvent = (event: string) => {
    return eventBus.getLastEvent(event)
  }

  // Auto cleanup on component unmount
  onUnmounted(() => {
    unsubscribers.forEach(unsub => unsub())
  })

  return { subscribe, emit, getLastEvent }
}