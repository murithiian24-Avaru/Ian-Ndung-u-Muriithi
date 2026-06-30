import React from 'react'
import { CheckCircle, XCircle, Clock, DollarSign } from 'lucide-react'

const withdrawals = [
  { id: 1, user: 'John Kamau', amount: 15.00, method: 'M-Pesa', details: '+254711222333', status: 'pending', date: '2024-02-15' },
  { id: 2, user: 'Mary Wanjiku', amount: 25.00, method: 'Bank Transfer', details: 'Equity 012345678', status: 'pending', date: '2024-02-14' },
  { id: 3, user: 'David Otieno', amount: 10.00, method: 'M-Pesa', details: '+254755666777', status: 'approved', date: '2024-02-13' },
  { id: 4, user: 'Amina Hassan', amount: 50.00, method: 'PayPal', details: 'amina@email.com', status: 'completed', date: '2024-02-12' },
  { id: 5, user: 'Grace Akinyi', amount: 8.00, method: 'Airtel Money', details: '+254766777888', status: 'rejected', date: '2024-02-11' },
]

const stats = [
  { label: 'Pending', value: 2, amount: '$40.00', color: 'yellow' },
  { label: 'Approved', value: 1, amount: '$10.00', color: 'blue' },
  { label: 'Completed', value: 1, amount: '$50.00', color: 'green' },
  { label: 'Rejected', value: 1, amount: '$8.00', color: 'red' },
]

export default function WithdrawalsPage() {
  return (
    <div className="p-8">
      <div className="mb-8">
        <h1 className="text-3xl font-bold text-gray-900">Withdrawals</h1>
        <p className="text-gray-500 mt-1">Approve and manage withdrawal requests</p>
      </div>

      <div className="grid grid-cols-1 md:grid-cols-4 gap-4 mb-8">
        {stats.map((stat) => (
          <div key={stat.label} className="bg-white rounded-2xl p-5 shadow-sm border border-gray-100">
            <div className="flex items-center justify-between">
              <div>
                <p className="text-sm text-gray-500">{stat.label}</p>
                <p className="text-2xl font-bold mt-1">{stat.value}</p>
                <p className="text-sm text-gray-400">{stat.amount}</p>
              </div>
              <div className={`p-3 rounded-xl ${
                stat.color === 'yellow' ? 'bg-yellow-100' :
                stat.color === 'blue' ? 'bg-blue-100' :
                stat.color === 'green' ? 'bg-green-100' : 'bg-red-100'
              }`}>
                <DollarSign className={`w-5 h-5 ${
                  stat.color === 'yellow' ? 'text-yellow-600' :
                  stat.color === 'blue' ? 'text-blue-600' :
                  stat.color === 'green' ? 'text-green-600' : 'text-red-600'
                }`} />
              </div>
            </div>
          </div>
        ))}
      </div>

      <div className="bg-white rounded-2xl shadow-sm border border-gray-100">
        <div className="overflow-x-auto">
          <table className="w-full">
            <thead>
              <tr className="border-b border-gray-100">
                <th className="text-left p-4 text-sm font-semibold text-gray-600">User</th>
                <th className="text-left p-4 text-sm font-semibold text-gray-600">Amount</th>
                <th className="text-left p-4 text-sm font-semibold text-gray-600">Method</th>
                <th className="text-left p-4 text-sm font-semibold text-gray-600">Details</th>
                <th className="text-left p-4 text-sm font-semibold text-gray-600">Date</th>
                <th className="text-left p-4 text-sm font-semibold text-gray-600">Status</th>
                <th className="text-left p-4 text-sm font-semibold text-gray-600">Actions</th>
              </tr>
            </thead>
            <tbody>
              {withdrawals.map((w) => (
                <tr key={w.id} className="border-b border-gray-50 hover:bg-gray-50">
                  <td className="p-4 font-medium text-sm">{w.user}</td>
                  <td className="p-4 text-sm font-semibold">${w.amount.toFixed(2)}</td>
                  <td className="p-4 text-sm text-gray-600">{w.method}</td>
                  <td className="p-4 text-sm text-gray-500 font-mono">{w.details}</td>
                  <td className="p-4 text-sm text-gray-600">{w.date}</td>
                  <td className="p-4">
                    <span className={`px-3 py-1 rounded-full text-xs font-semibold ${
                      w.status === 'pending' ? 'bg-yellow-100 text-yellow-700' :
                      w.status === 'approved' ? 'bg-blue-100 text-blue-700' :
                      w.status === 'completed' ? 'bg-green-100 text-green-700' :
                      'bg-red-100 text-red-700'
                    }`}>
                      {w.status}
                    </span>
                  </td>
                  <td className="p-4">
                    {w.status === 'pending' && (
                      <div className="flex items-center gap-2">
                        <button className="p-1.5 hover:bg-green-50 rounded-lg" title="Approve">
                          <CheckCircle className="w-5 h-5 text-green-600" />
                        </button>
                        <button className="p-1.5 hover:bg-red-50 rounded-lg" title="Reject">
                          <XCircle className="w-5 h-5 text-red-600" />
                        </button>
                      </div>
                    )}
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
