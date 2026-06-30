import React, { useState } from 'react'
import { Search, Filter, MoreVertical, UserCheck, UserX, Eye } from 'lucide-react'

const sampleUsers = [
  { id: 1, name: 'John Kamau', email: 'john@email.com', phone: '+254711222333', country: 'Kenya', balance: 45.50, ownership: 67, verified: true, status: 'active' },
  { id: 2, name: 'Mary Wanjiku', email: 'mary@email.com', phone: '+254722333444', country: 'Kenya', balance: 12.00, ownership: 23, verified: true, status: 'active' },
  { id: 3, name: 'Peter Ochieng', email: 'peter@email.com', phone: '+254733444555', country: 'Kenya', balance: 0.00, ownership: 0, verified: false, status: 'pending' },
  { id: 4, name: 'Amina Hassan', email: 'amina@email.com', phone: '+254744555666', country: 'Tanzania', balance: 89.00, ownership: 100, verified: true, status: 'active' },
  { id: 5, name: 'David Otieno', email: 'david@email.com', phone: '+254755666777', country: 'Kenya', balance: 33.25, ownership: 45, verified: true, status: 'active' },
  { id: 6, name: 'Grace Akinyi', email: 'grace@email.com', phone: '+254766777888', country: 'Uganda', balance: 5.00, ownership: 8, verified: false, status: 'suspended' },
]

export default function UsersPage() {
  const [search, setSearch] = useState('')
  const filtered = sampleUsers.filter(u =>
    u.name.toLowerCase().includes(search.toLowerCase()) ||
    u.email.toLowerCase().includes(search.toLowerCase())
  )

  return (
    <div className="p-8">
      <div className="flex items-center justify-between mb-8">
        <div>
          <h1 className="text-3xl font-bold text-gray-900">Users</h1>
          <p className="text-gray-500 mt-1">Manage all registered users</p>
        </div>
        <span className="bg-blue-100 text-blue-800 px-4 py-2 rounded-full text-sm font-semibold">
          {sampleUsers.length} total users
        </span>
      </div>

      <div className="bg-white rounded-2xl shadow-sm border border-gray-100">
        <div className="p-4 border-b border-gray-100 flex items-center gap-4">
          <div className="flex-1 relative">
            <Search className="w-5 h-5 absolute left-3 top-1/2 -translate-y-1/2 text-gray-400" />
            <input
              type="text"
              placeholder="Search users..."
              value={search}
              onChange={(e) => setSearch(e.target.value)}
              className="w-full pl-10 pr-4 py-2.5 rounded-xl border border-gray-200 focus:outline-none focus:ring-2 focus:ring-blue-500 focus:border-transparent"
            />
          </div>
          <button className="flex items-center gap-2 px-4 py-2.5 border border-gray-200 rounded-xl hover:bg-gray-50">
            <Filter className="w-4 h-4" /> Filter
          </button>
        </div>

        <div className="overflow-x-auto">
          <table className="w-full">
            <thead>
              <tr className="border-b border-gray-100">
                <th className="text-left p-4 text-sm font-semibold text-gray-600">User</th>
                <th className="text-left p-4 text-sm font-semibold text-gray-600">Country</th>
                <th className="text-left p-4 text-sm font-semibold text-gray-600">Balance</th>
                <th className="text-left p-4 text-sm font-semibold text-gray-600">Ownership</th>
                <th className="text-left p-4 text-sm font-semibold text-gray-600">Status</th>
                <th className="text-left p-4 text-sm font-semibold text-gray-600">Actions</th>
              </tr>
            </thead>
            <tbody>
              {filtered.map((user) => (
                <tr key={user.id} className="border-b border-gray-50 hover:bg-gray-50">
                  <td className="p-4">
                    <div className="flex items-center gap-3">
                      <div className="w-10 h-10 bg-blue-100 rounded-full flex items-center justify-center">
                        <span className="text-blue-800 font-bold text-sm">{user.name.split(' ').map(n => n[0]).join('')}</span>
                      </div>
                      <div>
                        <p className="font-medium text-sm">{user.name}</p>
                        <p className="text-xs text-gray-500">{user.email}</p>
                      </div>
                    </div>
                  </td>
                  <td className="p-4 text-sm text-gray-600">{user.country}</td>
                  <td className="p-4 text-sm font-semibold">${user.balance.toFixed(2)}</td>
                  <td className="p-4">
                    <div className="flex items-center gap-2">
                      <div className="w-24 h-2 bg-gray-200 rounded-full overflow-hidden">
                        <div
                          className="h-full bg-blue-600 rounded-full"
                          style={{ width: `${user.ownership}%` }}
                        />
                      </div>
                      <span className="text-xs font-medium text-gray-600">{user.ownership}%</span>
                    </div>
                  </td>
                  <td className="p-4">
                    <span className={`px-3 py-1 rounded-full text-xs font-semibold ${
                      user.status === 'active' ? 'bg-green-100 text-green-700' :
                      user.status === 'pending' ? 'bg-yellow-100 text-yellow-700' :
                      'bg-red-100 text-red-700'
                    }`}>
                      {user.status}
                    </span>
                  </td>
                  <td className="p-4">
                    <div className="flex items-center gap-2">
                      <button className="p-1.5 hover:bg-blue-50 rounded-lg" title="View">
                        <Eye className="w-4 h-4 text-blue-600" />
                      </button>
                      <button className="p-1.5 hover:bg-green-50 rounded-lg" title="Verify">
                        <UserCheck className="w-4 h-4 text-green-600" />
                      </button>
                      <button className="p-1.5 hover:bg-red-50 rounded-lg" title="Suspend">
                        <UserX className="w-4 h-4 text-red-600" />
                      </button>
                    </div>
                  </td>
                </tr>
              ))}
            </tbody>
          </table>
        </div>
      </div>
    </div>
  )
}
