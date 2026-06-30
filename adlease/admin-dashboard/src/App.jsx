import React, { useState } from 'react'
import Sidebar from './components/Sidebar'
import Dashboard from './pages/Dashboard'
import UsersPage from './pages/UsersPage'
import AdvertisersPage from './pages/AdvertisersPage'
import AdsPage from './pages/AdsPage'
import WithdrawalsPage from './pages/WithdrawalsPage'
import AnalyticsPage from './pages/AnalyticsPage'
import FraudPage from './pages/FraudPage'

const pages = {
  dashboard: Dashboard,
  users: UsersPage,
  advertisers: AdvertisersPage,
  ads: AdsPage,
  withdrawals: WithdrawalsPage,
  analytics: AnalyticsPage,
  fraud: FraudPage,
}

export default function App() {
  const [currentPage, setCurrentPage] = useState('dashboard')
  const PageComponent = pages[currentPage] || Dashboard

  return (
    <div className="flex h-screen bg-gray-50">
      <Sidebar currentPage={currentPage} onNavigate={setCurrentPage} />
      <main className="flex-1 overflow-auto">
        <PageComponent />
      </main>
    </div>
  )
}
