import React from 'react'
import {
  LayoutDashboard, Users, Megaphone, PlayCircle,
  CreditCard, BarChart3, ShieldAlert, LogOut, Smartphone
} from 'lucide-react'

const menuItems = [
  { id: 'dashboard', label: 'Dashboard', icon: LayoutDashboard },
  { id: 'users', label: 'Users', icon: Users },
  { id: 'advertisers', label: 'Advertisers', icon: Megaphone },
  { id: 'ads', label: 'Advertisements', icon: PlayCircle },
  { id: 'withdrawals', label: 'Withdrawals', icon: CreditCard },
  { id: 'analytics', label: 'Analytics', icon: BarChart3 },
  { id: 'fraud', label: 'Fraud Monitor', icon: ShieldAlert },
]

export default function Sidebar({ currentPage, onNavigate }) {
  return (
    <aside className="w-64 bg-gradient-to-b from-blue-800 to-blue-900 text-white flex flex-col">
      <div className="p-6 border-b border-blue-700">
        <div className="flex items-center gap-3">
          <div className="w-10 h-10 bg-white rounded-xl flex items-center justify-center">
            <Smartphone className="w-6 h-6 text-blue-800" />
          </div>
          <div>
            <h1 className="text-xl font-bold">AdLease</h1>
            <p className="text-xs text-blue-300">Admin Panel</p>
          </div>
        </div>
      </div>

      <nav className="flex-1 p-4 space-y-1">
        {menuItems.map((item) => {
          const Icon = item.icon
          const isActive = currentPage === item.id
          return (
            <button
              key={item.id}
              onClick={() => onNavigate(item.id)}
              className={`w-full flex items-center gap-3 px-4 py-3 rounded-xl text-sm font-medium transition-all ${
                isActive
                  ? 'bg-white/20 text-white shadow-lg'
                  : 'text-blue-200 hover:bg-white/10 hover:text-white'
              }`}
            >
              <Icon className="w-5 h-5" />
              {item.label}
            </button>
          )
        })}
      </nav>

      <div className="p-4 border-t border-blue-700">
        <div className="flex items-center gap-3 px-4 py-3">
          <div className="w-8 h-8 bg-blue-600 rounded-full flex items-center justify-center text-sm font-bold">
            A
          </div>
          <div className="flex-1">
            <p className="text-sm font-medium">Admin</p>
            <p className="text-xs text-blue-300">admin@adlease.com</p>
          </div>
          <button className="text-blue-300 hover:text-white">
            <LogOut className="w-4 h-4" />
          </button>
        </div>
      </div>
    </aside>
  )
}
