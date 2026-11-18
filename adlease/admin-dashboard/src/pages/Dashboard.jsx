import React from 'react'
import { ShieldCheck, Users, Smartphone, Megaphone, CreditCard } from 'lucide-react'

const items = [
  { icon: Users, title: 'User administration', text: 'Demo only. Authentication, server-side roles and audit controls are not yet connected.' },
  { icon: Smartphone, title: 'Financing', text: 'No financing partner is connected. No applications, offers, contracts or repayments are available.' },
  { icon: Megaphone, title: 'Advertising', text: 'Ad serving and reward issuance are disabled pending policy and privacy review.' },
  { icon: CreditCard, title: 'Payments', text: 'No customer funds are collected. Payment integration is not active.' },
]

export default function Dashboard() {
  return (
    <div className="p-8">
      <div className="mb-8">
        <h1 className="text-3xl font-bold text-gray-900">AdLease Admin</h1>
        <p className="mt-1 text-gray-500">Development readiness overview — not live operational data.</p>
      </div>
      <div className="mb-6 flex items-start gap-3 rounded-2xl border border-amber-200 bg-amber-50 p-5">
        <ShieldCheck className="mt-0.5 h-6 w-6 shrink-0 text-amber-700" />
        <div>
          <h2 className="font-semibold text-amber-900">Prototype only — do not use for customer operations</h2>
          <p className="mt-1 text-sm text-amber-800">This dashboard is not authenticated and has no production backend. Do not deploy publicly or enter real customer information.</p>
        </div>
      </div>
      <div className="grid grid-cols-1 gap-5 md:grid-cols-2">
        {items.map(({ icon: Icon, title, text }) => (
          <section key={title} className="rounded-2xl border border-gray-100 bg-white p-6 shadow-sm">
            <Icon className="mb-4 h-7 w-7 text-blue-700" />
            <h3 className="font-semibold text-gray-900">{title}</h3>
            <p className="mt-2 text-sm leading-6 text-gray-600">{text}</p>
          </section>
        ))}
      </div>
    </div>
  )
}
