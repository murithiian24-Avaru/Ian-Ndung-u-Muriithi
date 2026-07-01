import React from 'react'
import { ShieldAlert, AlertTriangle, CheckCircle, XCircle, Eye, Ban } from 'lucide-react'

const fraudAlerts = [
  { id: 1, user: 'User #4521', type: 'Multiple devices', risk: 'high', description: 'Same account accessed from 5 different devices in 1 hour', time: '10 min ago', status: 'new' },
  { id: 2, user: 'User #3892', type: 'Rapid ad views', risk: 'medium', description: 'Completed 3 ads within 2 minutes (impossible)', time: '25 min ago', status: 'investigating' },
  { id: 3, user: 'User #5103', type: 'VPN detected', risk: 'low', description: 'User location changed 4 times during ad view', time: '1 hr ago', status: 'resolved' },
  { id: 4, user: 'User #2847', type: 'Bot behavior', risk: 'high', description: 'Identical interaction patterns detected, zero variance', time: '2 hr ago', status: 'new' },
  { id: 5, user: 'User #6291', type: 'Fake referrals', risk: 'high', description: '15 referrals from same IP address in 30 minutes', time: '3 hr ago', status: 'investigating' },
]

const metrics = [
  { label: 'Active Alerts', value: 3, icon: AlertTriangle, color: 'red' },
  { label: 'Investigating', value: 2, icon: Eye, color: 'yellow' },
  { label: 'Resolved Today', value: 8, icon: CheckCircle, color: 'green' },
  { label: 'Blocked Users', value: 12, icon: Ban, color: 'gray' },
]

export default function FraudPage() {
  return (
    <div className="p-8">
      <div className="mb-8">
        <h1 className="text-3xl font-bold text-gray-900">Fraud Monitor</h1>
        <p className="text-gray-500 mt-1">Detect and prevent fraudulent activity</p>
      </div>

      <div className="grid grid-cols-1 md:grid-cols-4 gap-4 mb-8">
        {metrics.map((metric) => {
          const Icon = metric.icon
          return (
            <div key={metric.label} className="bg-white rounded-2xl p-5 shadow-sm border border-gray-100">
              <div className="flex items-center justify-between">
                <div>
                  <p className="text-sm text-gray-500">{metric.label}</p>
                  <p className="text-3xl font-bold mt-1">{metric.value}</p>
                </div>
                <div className={`p-3 rounded-xl ${
                  metric.color === 'red' ? 'bg-red-100' :
                  metric.color === 'yellow' ? 'bg-yellow-100' :
                  metric.color === 'green' ? 'bg-green-100' : 'bg-gray-100'
                }`}>
                  <Icon className={`w-5 h-5 ${
                    metric.color === 'red' ? 'text-red-600' :
                    metric.color === 'yellow' ? 'text-yellow-600' :
                    metric.color === 'green' ? 'text-green-600' : 'text-gray-600'
                  }`} />
                </div>
              </div>
            </div>
          )
        })}
      </div>

      <div className="bg-white rounded-2xl shadow-sm border border-gray-100">
        <div className="p-4 border-b border-gray-100">
          <h3 className="font-semibold flex items-center gap-2">
            <ShieldAlert className="w-5 h-5 text-red-500" /> Recent Fraud Alerts
          </h3>
        </div>
        <div className="divide-y divide-gray-50">
          {fraudAlerts.map((alert) => (
            <div key={alert.id} className="p-4 hover:bg-gray-50">
              <div className="flex items-start justify-between">
                <div className="flex items-start gap-3">
                  <div className={`mt-1 p-2 rounded-xl ${
                    alert.risk === 'high' ? 'bg-red-100' :
                    alert.risk === 'medium' ? 'bg-yellow-100' : 'bg-blue-100'
                  }`}>
                    <AlertTriangle className={`w-4 h-4 ${
                      alert.risk === 'high' ? 'text-red-600' :
                      alert.risk === 'medium' ? 'text-yellow-600' : 'text-blue-600'
                    }`} />
                  </div>
                  <div>
                    <div className="flex items-center gap-2">
                      <p className="font-semibold text-sm">{alert.user}</p>
                      <span className={`px-2 py-0.5 rounded-full text-xs font-semibold ${
                        alert.risk === 'high' ? 'bg-red-100 text-red-700' :
                        alert.risk === 'medium' ? 'bg-yellow-100 text-yellow-700' :
                        'bg-blue-100 text-blue-700'
                      }`}>
                        {alert.risk} risk
                      </span>
                      <span className={`px-2 py-0.5 rounded-full text-xs font-semibold ${
                        alert.status === 'new' ? 'bg-red-100 text-red-700' :
                        alert.status === 'investigating' ? 'bg-yellow-100 text-yellow-700' :
                        'bg-green-100 text-green-700'
                      }`}>
                        {alert.status}
                      </span>
                    </div>
                    <p className="text-sm font-medium text-gray-700 mt-1">{alert.type}</p>
                    <p className="text-sm text-gray-500">{alert.description}</p>
                    <p className="text-xs text-gray-400 mt-1">{alert.time}</p>
                  </div>
                </div>
                <div className="flex items-center gap-2">
                  <button className="px-3 py-1.5 text-sm bg-yellow-50 text-yellow-700 rounded-lg hover:bg-yellow-100 font-medium">
                    Investigate
                  </button>
                  <button className="px-3 py-1.5 text-sm bg-red-50 text-red-700 rounded-lg hover:bg-red-100 font-medium">
                    Block User
                  </button>
                </div>
              </div>
            </div>
          ))}
        </div>
      </div>
    </div>
  )
}
