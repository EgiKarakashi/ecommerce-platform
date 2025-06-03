export const environment = {
  production: true,
  apiUrl: 'https://api.yourcompany.com/api',
  shellUrl: 'https://yourcompany.com',
  catalogUrl: 'https://catalog.yourcompany.com',
  cartUrl: 'https://cart.yourcompany.com',
  auth: {
    tokenKey: 'ecommerce_auth_token',
    refreshTokenKey: 'ecommerce_refresh_token',
    tokenExpiration: 3600000, // 1 hour
  },
  features: {
    enableNotifications: true,
    enableAnalytics: true,
    enablePWA: true,
  }
};
