import React, { useState } from 'react'
import { Search, Filter } from 'lucide-react'

const sampleUsers = [
  { id: 1, name: 'Demo User 01', email: 'demo-user-01@example.invalid', phone: '', country: 'Demo', balance: 0, ownership: 0, verified: false, status: 'sample' },
  { id: 2, name: 'Demo User 02', email: 'demo-user-02@example.invalid', phone: '', country: 'Demo', balance: 0, ownership: 0, verified: false, status: 'sample' },
  { id: 3, name: 'Demo User 03', email: 'demo-user-03@example.invalid', phone: '', country: 'Demo', balance: 0, ownership: 0, verified: false, status: 'sample' },
  { id: 4, name: 'Demo User 04', email: 'demo-user-04@example.invalid', phone: '', country: 'Demo', balance: 0, ownership: 0, verified: false, status: 'sample' },
  { id: 5, name: 'Demo User 05', email: 'demo-user-05@example.invalid', phone: '', country: 'Demo', balance: 0, ownership: 0, verified: false, status: 'sample' },
  { id: 6, name: 'Demo User 06', email: 'demo-user-06@example.invalid', phone: '', country: 'Demo', balance: 0, ownership: 0, verified: false, status: 'sample' },
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
          <p className="text-gray-500 mt-1">Synthetic demo records only — not registered customers</p>
        </div>
        <span className="bg-blue-100 text-blue-800 px-4 py-2 rounded-full text-sm font-semibold">
          {sampleUsers.length} demo records
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
                <th className="text-left p-4 text-sm font-semibold text-gray-600">Progress</th>
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
                  <td className="p-4 text-sm text-gray-500">Unavailable</td>
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
                      'bg-gray-100 text-gray-600'
                    }`}>
                      {user.status}
                    </span>
                  </td>
                  <td className="p-4">
                    <span className="text-xs text-gray-500">Demo only — unavailable</span>
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
