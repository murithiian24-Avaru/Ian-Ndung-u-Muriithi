import React from 'react';
import { Wallet, FundRequest, RequestStatus } from '../types';
import { PieChart, Pie, Cell, ResponsiveContainer, Tooltip, Legend } from 'recharts';
import { ArrowUpRight, ArrowDownLeft, AlertCircle, CheckCircle } from 'lucide-react';

interface DashboardProps {
  wallet: Wallet;
  requests: FundRequest[];
}

const COLORS = ['#10b981', '#3b82f6', '#f59e0b', '#ef4444', '#8b5cf6', '#ec4899', '#6366f1'];

export default function Dashboard({ wallet, requests }: DashboardProps) {
  
  const pieData = Object.entries(wallet.allocated)
    .filter(([_, value]) => value > 0)
    .map(([key, value]) => ({ name: key, value }));

  const pendingRequests = requests.filter(r => r.status === RequestStatus.PENDING).length;
  
  return (
    <div className="space-y-6">
      <header className="mb-8">
        <h1 className="text-3xl font-bold text-gray-900">Karibu, David.</h1>
        <p className="text-gray-500 mt-1">Here is your financial overview for Kenya.</p>
      </header>

      {/* Stats Cards */}
      <div className="grid grid-cols-1 md:grid-cols-3 gap-6">
        <div className="bg-white p-6 rounded-2xl shadow-sm border border-gray-100 relative overflow-hidden">
          <div className="absolute top-0 right-0 p-4 opacity-10">
            <ArrowUpRight size={64} className="text-brand-600" />
          </div>
          <h3 className="text-sm font-medium text-gray-500 uppercase tracking-wider">Total Wallet Balance</h3>
          <p className="text-4xl font-bold text-gray-900 mt-2">KES {wallet.balance.toLocaleString()}</p>
          <div className="mt-4 flex items-center text-sm text-green-600">
            <CheckCircle size={16} className="mr-1" />
            <span>Secure & Ready</span>
          </div>
        </div>

        <div className="bg-white p-6 rounded-2xl shadow-sm border border-gray-100">
           <h3 className="text-sm font-medium text-gray-500 uppercase tracking-wider">Pending Requests</h3>
           <div className="flex items-end mt-2">
             <span className="text-4xl font-bold text-gray-900">{pendingRequests}</span>
             <span className="ml-2 text-gray-400 mb-1">needs review</span>
           </div>
           <div className="mt-4 flex items-center text-sm text-amber-600">
             <AlertCircle size={16} className="mr-1" />
             <span>Action required</span>
           </div>
        </div>

        <div className="bg-gradient-to-br from-brand-600 to-brand-800 p-6 rounded-2xl shadow-lg text-white">
          <h3 className="text-sm font-medium text-brand-100 uppercase tracking-wider">Next Scheduled Payout</h3>
          <p className="text-2xl font-bold mt-2">Rent: KES 35,000</p>
          <p className="text-sm text-brand-200 mt-1">Due: Nov 1st to James Kamau</p>
          <button className="mt-4 bg-white/20 hover:bg-white/30 px-4 py-2 rounded-lg text-sm font-semibold transition backdrop-blur-sm">
            View Schedule
          </button>
        </div>
      </div>

      {/* Charts & Recent Activity */}
      <div className="grid grid-cols-1 lg:grid-cols-2 gap-6">
        
        {/* Allocation Chart */}
        <div className="bg-white p-6 rounded-2xl shadow-sm border border-gray-100 h-96">
          <h3 className="text-lg font-bold text-gray-900 mb-4">Fund Allocation</h3>
          <ResponsiveContainer width="100%" height="100%">
            <PieChart>
              <Pie
                data={pieData}
                cx="50%"
                cy="50%"
                innerRadius={80}
                outerRadius={110}
                fill="#8884d8"
                paddingAngle={5}
                dataKey="value"
              >
                {pieData.map((entry, index) => (
                  <Cell key={`cell-${index}`} fill={COLORS[index % COLORS.length]} />
                ))}
              </Pie>
              <Tooltip 
                formatter={(value: number) => `KES ${value.toLocaleString()}`}
                contentStyle={{ borderRadius: '8px', border: 'none', boxShadow: '0 4px 12px rgba(0,0,0,0.1)' }}
              />
              <Legend verticalAlign="bottom" height={36}/>
            </PieChart>
          </ResponsiveContainer>
        </div>

        {/* Recent Transactions List (Simulated) */}
        <div className="bg-white p-6 rounded-2xl shadow-sm border border-gray-100 h-96 overflow-y-auto">
          <h3 className="text-lg font-bold text-gray-900 mb-4">Recent Activity</h3>
          <div className="space-y-4">
            {[
              { label: 'School Fees - Term 3', amount: -25000, date: 'Oct 24', recipient: 'Alliance High' },
              { label: 'Mom\'s Allowance', amount: -15000, date: 'Oct 22', recipient: 'Mama Sarah' },
              { label: 'Added Funds via Wise', amount: +100000, date: 'Oct 20', recipient: 'Top Up' },
              { label: 'Emergency Fund Allocation', amount: 0, date: 'Oct 18', recipient: 'Self' },
            ].map((tx, i) => (
              <div key={i} className="flex justify-between items-center p-3 hover:bg-gray-50 rounded-lg transition">
                <div className="flex items-center space-x-3">
                  <div className={`p-2 rounded-full ${tx.amount > 0 ? 'bg-green-100 text-green-600' : 'bg-red-100 text-red-600'}`}>
                    {tx.amount > 0 ? <ArrowDownLeft size={18} /> : <ArrowUpRight size={18} />}
                  </div>
                  <div>
                    <p className="font-medium text-gray-900">{tx.label}</p>
                    <p className="text-xs text-gray-500">{tx.recipient} • {tx.date}</p>
                  </div>
                </div>
                <span className={`font-semibold ${tx.amount > 0 ? 'text-green-600' : 'text-gray-900'}`}>
                  {tx.amount > 0 ? '+' : ''}KES {Math.abs(tx.amount).toLocaleString()}
                </span>
              </div>
            ))}
          </div>
        </div>
      </div>
    </div>
  );
}