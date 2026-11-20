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

function ProductionAccessNotice() {
  return (
    <main className="min-h-screen flex items-center justify-center bg-gray-50 p-6">
      <section role="alert" className="max-w-xl rounded-2xl border border-amber-200 bg-white p-8 shadow-sm">
        <h1 className="text-xl font-bold text-gray-900">Admin dashboard unavailable</h1>
        <p className="mt-3 text-gray-700">
          This dashboard is a local-only prototype. It has no authentication,
          server-side authorization, or audit logging and must not be used to
          access or manage real customer data.
        </p>
        <p className="mt-3 text-sm text-gray-500">
          Production admin access remains disabled until the approved security
          controls and backend are implemented.
        </p>
      </section>
    </main>
  )
}

function AdminDemoApp() {
  const [currentPage, setCurrentPage] = useState('dashboard')
  const PageComponent = pages[currentPage] || Dashboard

  return (
    <div className="flex h-screen bg-gray-50">
      <Sidebar currentPage={currentPage} onNavigate={setCurrentPage} />
      <main className="flex-1 overflow-auto">
        <div role="note" className="bg-amber-50 border-b border-amber-200 text-amber-900 text-sm px-8 py-2">
          LOCAL DEMO ONLY: sample data; no real users, money, payments or withdrawals.
        </div>
        <PageComponent />
      </main>
    </div>
  )
}

export default function App() {
  // Vite replaces DEV at build time. Production builds never render the
  // unauthenticated prototype, even if a runtime environment flag is set.
  if (!import.meta.env.DEV) {
    return <ProductionAccessNotice />
  }

  return <AdminDemoApp />
}
