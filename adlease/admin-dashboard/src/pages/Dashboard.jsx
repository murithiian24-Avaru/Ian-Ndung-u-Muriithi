import React from 'react'
import { Users, DollarSign, PlayCircle, Smartphone, TrendingUp, Eye } from 'lucide-react'
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
  { user: 'John Kamau', action: 'Watched ad', amount: '+$2.50', time: '2 min ago' },
  { user: 'Mary Wanjiku', action: 'Withdrawal request', amount: '-$15.00', time: '5 min ago' },
  { user: 'Peter Ochieng', action: 'New registration', amount: '', time: '12 min ago' },
  { user: 'Sarah Muthoni', action: 'Phone ownership complete', amount: '$300.00', time: '1 hr ago' },
  { user: 'James Njoroge', action: 'Referral bonus', amount: '+$5.00', time: '2 hr ago' },
]

export default function Dashboard() {
  return (
    <div className="p-8">
      <div className="mb-8">
        <h1 className="text-3xl font-bold text-gray-900">Dashboard</h1>
        <p className="text-gray-500 mt-1">Welcome back, Admin. Here's what's happening.</p>
      </div>

      <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-4 gap-6 mb-8">
        <StatCard title="Total Users" value="1,247" icon={Users} color="blue" change={12.5} />
        <StatCard title="Revenue" value="$45,200" icon={DollarSign} color="green" change={8.3} />
        <StatCard title="Ads Watched" value="3,842" icon={PlayCircle} color="orange" change={15.2} />
        <StatCard title="Phones Owned" value="89" icon={Smartphone} color="purple" change={5.7} />
      </div>

      <div className="grid grid-cols-1 lg:grid-cols-3 gap-6 mb-8">
        <div className="lg:col-span-2 bg-white rounded-2xl p-6 shadow-sm border border-gray-100">
          <h3 className="text-lg font-semibold mb-4">Revenue Overview</h3>
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
          <h3 className="text-lg font-semibold mb-4">Revenue Distribution</h3>
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
        <h3 className="text-lg font-semibold mb-4">Recent Activity</h3>
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
