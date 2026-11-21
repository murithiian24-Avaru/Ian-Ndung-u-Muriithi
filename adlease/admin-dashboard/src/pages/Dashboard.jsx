import React from 'react'
import { Users, Banknote, PlayCircle, Smartphone } from 'lucide-react'
import { AreaChart, Area, XAxis, YAxis, CartesianGrid, Tooltip, ResponsiveContainer, PieChart, Pie, Cell } from 'recharts'
import StatCard from '../components/StatCard'

const revenueData = [
  { month: 'Jan', revenue: 12400, users: 230 },
  { month: 'Feb', revenue: 18600, users: 340 },
  { month: 'Mar', revenue: 24800, users: 520 },
  { month: 'Apr', revenue: 31200, users: 680 },
  { month: 'May', revenue: 38500, users: 890 },
  { month: 'Jun', revenue: 45200, users: 1120 },
]

const distributionData = [
  { name: 'Users', value: 40, color: '#1565C0' },
  { name: 'AdLease', value: 30, color: '#FFB300' },
  { name: 'Manufacturers', value: 30, color: '#43A047' },
]

const recentActivity = [
  { user: 'Demo User 01', action: 'Sample playback event', amount: 'Sample event', time: 'Demo timestamp' },
  { user: 'Demo User 02', action: 'Sample registration event', amount: 'Sample event', time: 'Demo timestamp' },
  { user: 'Demo User 03', action: 'Sample ownership event', amount: 'Sample event', time: 'Demo timestamp' },
  { user: 'Demo User 04', action: 'Sample referral event', amount: 'Sample event', time: 'Demo timestamp' },
]

export default function Dashboard() {
  return (
    <div className="p-8">
      <div className="mb-8">
        <h1 className="text-3xl font-bold text-gray-900">Demo Dashboard</h1>
        <p className="text-gray-500 mt-1">Illustrative sample metrics only — no live users, ad views, revenue or ownership events.</p>
      </div>

      <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-4 gap-6 mb-8">
        <StatCard title="Sample users" value="1,247 (demo)" icon={Users} color="blue" change={0} />
        <StatCard title="Revenue" value="Not available" icon={Banknote} color="green" change={0} />
        <StatCard title="Sample ad views" value="3,842 (demo)" icon={PlayCircle} color="orange" change={0} />
        <StatCard title="Sample ownership events" value="89 (demo)" icon={Smartphone} color="purple" change={0} />
      </div>

      <div className="grid grid-cols-1 lg:grid-cols-3 gap-6 mb-8">
        <div className="lg:col-span-2 bg-white rounded-2xl p-6 shadow-sm border border-gray-100">
          <h3 className="text-lg font-semibold mb-4">Sample trend (not actual revenue)</h3>
          <ResponsiveContainer width="100%" height={300}>
            <AreaChart data={revenueData}>
              <CartesianGrid strokeDasharray="3 3" stroke="#f0f0f0" />
              <XAxis dataKey="month" stroke="#9ca3af" />
              <YAxis stroke="#9ca3af" />
              <Tooltip />
              <Area type="monotone" dataKey="revenue" stroke="#1565C0" fill="#1565C020" strokeWidth={2} />
            </AreaChart>
          </ResponsiveContainer>
        </div>

        <div className="bg-white rounded-2xl p-6 shadow-sm border border-gray-100">
          <h3 className="text-lg font-semibold mb-4">Illustrative distribution only</h3>
          <ResponsiveContainer width="100%" height={200}>
            <PieChart>
              <Pie data={distributionData} cx="50%" cy="50%" innerRadius={50} outerRadius={80} dataKey="value">
                {distributionData.map((entry, index) => (
                  <Cell key={index} fill={entry.color} />
                ))}
              </Pie>
              <Tooltip />
            </PieChart>
          </ResponsiveContainer>
          <div className="space-y-2 mt-4">
            {distributionData.map((item) => (
              <div key={item.name} className="flex items-center justify-between">
                <div className="flex items-center gap-2">
                  <div className="w-3 h-3 rounded-full" style={{ backgroundColor: item.color }} />
                  <span className="text-sm text-gray-600">{item.name}</span>
                </div>
                <span className="text-sm font-semibold">{item.value}%</span>
              </div>
            ))}
          </div>
        </div>
      </div>

      <div className="bg-white rounded-2xl p-6 shadow-sm border border-gray-100">
        <h3 className="text-lg font-semibold mb-4">Synthetic sample activity</h3>
        <div className="space-y-4">
          {recentActivity.map((activity, i) => (
            <div key={i} className="flex items-center justify-between py-3 border-b border-gray-50 last:border-0">
              <div className="flex items-center gap-3">
                <div className="w-10 h-10 bg-blue-100 rounded-full flex items-center justify-center">
                  <span className="text-blue-800 font-bold text-sm">
                    {activity.user.split(' ').map(n => n[0]).join('')}
                  </span>
                </div>
                <div>
                  <p className="font-medium text-sm">{activity.user}</p>
                  <p className="text-xs text-gray-500">{activity.action}</p>
                </div>
              </div>
              <div className="text-right">
                <p className={`font-semibold text-sm ${
                  activity.amount.startsWith('+') ? 'text-green-600' :
                  activity.amount.startsWith('-') ? 'text-red-600' : 'text-gray-600'
                }`}>
                  {activity.amount || '--'}
                </p>
                <p className="text-xs text-gray-400">{activity.time}</p>
              </div>
            </div>
          ))}
        </div>
      </div>
    </div>
  )
}
