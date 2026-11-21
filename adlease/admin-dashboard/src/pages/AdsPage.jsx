import React from 'react'
import { PlayCircle } from 'lucide-react'

const sampleAds = [
  // Synthetic examples only; these are not live campaigns or advertiser data.
  { id: 1, title: 'Sample Ad 1', advertiser: 'Sample Advertiser A', duration: 60, views: 1240 },
  { id: 2, title: 'Sample Ad 2', advertiser: 'Sample Advertiser B', duration: 60, views: 890 },
  { id: 3, title: 'Sample Ad 3', advertiser: 'Sample Advertiser C', duration: 60, views: 560 },
  { id: 4, title: 'Sample Ad 4', advertiser: 'Sample Advertiser D', duration: 60, views: 2100 },
  { id: 5, title: 'Sample Ad 5', advertiser: 'Sample Advertiser E', duration: 60, views: 340 },
]

export default function AdsPage() {
  return (
    <div className="p-8">
      <div className="flex items-center justify-between mb-8">
        <div>
          <h1 className="text-3xl font-bold text-gray-900">Advertisements</h1>
          <p className="text-gray-500 mt-1">Synthetic sample records only</p>
        </div>
        <span className="text-sm text-amber-700">Ad upload disabled — no advertiser backend</span>
      </div>

      <div role="note" className="mb-6 rounded-xl border border-amber-200 bg-amber-50 p-4 text-sm text-amber-900">
        Ad rewards are disabled. No KSh-per-view amount is configured, and these sample records are not live campaigns.
      </div>

      <div className="bg-white rounded-2xl shadow-sm border border-gray-100">
        <div className="overflow-x-auto">
          <table className="w-full">
            <thead>
              <tr className="border-b border-gray-100">
                <th className="text-left p-4 text-sm font-semibold text-gray-600">Ad</th>
                <th className="text-left p-4 text-sm font-semibold text-gray-600">Advertiser</th>
                <th className="text-left p-4 text-sm font-semibold text-gray-600">Duration</th>
                <th className="text-left p-4 text-sm font-semibold text-gray-600">Sample views</th>
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
                        <p className="text-xs text-gray-500">Demo record</p>
                      </div>
                    </div>
                  </td>
                  <td className="p-4 text-sm text-gray-600">{ad.advertiser}</td>
                  <td className="p-4 text-sm text-gray-600">{ad.duration}s</td>
                  <td className="p-4 text-sm font-semibold">{ad.views.toLocaleString()}</td>
                  <td className="p-4 text-sm text-gray-500">Disabled</td>
                  <td className="p-4">
                    <span className="px-3 py-1 rounded-full text-xs font-semibold bg-gray-100 text-gray-600">
                      Sample only
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
