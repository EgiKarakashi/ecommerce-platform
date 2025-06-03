export const environment = {
  production: false,
  apiUrl: 'http://localhost:8080/api',
  shellUrl: 'http://localhost:3000',
  catalogUrl: 'http://localhost:3001',
  cartUrl: 'http://localhost:3002',
  auth: {
    tokenKey: 'ecommerce_auth_token',
    refreshTokenKey: 'ecommerce_refresh_token',
    tokenExpiration: 3600000, // 1 hour
  },
  features: {
    enableNotifications: true,
    enableAnalytics: false,
    enablePWA: true,
  }
};
