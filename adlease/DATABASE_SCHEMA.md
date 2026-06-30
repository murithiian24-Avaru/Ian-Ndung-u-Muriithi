# AdLease Database Schema

## Firestore Collections

### `users`
| Field | Type | Description |
|-------|------|-------------|
| uid | string | Unique user ID |
| email | string | User email |
| fullName | string | Full name |
| phoneNumber | string | Phone number |
| country | string | Country |
| profilePictureUrl | string | Profile picture URL |
| referralCode | string | Unique referral code (ADL-XXXXXXXX) |
| referredBy | string? | Referral code used during signup |
| deviceModel | string | Device model info |
| deviceId | string | Device unique ID |
| createdAt | timestamp | Account creation date |
| lastLoginAt | timestamp | Last login timestamp |
| isVerified | boolean | Email verification status |
| isActive | boolean | Account active status |

### `wallets`
| Field | Type | Description |
|-------|------|-------------|
| userId | string | Reference to user |
| balance | number | Current balance |
| totalEarnings | number | Total earned amount |
| totalWithdrawn | number | Total withdrawn amount |
| lastUpdated | timestamp | Last update timestamp |

### `transactions`
| Field | Type | Description |
|-------|------|-------------|
| id | string | Transaction ID |
| userId | string | Reference to user |
| type | string | adReward, referralBonus, withdrawal, bonus |
| amount | number | Transaction amount |
| status | string | pending, completed, rejected |
| description | string | Transaction description |
| createdAt | timestamp | Transaction date |
| referenceId | string? | Related entity ID |

### `ownerships`
| Field | Type | Description |
|-------|------|-------------|
| id | string | Ownership ID |
| userId | string | Reference to user |
| phoneId | string | Reference to phone |
| phoneName | string | Phone full name |
| phonePrice | number | Phone price |
| amountPaid | number | Amount paid so far |
| startDate | timestamp | Ownership start date |
| completionDate | timestamp? | When phone was fully paid |
| isCompleted | boolean | Whether phone is fully owned |

### `phones`
| Field | Type | Description |
|-------|------|-------------|
| id | string | Phone ID |
| brand | string | Phone brand |
| model | string | Phone model |
| imageUrl | string | Phone image URL |
| price | number | Phone price |
| description | string | Phone description |
| specs | map | Key-value specs (Display, Camera, etc.) |
| isAvailable | boolean | Availability status |

### `ads`
| Field | Type | Description |
|-------|------|-------------|
| id | string | Ad ID |
| title | string | Ad title |
| advertiserName | string | Advertiser name |
| videoUrl | string | Video URL |
| thumbnailUrl | string | Thumbnail URL |
| durationSeconds | number | Ad duration (default 60) |
| rewardAmount | number | Reward per view |
| isActive | boolean | Whether ad is active |
| createdAt | timestamp | Creation date |
| expiresAt | timestamp | Expiration date |
| totalViews | number | Total view count |

### `adViews`
| Field | Type | Description |
|-------|------|-------------|
| id | string | View record ID |
| userId | string | Viewer user ID |
| adId | string | Ad ID |
| viewedAt | timestamp | View timestamp |
| completedFully | boolean | Whether ad was fully watched |
| rewardEarned | number | Reward earned |
| deviceId | string | Device that viewed |
| verificationHash | string | SHA-256 anti-cheat hash |

### `withdrawals`
| Field | Type | Description |
|-------|------|-------------|
| id | string | Withdrawal ID |
| userId | string | User ID |
| amount | number | Withdrawal amount |
| paymentMethod | string | M-Pesa, Bank Transfer, PayPal, etc. |
| paymentDetails | string | Payment destination details |
| status | string | pending, approved, completed, rejected |
| requestedAt | timestamp | Request timestamp |
| processedAt | timestamp? | Processing timestamp |
| adminNote | string? | Admin processing note |

### `referrals`
| Field | Type | Description |
|-------|------|-------------|
| referrerId | string | User who referred |
| referredUserId | string | User who was referred |
| referredUserName | string | Referred user's name |
| date | timestamp | Referral date |
| rewardAmount | number | Referral reward ($5.00) |

## Security Rules

```
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    match /users/{userId} {
      allow read: if request.auth != null && request.auth.uid == userId;
      allow write: if request.auth != null && request.auth.uid == userId;
    }
    match /wallets/{userId} {
      allow read: if request.auth != null && request.auth.uid == userId;
      allow write: if false; // Server-side only
    }
    match /transactions/{transactionId} {
      allow read: if request.auth != null && resource.data.userId == request.auth.uid;
      allow write: if false; // Server-side only
    }
    match /ownerships/{ownershipId} {
      allow read: if request.auth != null && resource.data.userId == request.auth.uid;
      allow write: if false; // Server-side only
    }
    match /phones/{phoneId} {
      allow read: if request.auth != null;
      allow write: if false; // Admin only
    }
    match /ads/{adId} {
      allow read: if request.auth != null;
      allow write: if false; // Admin only
    }
  }
}
```
