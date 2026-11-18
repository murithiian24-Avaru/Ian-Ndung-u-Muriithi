import React from 'react'
import { ShieldCheck, Megaphone } from 'lucide-react'

export default function AdsPage() {
  return (
    <div className="p-8">
      <div className="mb-8">
        <h1 className="text-3xl font-bold text-gray-900">Advertising</h1>
        <p className="text-gray-500 mt-1">Advertising controls are disabled in this demo.</p>
      </div>
      <div className="max-w-3xl rounded-2xl border border-blue-100 bg-white p-8 shadow-sm">
        <div className="mb-4 flex h-12 w-12 items-center justify-center rounded-xl bg-blue-50">
          <Megaphone className="h-6 w-6 text-blue-700" />
        </div>
        <h2 className="text-xl font-semibold text-gray-900">No active ad campaigns</h2>
        <p className="mt-2 text-sm leading-6 text-gray-600">
          Ad serving, uploads, user ad tracking and reward issuance are disabled pending Google policy and privacy review.
          Advertising revenue, if enabled later, belongs to Avaru and will not create customer wallet credit, handset credit,
          discounts, deposits or financing repayments.
        </p>
        <div className="mt-6 flex items-start gap-3 rounded-xl bg-slate-50 p-4">
          <ShieldCheck className="mt-0.5 h-5 w-5 shrink-0 text-slate-600" />
          <p className="text-sm text-slate-600">This dashboard is a prototype with no backend connection or advertiser management. Do not upload ads or treat sample figures as live reporting.</p>
        </div>
      </div>
    </div>
  )
}
