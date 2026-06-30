import React, { useState } from 'react'
import { Plus, Upload, PlayCircle, Eye, Trash2, Clock } from 'lucide-react'

const sampleAds = [
  { id: 1, title: 'Safaricom M-Pesa Go', advertiser: 'Safaricom', duration: 60, views: 1240, reward: 2.50, status: 'active', created: '2024-01-15' },
  { id: 2, title: 'Samsung Galaxy S24 Launch', advertiser: 'Samsung', duration: 60, views: 890, reward: 2.50, status: 'active', created: '2024-01-20' },
  { id: 3, title: 'Equity Bank Digital Account', advertiser: 'Equity Bank', duration: 60, views: 560, reward: 2.50, status: 'active', created: '2024-02-01' },
  { id: 4, title: 'Tecno Camon 20 Pro', advertiser: 'Tecno Mobile', duration: 60, views: 2100, reward: 2.50, status: 'paused', created: '2024-01-10' },
  { id: 5, title: 'KCB M-Shwari Savings', advertiser: 'KCB Bank', duration: 60, views: 340, reward: 2.50, status: 'active', created: '2024-02-10' },
]

export default function AdsPage() {
  const [showUpload, setShowUpload] = useState(false)

  return (
    <div className="p-8">
      <div className="flex items-center justify-between mb-8">
        <div>
          <h1 className="text-3xl font-bold text-gray-900">Advertisements</h1>
          <p className="text-gray-500 mt-1">Manage and upload advertisements</p>
        </div>
        <button
          onClick={() => setShowUpload(!showUpload)}
          className="flex items-center gap-2 bg-blue-600 text-white px-5 py-2.5 rounded-xl hover:bg-blue-700 transition-colors font-medium"
        >
          <Upload className="w-5 h-5" /> Upload Ad
        </button>
      </div>

      {showUpload && (
        <div className="bg-white rounded-2xl p-6 shadow-sm border border-gray-100 mb-6">
          <h3 className="text-lg font-semibold mb-4">Upload New Advertisement</h3>
          <div className="grid grid-cols-1 md:grid-cols-2 gap-4">
            <input placeholder="Ad Title" className="px-4 py-2.5 rounded-xl border border-gray-200 focus:ring-2 focus:ring-blue-500 focus:outline-none" />
            <select className="px-4 py-2.5 rounded-xl border border-gray-200 focus:ring-2 focus:ring-blue-500 focus:outline-none">
              <option>Select Advertiser</option>
              <option>Safaricom</option>
              <option>Samsung</option>
              <option>Equity Bank</option>
            </select>
            <input placeholder="Reward Amount ($)" className="px-4 py-2.5 rounded-xl border border-gray-200 focus:ring-2 focus:ring-blue-500 focus:outline-none" />
            <input type="number" placeholder="Duration (seconds)" defaultValue={60} className="px-4 py-2.5 rounded-xl border border-gray-200 focus:ring-2 focus:ring-blue-500 focus:outline-none" />
          </div>
          <div className="mt-4 border-2 border-dashed border-gray-200 rounded-xl p-8 text-center">
            <Upload className="w-10 h-10 text-gray-400 mx-auto mb-2" />
            <p className="text-sm text-gray-500">Drop video file here or click to upload</p>
            <p className="text-xs text-gray-400 mt-1">MP4, MOV up to 100MB</p>
          </div>
          <div className="flex gap-3 mt-4">
            <button className="bg-blue-600 text-white px-6 py-2 rounded-xl hover:bg-blue-700 font-medium">Upload</button>
            <button onClick={() => setShowUpload(false)} className="px-6 py-2 rounded-xl border border-gray-200 hover:bg-gray-50 font-medium">Cancel</button>
          </div>
        </div>
      )}

      <div className="bg-white rounded-2xl shadow-sm border border-gray-100">
        <div className="overflow-x-auto">
          <table className="w-full">
            <thead>
              <tr className="border-b border-gray-100">
                <th className="text-left p-4 text-sm font-semibold text-gray-600">Ad</th>
                <th className="text-left p-4 text-sm font-semibold text-gray-600">Advertiser</th>
                <th className="text-left p-4 text-sm font-semibold text-gray-600">Duration</th>
                <th className="text-left p-4 text-sm font-semibold text-gray-600">Views</th>
                <th className="text-left p-4 text-sm font-semibold text-gray-600">Reward</th>
                <th className="text-left p-4 text-sm font-semibold text-gray-600">Status</th>
                <th className="text-left p-4 text-sm font-semibold text-gray-600">Actions</th>
              </tr>
            </thead>
            <tbody>
              {sampleAds.map((ad) => (
                <tr key={ad.id} className="border-b border-gray-50 hover:bg-gray-50">
                  <td className="p-4">
                    <div className="flex items-center gap-3">
                      <div className="w-10 h-10 bg-blue-100 rounded-xl flex items-center justify-center">
                        <PlayCircle className="w-5 h-5 text-blue-600" />
                      </div>
                      <div>
                        <p className="font-medium text-sm">{ad.title}</p>
                        <p className="text-xs text-gray-500">{ad.created}</p>
                      </div>
                    </div>
                  </td>
                  <td className="p-4 text-sm text-gray-600">{ad.advertiser}</td>
                  <td className="p-4 text-sm text-gray-600">{ad.duration}s</td>
                  <td className="p-4 text-sm font-semibold">{ad.views.toLocaleString()}</td>
                  <td className="p-4 text-sm font-semibold text-green-600">${ad.reward.toFixed(2)}</td>
                  <td className="p-4">
                    <span className={`px-3 py-1 rounded-full text-xs font-semibold ${
                      ad.status === 'active' ? 'bg-green-100 text-green-700' : 'bg-yellow-100 text-yellow-700'
                    }`}>
                      {ad.status}
                    </span>
                  </td>
                  <td className="p-4">
                    <div className="flex items-center gap-2">
                      <button className="p-1.5 hover:bg-blue-50 rounded-lg"><Eye className="w-4 h-4 text-blue-600" /></button>
                      <button className="p-1.5 hover:bg-red-50 rounded-lg"><Trash2 className="w-4 h-4 text-red-600" /></button>
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
