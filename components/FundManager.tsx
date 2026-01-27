import React, { useState } from 'react';
import { Wallet, TransactionCategory, Recipient } from '../types';
import { Send, PieChart, Coins } from 'lucide-react';

interface FundManagerProps {
  wallet: Wallet;
  setWallet: (w: Wallet) => void;
  recipients: Recipient[];
}

export default function FundManager({ wallet, setWallet, recipients }: FundManagerProps) {
  const [amount, setAmount] = useState('');
  const [category, setCategory] = useState<TransactionCategory>(TransactionCategory.RENT);
  const [selectedRecipient, setSelectedRecipient] = useState<string>('');
  const [note, setNote] = useState('');
  const [processing, setProcessing] = useState(false);
  const [success, setSuccess] = useState(false);

  const handleSend = () => {
    if (!amount || !selectedRecipient) return;
    setProcessing(true);

    setTimeout(() => {
        const amt = parseFloat(amount);
        const newWallet = { ...wallet };
        
        // Deduct from main balance (simplified logic: usually you allocate first, then send)
        // Here we just update the specific allocation bucket
        newWallet.allocated[category] += amt;
        newWallet.balance -= amt; // Assuming main balance is unallocated pool for this demo

        setWallet(newWallet);
        setProcessing(false);
        setSuccess(true);
        setTimeout(() => setSuccess(false), 3000);
        setAmount('');
        setNote('');
    }, 1500);
  };

  return (
    <div className="max-w-4xl mx-auto">
        <header className="mb-8">
            <h1 className="text-2xl font-bold text-gray-900">Controlled Funds</h1>
            <p className="text-gray-500">Direct money to specific categories. It cannot be used elsewhere.</p>
        </header>

        <div className="grid grid-cols-1 md:grid-cols-2 gap-8">
            
            {/* Allocation Form */}
            <div className="bg-white p-8 rounded-2xl shadow-lg border border-gray-100">
                <h2 className="text-xl font-bold text-gray-900 mb-6 flex items-center">
                    <Send className="mr-2 text-brand-600" size={24} />
                    Send Funds
                </h2>
                
                <div className="space-y-5">
                    <div>
                        <label className="block text-sm font-medium text-gray-700 mb-1">Category</label>
                        <select 
                            className="w-full p-3 border border-gray-200 rounded-lg outline-none focus:ring-2 focus:ring-brand-500 bg-gray-50"
                            value={category}
                            onChange={(e) => setCategory(e.target.value as TransactionCategory)}
                        >
                            {Object.values(TransactionCategory).map(c => (
                                <option key={c} value={c}>{c}</option>
                            ))}
                        </select>
                    </div>

                    <div>
                        <label className="block text-sm font-medium text-gray-700 mb-1">Recipient</label>
                        <select 
                            className="w-full p-3 border border-gray-200 rounded-lg outline-none focus:ring-2 focus:ring-brand-500 bg-gray-50"
                            value={selectedRecipient}
                            onChange={(e) => setSelectedRecipient(e.target.value)}
                        >
                            <option value="">Select a Trusted Recipient</option>
                            {recipients.map(r => (
                                <option key={r.id} value={r.id}>{r.name} ({r.relation})</option>
                            ))}
                        </select>
                    </div>

                    <div>
                        <label className="block text-sm font-medium text-gray-700 mb-1">Amount (KES)</label>
                        <input 
                            type="number" 
                            className="w-full p-3 border border-gray-200 rounded-lg outline-none focus:ring-2 focus:ring-brand-500 text-lg font-mono"
                            placeholder="0.00"
                            value={amount}
                            onChange={(e) => setAmount(e.target.value)}
                        />
                    </div>

                    <div>
                        <label className="block text-sm font-medium text-gray-700 mb-1">Note (Optional)</label>
                        <textarea 
                            className="w-full p-3 border border-gray-200 rounded-lg outline-none focus:ring-2 focus:ring-brand-500 h-24 resize-none"
                            placeholder="e.g., Paybill for October Rent"
                            value={note}
                            onChange={(e) => setNote(e.target.value)}
                        />
                    </div>

                    <button 
                        disabled={processing || !amount || !selectedRecipient}
                        onClick={handleSend}
                        className={`w-full py-4 rounded-xl font-bold text-lg text-white transition-all ${processing ? 'bg-gray-400 cursor-wait' : 'bg-brand-600 hover:bg-brand-700 shadow-lg hover:shadow-xl hover:-translate-y-1'}`}
                    >
                        {processing ? 'Processing Securely...' : success ? 'Funds Sent!' : 'Authorize Transaction'}
                    </button>
                </div>
            </div>

            {/* Current Allocations */}
            <div className="space-y-6">
                <div className="bg-gray-900 text-white p-6 rounded-2xl shadow-xl">
                    <div className="flex items-center justify-between mb-4">
                        <span className="text-gray-400 font-medium">Available to Allocate</span>
                        <Coins className="text-yellow-400" />
                    </div>
                    <div className="text-4xl font-bold font-mono">KES {wallet.balance.toLocaleString()}</div>
                    <div className="mt-4 text-sm text-gray-400 border-t border-gray-700 pt-4">
                        Funds are held in a secure trust account until released to specific categories.
                    </div>
                </div>

                <div className="bg-white p-6 rounded-2xl shadow-sm border border-gray-100">
                    <h3 className="font-bold text-gray-900 mb-4">Current Category Balances</h3>
                    <div className="space-y-4">
                        {Object.entries(wallet.allocated).map(([cat, bal]) => (
                            <div key={cat} className="flex items-center justify-between">
                                <div className="flex items-center">
                                    <div className={`w-2 h-2 rounded-full mr-3 ${bal > 0 ? 'bg-green-500' : 'bg-gray-300'}`}></div>
                                    <span className="text-gray-600">{cat}</span>
                                </div>
                                <span className="font-bold text-gray-900">KES {bal.toLocaleString()}</span>
                            </div>
                        ))}
                    </div>
                </div>
            </div>
        </div>
    </div>
  );
}