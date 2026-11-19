import React from 'react'
import { ShieldAlert, LockKeyhole } from 'lucide-react'

/// Fail-closed admin entry point. The prototype pages remain in the repository
/// but are unreachable until authentication, MFA, server-side roles and audit
/// controls have been implemented and independently reviewed.
export default function App() {
  return (
    <main className="flex min-h-screen items-center justify-center bg-slate-50 px-6 py-12">
      <section className="w-full max-w-2xl rounded-2xl border border-slate-200 bg-white p-8 shadow-sm">
        <div className="mb-5 flex h-12 w-12 items-center justify-center rounded-xl bg-amber-50">
          <ShieldAlert className="h-6 w-6 text-amber-700" />
        </div>
        <h1 className="text-2xl font-bold text-slate-900">AdLease Admin is not enabled</h1>
        <p className="mt-3 leading-7 text-slate-600">
          This dashboard is a development prototype. Administrative access is blocked until Firebase Authentication,
          multi-factor authentication, server-side role authorization, audited role management and protected backend APIs
          are implemented and reviewed.
        </p>
        <div className="mt-6 flex items-start gap-3 rounded-xl bg-slate-50 p-4">
          <LockKeyhole className="mt-0.5 h-5 w-5 shrink-0 text-slate-500" />
          <p className="text-sm text-slate-600">No user records, identity documents, financing accounts, payment records or administrative actions are accessible from this build. Do not enter customer information.</p>
        </div>
      </section>
    </main>
  )
}
