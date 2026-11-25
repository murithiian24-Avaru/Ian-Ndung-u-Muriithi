import React, { useState } from 'react'
import Sidebar from './components/Sidebar'
import Dashboard from './pages/Dashboard'
import UsersPage from './pages/UsersPage'
import AdvertisersPage from './pages/AdvertisersPage'
import AdsPage from './pages/AdsPage'
import WithdrawalsPage from './pages/WithdrawalsPage'
import AnalyticsPage from './pages/AnalyticsPage'
import FraudPage from './pages/FraudPage'
import { WITHDRAWALS_ENABLED } from './features'

const pages = {
  dashboard: Dashboard,
  users: UsersPage,
  advertisers: AdvertisersPage,
  ads: AdsPage,
  ...(WITHDRAWALS_ENABLED ? { withdrawals: WithdrawalsPage } : {}),
  analytics: AnalyticsPage,
  fraud: FraudPage,
}

export default function App() {
  const [currentPage, setCurrentPage] = useState('dashboard')

  if (import.meta.env.PROD) {
    return (
      <main
        data-adlease-admin-status="ADLEASE_ADMIN_PRODUCTION_DISABLED"
        className="min-h-screen flex items-center justify-center bg-slate-950 p-8 text-center text-white"
      >
        <section className="max-w-lg">
          <h1 className="text-2xl font-semibold">Admin dashboard unavailable</h1>
          <p className="mt-3 text-slate-300">
            The AdLease admin dashboard is disabled in production. No administrator
            sign-in or production data access is available from this build.
          </p>
        </section>
      </main>
    )
  }
 
  const PageComponent = pages[currentPage] || Dashboard

  return (
    <div className="flex h-screen bg-gray-50">
      <Sidebar currentPage={currentPage} onNavigate={setCurrentPage} />
      <main className="flex-1 overflow-auto">
        <div role="note" className="bg-amber-50 border-b border-amber-200 text-amber-900 text-sm px-8 py-2">
          Demo data only: no real users, money, payments or withdrawals. Ads and rewards are simulated.
        </div>
        <PageComponent />
      </main>
    </div>
  )
}
