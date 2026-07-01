import React, { useState } from 'react'
import { Plus, Search, Building2, DollarSign, Eye } from 'lucide-react'

const sampleAdvertisers = [
  { id: 1, name: 'Safaricom', contact: 'ads@safaricom.co.ke', adsCount: 12, totalSpend: 15000, status: 'active' },
  { id: 2, name: 'Samsung East Africa', contact: 'marketing@samsung.co.ke', adsCount: 8, totalSpend: 22000, status: 'active' },
  { id: 3, name: 'Equity Bank', contact: 'digital@equity.co.ke', adsCount: 5, totalSpend: 8000, status: 'active' },
  { id: 4, name: 'Tecno Mobile', contact: 'brand@tecno.com', adsCount: 15, totalSpend: 18000, status: 'active' },
  { id: 5, name: 'KCB Bank', contact: 'ads@kcb.co.ke', adsCount: 3, totalSpend: 5000, status: 'paused' },
]

export default function AdvertisersPage() {
  const [showForm, setShowForm] = useState(false)

  return (
    <div className="p-8">
      <div className="flex items-center justify-between mb-8">
        <div>
          <h1 className="text-3xl font-bold text-gray-900">Advertisers</h1>
          <p className="text-gray-500 mt-1">Manage advertising partners</p>
        </div>
        <button
          onClick={() => setShowForm(!showForm)}
          className="flex items-center gap-2 bg-blue-600 text-white px-5 py-2.5 rounded-xl hover:bg-blue-700 transition-colors font-medium"
        >
          <Plus className="w-5 h-5" /> Add Advertiser
        </button>
      </div>

      {showForm && (
        <div className="bg-white rounded-2xl p-6 shadow-sm border border-gray-100 mb-6">
          <h3 className="text-lg font-semibold mb-4">New Advertiser</h3>
          <div className="grid grid-cols-1 md:grid-cols-2 gap-4">
            <input placeholder="Company Name" className="px-4 py-2.5 rounded-xl border border-gray-200 focus:ring-2 focus:ring-blue-500 focus:outline-none" />
            <input placeholder="Contact Email" className="px-4 py-2.5 rounded-xl border border-gray-200 focus:ring-2 focus:ring-blue-500 focus:outline-none" />
            <input placeholder="Phone" className="px-4 py-2.5 rounded-xl border border-gray-200 focus:ring-2 focus:ring-blue-500 focus:outline-none" />
            <input placeholder="Budget ($)" className="px-4 py-2.5 rounded-xl border border-gray-200 focus:ring-2 focus:ring-blue-500 focus:outline-none" />
          </div>
          <div className="flex gap-3 mt-4">
            <button className="bg-blue-600 text-white px-6 py-2 rounded-xl hover:bg-blue-700 font-medium">Save</button>
            <button onClick={() => setShowForm(false)} className="px-6 py-2 rounded-xl border border-gray-200 hover:bg-gray-50 font-medium">Cancel</button>
          </div>
        </div>
      )}

      <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-6">
        {sampleAdvertisers.map((advertiser) => (
          <div key={advertiser.id} className="bg-white rounded-2xl p-6 shadow-sm border border-gray-100 hover:shadow-md transition-shadow">
            <div className="flex items-start justify-between mb-4">
              <div className="flex items-center gap-3">
                <div className="w-12 h-12 bg-blue-100 rounded-xl flex items-center justify-center">
                  <Building2 className="w-6 h-6 text-blue-600" />
                </div>
                <div>
                  <h3 className="font-semibold">{advertiser.name}</h3>
                  <p className="text-xs text-gray-500">{advertiser.contact}</p>
                </div>
              </div>
              <span className={`px-2 py-1 rounded-full text-xs font-semibold ${
                advertiser.status === 'active' ? 'bg-green-100 text-green-700' : 'bg-yellow-100 text-yellow-700'
              }`}>
                {advertiser.status}
              </span>
            </div>
            <div className="grid grid-cols-2 gap-4 mt-4">
              <div className="bg-gray-50 rounded-xl p-3">
                <p className="text-xs text-gray-500">Active Ads</p>
                <p className="text-xl font-bold">{advertiser.adsCount}</p>
              </div>
              <div className="bg-gray-50 rounded-xl p-3">
                <p className="text-xs text-gray-500">Total Spend</p>
                <p className="text-xl font-bold">${advertiser.totalSpend.toLocaleString()}</p>
              </div>
            </div>
          </div>
        ))}
      </div>
    </div>
  )
}
