/**
 * Shared constants for the Nuge application
 */

// App Configuration
export const APP_NAME = 'Nuge' as const;
export const APP_VERSION = '1.0.0' as const;

// API Configuration
export const API_ENDPOINTS = {
  VENDORS: '/api/vendors',
  USERS: '/api/users',
  ORDERS: '/api/orders',
  RATINGS: '/api/ratings',
} as const;

// Map Configuration
export const MAP_CONFIG = {
  DEFAULT_ZOOM: 13,
  MAX_ZOOM: 18,
  MIN_ZOOM: 10,
  DEFAULT_CENTER: {
    lat: 50.8503, // Brussels default
    lng: 4.3517,
  },
} as const;

// Vendor Types
export const VENDOR_TYPES = {
  FOOD_TRUCK: 'food_truck',
  ICE_CREAM: 'ice_cream',
  BUTCHER: 'butcher',
  BAKERY: 'bakery',
  OTHER: 'other',
} as const;

export type VendorType = (typeof VENDOR_TYPES)[keyof typeof VENDOR_TYPES];

// Languages
export const SUPPORTED_LANGUAGES = ['en', 'fr', 'nl'] as const;
export type SupportedLanguage = (typeof SUPPORTED_LANGUAGES)[number];

// Subscription Plans
export const SUBSCRIPTION_PLANS = {
  FREE: 'free',
  VENDOR_BASIC: 'vendor_basic',
  VENDOR_PREMIUM: 'vendor_premium',
} as const;

export type SubscriptionPlan =
  (typeof SUBSCRIPTION_PLANS)[keyof typeof SUBSCRIPTION_PLANS];

// Pricing
export const PRICING = {
  VENDOR_MONTHLY: 39.99,
  VENDOR_MONTHLY_PROMO: 29.99,
  TRANSACTION_FEE: 0.05, // 5%
  TRANSACTION_FEE_FIXED: 0.3, // €0.30
  TRANSACTION_FEE_PROMO: 0.03, // 3%
} as const;
