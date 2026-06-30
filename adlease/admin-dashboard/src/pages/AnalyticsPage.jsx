import React from 'react'
import { BarChart, Bar, LineChart, Line, XAxis, YAxis, CartesianGrid, Tooltip, ResponsiveContainer, PieChart, Pie, Cell } from 'recharts'
import { TrendingUp, Users, Eye, DollarSign } from 'lucide-react'

const monthlyData = [
  { month: 'Jan', users: 230, ads: 680, revenue: 12400 },
  { month: 'Feb', users: 340, ads: 1020, revenue: 18600 },
  { month: 'Mar', users: 520, ads: 1560, revenue: 24800 },
  { month: 'Apr', users: 680, ads: 2040, revenue: 31200 },
  { month: 'May', users: 890, ads: 2670, revenue: 38500 },
  { month: 'Jun', users: 1120, ads: 3360, revenue: 45200 },
]

const countryData = [
  { name: 'Kenya', value: 580, color: '#1565C0' },
  { name: 'Nigeria', value: 230, color: '#42A5F5' },
  { name: 'Tanzania', value: 150, color: '#FFB300' },
  { name: 'Uganda', value: 120, color: '#43A047' },
  { name: 'Others', value: 167, color: '#9E9E9E' },
]

const phoneData = [
  { model: 'Samsung A54', count: 25 },
  { model: 'Tecno Camon 20', count: 22 },
  { model: 'Xiaomi Note 13', count: 18 },
  { model: 'Infinix Note 30', count: 14 },
  { model: 'Galaxy S24', count: 6 },
  { model: 'iPhone 15', count: 4 },
]

export default function AnalyticsPage() {
  return (
    <div className="p-8">
      <div className="mb-8">
        <h1 className="text-3xl font-bold text-gray-900">Analytics</h1>
        <p className="text-gray-500 mt-1">Platform performance and insights</p>
      </div>

      <div className="grid grid-cols-1 lg:grid-cols-2 gap-6 mb-6">
        <div className="bg-white rounded-2xl p-6 shadow-sm border border-gray-100">
          <h3 className="text-lg font-semibold mb-4 flex items-center gap-2">
            <Users className="w-5 h-5 text-blue-600" /> User Growth
          </h3>
          <ResponsiveContainer width="100%" height={250}>
            <LineChart data={monthlyData}>
              <CartesianGrid strokeDasharray="3 3" stroke="#f0f0f0" />
              <XAxis dataKey="month" stroke="#9ca3af" />
              <YAxis stroke="#9ca3af" />
              <Tooltip />
              <Line type="monotone" dataKey="users" stroke="#1565C0" strokeWidth={2} dot={{ r: 4 }} />
            </LineChart>
          </ResponsiveContainer>
        </div>

        <div className="bg-white rounded-2xl p-6 shadow-sm border border-gray-100">
          <h3 className="text-lg font-semibold mb-4 flex items-center gap-2">
            <Eye className="w-5 h-5 text-orange-500" /> Ad Views
          </h3>
          <ResponsiveContainer width="100%" height={250}>
            <BarChart data={monthlyData}>
              <CartesianGrid strokeDasharray="3 3" stroke="#f0f0f0" />
              <XAxis dataKey="month" stroke="#9ca3af" />
              <YAxis stroke="#9ca3af" />
              <Tooltip />
              <Bar dataKey="ads" fill="#FFB300" radius={[6, 6, 0, 0]} />
            </BarChart>
          </ResponsiveContainer>
        </div>
      </div>

      <div className="grid grid-cols-1 lg:grid-cols-2 gap-6">
        <div className="bg-white rounded-2xl p-6 shadow-sm border border-gray-100">
          <h3 className="text-lg font-semibold mb-4">Users by Country</h3>
          <div className="flex items-center gap-8">
            <ResponsiveContainer width="50%" height={200}>
              <PieChart>
                <Pie data={countryData} cx="50%" cy="50%" innerRadius={40} outerRadius={80} dataKey="value">
                  {countryData.map((entry, i) => (
                    <Cell key={i} fill={entry.color} />
                  ))}
                </Pie>
                <Tooltip />
              </PieChart>
            </ResponsiveContainer>
            <div className="space-y-3">
              {countryData.map((item) => (
                <div key={item.name} className="flex items-center gap-2">
                  <div className="w-3 h-3 rounded-full" style={{ backgroundColor: item.color }} />
                  <span className="text-sm text-gray-600">{item.name}</span>
                  <span className="text-sm font-semibold ml-auto">{item.value}</span>
                </div>
              ))}
            </div>
          </div>
        </div>

        <div className="bg-white rounded-2xl p-6 shadow-sm border border-gray-100">
          <h3 className="text-lg font-semibold mb-4">Popular Phone Models</h3>
          <ResponsiveContainer width="100%" height={250}>
            <BarChart data={phoneData} layout="vertical">
              <CartesianGrid strokeDasharray="3 3" stroke="#f0f0f0" />
              <XAxis type="number" stroke="#9ca3af" />
              <YAxis dataKey="model" type="category" stroke="#9ca3af" width={100} />
              <Tooltip />
              <Bar dataKey="count" fill="#1565C0" radius={[0, 6, 6, 0]} />
            </BarChart>
          </ResponsiveContainer>
        </div>
      </div>
    </div>
  )
}
