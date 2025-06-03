// Unified authentication system for microfrontends
import { jwtDecode } from 'jwt-decode'

interface User {
  id: string
  email: string
  name: string
  role: string
  permissions: string[]
}

interface TokenPayload {
  sub: string
  email: string
  name: string
  role: string
  permissions: string[]
  exp: number
  iat: number
}

class AuthManager {
  private static instance: AuthManager
  private accessToken: string | null = null
  private refreshToken: string | null = null
  private user: User | null = null
  private refreshTimer: NodeJS.Timeout | null = null

  private constructor() {
    this.loadTokensFromStorage()
    this.startTokenRefreshTimer()
  }

  static getInstance(): AuthManager {
    if (!AuthManager.instance) {
      AuthManager.instance = new AuthManager()
    }
    return AuthManager.instance
  }

  // Login with credentials
  async login(email: string, password: string): Promise<{ success: boolean; error?: string }> {
    try {
      const response = await fetch('/api/auth/login', {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({ email, password })
      })

      if (!response.ok) {
        const error = await response.json()
        return { success: false, error: error.message }
      }

      const { accessToken, refreshToken } = await response.json()
      this.setTokens(accessToken, refreshToken)
      
      return { success: true }
    } catch (error) {
      return { success: false, error: 'Login failed' }
    }
  }

  // Logout
  async logout(): Promise<void> {
    try {
      if (this.refreshToken) {
        await fetch('/api/auth/logout', {
          method: 'POST',
          headers: {
            'Content-Type': 'application/json',
            'Authorization': `Bearer ${this.accessToken}`
          },
          body: JSON.stringify({ refreshToken: this.refreshToken })
        })
      }
    } catch (error) {
      console.error('Logout API call failed:', error)
    } finally {
      this.clearTokens()
    }
  }

  // Set tokens and update user
  private setTokens(accessToken: string, refreshToken: string): void {
    this.accessToken = accessToken
    this.refreshToken = refreshToken
    
    // Decode user from token
    try {
      const payload: TokenPayload = jwtDecode(accessToken)
      this.user = {
        id: payload.sub,
        email: payload.email,
        name: payload.name,
        role: payload.role,
        permissions: payload.permissions || []
      }
    } catch (error) {
      console.error('Failed to decode token:', error)
    }

    // Store in localStorage
    localStorage.setItem('accessToken', accessToken)
    localStorage.setItem('refreshToken', refreshToken)
    
    this.startTokenRefreshTimer()
  }

  // Clear tokens and user
  private clearTokens(): void {
    this.accessToken = null
    this.refreshToken = null
    this.user = null
    
    localStorage.removeItem('accessToken')
    localStorage.removeItem('refreshToken')
    
    if (this.refreshTimer) {
      clearTimeout(this.refreshTimer)
      this.refreshTimer = null
    }
  }

  // Load tokens from storage
  private loadTokensFromStorage(): void {
    const accessToken = localStorage.getItem('accessToken')
    const refreshToken = localStorage.getItem('refreshToken')
    
    if (accessToken && refreshToken) {
      try {
        const payload: TokenPayload = jwtDecode(accessToken)
        
        // Check if token is expired
        if (payload.exp * 1000 > Date.now()) {
          this.setTokens(accessToken, refreshToken)
        } else {
          this.clearTokens()
        }
      } catch (error) {
        this.clearTokens()
      }
    }
  }

  // Refresh access token
  private async refreshAccessToken(): Promise<boolean> {
    if (!this.refreshToken) return false

    try {
      const response = await fetch('/api/auth/refresh', {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({ refreshToken: this.refreshToken })
      })

      if (!response.ok) {
        this.clearTokens()
        return false
      }

      const { accessToken, refreshToken } = await response.json()
      this.setTokens(accessToken, refreshToken)
      return true
    } catch (error) {
      this.clearTokens()
      return false
    }
  }

  // Start automatic token refresh
  private startTokenRefreshTimer(): void {
    if (this.refreshTimer) {
      clearTimeout(this.refreshTimer)
    }

    if (!this.accessToken) return

    try {
      const payload: TokenPayload = jwtDecode(this.accessToken)
      const expiresIn = (payload.exp * 1000) - Date.now()
      const refreshTime = Math.max(expiresIn - 5 * 60 * 1000, 30000) // Refresh 5 mins before expiry, min 30s

      this.refreshTimer = setTimeout(async () => {
        await this.refreshAccessToken()
      }, refreshTime)
    } catch (error) {
      console.error('Failed to set refresh timer:', error)
    }
  }

  // Get current user
  getUser(): User | null {
    return this.user
  }

  // Check if user is authenticated
  isAuthenticated(): boolean {
    return !!this.accessToken && !!this.user
  }

  // Get access token
  getAccessToken(): string | null {
    return this.accessToken
  }

  // Check user permissions
  hasPermission(permission: string): boolean {
    return this.user?.permissions.includes(permission) || false
  }

  // Check user role
  hasRole(role: string): boolean {
    return this.user?.role === role
  }
}

// Export singleton instance
export const authManager = AuthManager.getInstance()

// React hook for authentication
export const useAuth = () => {
  const [user, setUser] = useState<User | null>(authManager.getUser())
  const [isAuthenticated, setIsAuthenticated] = useState(authManager.isAuthenticated())

  useEffect(() => {
    // Listen for auth changes
    const checkAuth = () => {
      setUser(authManager.getUser())
      setIsAuthenticated(authManager.isAuthenticated())
    }

    // Check periodically
    const interval = setInterval(checkAuth, 1000)
    
    return () => clearInterval(interval)
  }, [])

  const login = async (email: string, password: string) => {
    const result = await authManager.login(email, password)
    if (result.success) {
      setUser(authManager.getUser())
      setIsAuthenticated(true)
    }
    return result
  }

  const logout = async () => {
    await authManager.logout()
    setUser(null)
    setIsAuthenticated(false)
  }

  return {
    user,
    isAuthenticated,
    login,
    logout,
    hasPermission: (permission: string) => authManager.hasPermission(permission),
    hasRole: (role: string) => authManager.hasRole(role)
  }
}