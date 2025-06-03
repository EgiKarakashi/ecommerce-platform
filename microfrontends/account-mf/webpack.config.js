const { shareAll, withModuleFederationPlugin } = require('@angular-architects/module-federation/webpack');

module.exports = withModuleFederationPlugin({
  name: 'account',
  
  exposes: {
    './UserProfile': './src/app/features/profile/components/user-profile/user-profile.component.ts',
    './ProfileEdit': './src/app/features/profile/components/profile-edit/profile-edit.component.ts',
    './OrderHistory': './src/app/features/orders/components/order-history/order-history.component.ts',
    './OrderDetails': './src/app/features/orders/components/order-details/order-details.component.ts',
    './AddressBook': './src/app/features/addresses/components/address-book/address-book.component.ts',
    './AddressForm': './src/app/features/addresses/components/address-form/address-form.component.ts',
    './PaymentMethods': './src/app/features/payment-methods/components/payment-methods/payment-methods.component.ts',
    './PaymentMethodForm': './src/app/features/payment-methods/components/payment-method-form/payment-method-form.component.ts',
    './AccountSettings': './src/app/features/settings/components/account-settings/account-settings.component.ts',
    './SecuritySettings': './src/app/features/settings/components/security-settings/security-settings.component.ts',
    './NotificationSettings': './src/app/features/settings/components/notification-settings/notification-settings.component.ts',
    './LoginForm': './src/app/features/auth/components/login-form/login-form.component.ts',
    './RegisterForm': './src/app/features/auth/components/register-form/register-form.component.ts',
    './ForgotPassword': './src/app/features/auth/components/forgot-password/forgot-password.component.ts',
    './AccountDashboard': './src/app/features/dashboard/components/account-dashboard/account-dashboard.component.ts',
    './WishList': './src/app/features/wishlist/components/wish-list/wish-list.component.ts',
    './ReviewsRatings': './src/app/features/reviews/components/reviews-ratings/reviews-ratings.component.ts',
  },

  shared: {
    ...shareAll({ 
      singleton: true, 
      strictVersion: true, 
      requiredVersion: 'auto' 
    }),
  }
});
