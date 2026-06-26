import React, { useState } from 'react';
import { Recipient, RecipientStatus } from '../types';
import { Plus, CheckCircle, Clock, XCircle, ShieldCheck, User, AlertTriangle } from 'lucide-react';

interface RecipientsProps {
  recipients: Recipient[];
  setRecipients: (val: Recipient[]) => void;
}

export default function Recipients({ recipients, setRecipients }: RecipientsProps) {
  const [showAddModal, setShowAddModal] = useState(false);
  const [newRecipient, setNewRecipient] = useState<Partial<Recipient>>({
    name: '', relation: '', type: 'Family', phone: ''
  });
  const [addError, setAddError] = useState<string | null>(null);

  const handleAdd = () => {
    setAddError(null);

    const missingFields: string[] = [];
    if (!newRecipient.name?.trim()) missingFields.push('Name');
    if (!newRecipient.relation?.trim()) missingFields.push('Relation');
    if (!newRecipient.phone?.trim()) missingFields.push('M-Pesa Number / Paybill');

    if (missingFields.length > 0) {
      setAddError(`Please fill in: ${missingFields.join(', ')}`);
      return;
    }

    const id = (Math.random() * 1000).toString();
    setRecipients([
      ...recipients, 
      { 
        id,
        name: newRecipient.name!.trim(),
        relation: newRecipient.relation!.trim(),
        type: newRecipient.type || 'Family',
        phone: newRecipient.phone!.trim(),
        status: RecipientStatus.PENDING, 
        trustScore: 50 
      }
    ]);
    setShowAddModal(false);
    setAddError(null);
    setNewRecipient({ name: '', relation: '', type: 'Family', phone: '' });
  };

  const verifyRecipient = (id: string) => {
    // Simulate API delay
    setTimeout(() => {
        setRecipients(recipients.map(r => r.id === id ? { ...r, status: RecipientStatus.VERIFIED, trustScore: 80 } : r));
    }, 1000);
  };

  return (
    <div>
      <div className="flex justify-between items-center mb-6">
        <div>
          <h1 className="text-2xl font-bold text-gray-900">Trusted Recipients</h1>
          <p className="text-gray-500">Manage who can receive funds directly.</p>
        </div>
        <button 
          onClick={() => setShowAddModal(true)}
          className="bg-brand-600 hover:bg-brand-700 text-white px-4 py-2 rounded-lg flex items-center space-x-2 transition shadow-lg shadow-brand-200"
        >
          <Plus size={18} />
          <span>Add New</span>
        </button>
      </div>

      <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-6">
        {recipients.map((recipient) => (
          <div key={recipient.id} className="bg-white rounded-xl shadow-sm border border-gray-100 p-6 flex flex-col h-full">
            <div className="flex justify-between items-start mb-4">
              <div className="flex items-center space-x-3">
                <div className={`w-12 h-12 rounded-full flex items-center justify-center text-lg font-bold ${recipient.type === 'Family' ? 'bg-blue-100 text-blue-600' : 'bg-purple-100 text-purple-600'}`}>
                  {recipient.name.charAt(0)}
                </div>
                <div>
                  <h3 className="font-bold text-gray-900">{recipient.name}</h3>
                  <p className="text-sm text-gray-500">{recipient.relation}</p>
                </div>
              </div>
              {recipient.status === RecipientStatus.VERIFIED ? (
                <ShieldCheck className="text-brand-500" size={20} />
              ) : (
                <Clock className="text-amber-500" size={20} />
              )}
            </div>

            <div className="space-y-3 mb-6 flex-1">
              <div className="flex justify-between text-sm">
                <span className="text-gray-500">Type</span>
                <span className="font-medium text-gray-900">{recipient.type}</span>
              </div>
              <div className="flex justify-between text-sm">
                <span className="text-gray-500">M-Pesa / Paybill</span>
                <span className="font-medium text-gray-900 font-mono">{recipient.phone}</span>
              </div>
              <div className="flex justify-between text-sm items-center">
                <span className="text-gray-500">Trust Score</span>
                <div className="w-24 bg-gray-200 rounded-full h-2">
                  <div 
                    className={`h-2 rounded-full ${recipient.trustScore > 80 ? 'bg-green-500' : recipient.trustScore > 50 ? 'bg-yellow-500' : 'bg-red-500'}`} 
                    style={{ width: `${recipient.trustScore}%` }}
                  ></div>
                </div>
              </div>
            </div>

            {recipient.status === RecipientStatus.PENDING && (
              <button 
                onClick={() => verifyRecipient(recipient.id)}
                className="w-full py-2 border border-brand-500 text-brand-600 rounded-lg hover:bg-brand-50 font-medium transition"
              >
                Verify Identity
              </button>
            )}
            
            {recipient.status === RecipientStatus.VERIFIED && (
               <button className="w-full py-2 bg-gray-50 text-gray-400 rounded-lg font-medium cursor-not-allowed text-sm">
                 Verified & Secure
               </button>
            )}
          </div>
        ))}
      </div>

      {showAddModal && (
        <div className="fixed inset-0 bg-black/50 flex items-center justify-center z-50 p-4">
          <div className="bg-white rounded-2xl p-6 w-full max-w-md">
            <h2 className="text-xl font-bold mb-4">Add Trusted Recipient</h2>
            <div className="space-y-4">
              <input 
                type="text" 
                placeholder="Full Name / Company Name" 
                className="w-full p-3 border border-gray-200 rounded-lg focus:ring-2 focus:ring-brand-500 outline-none"
                value={newRecipient.name}
                onChange={e => setNewRecipient({...newRecipient, name: e.target.value})}
              />
              <div className="grid grid-cols-2 gap-4">
                  <select 
                    className="p-3 border border-gray-200 rounded-lg outline-none"
                    value={newRecipient.type}
                    onChange={e => setNewRecipient({...newRecipient, type: e.target.value as any})}
                  >
                    <option value="Family">Family</option>
                    <option value="Service Provider">Service Provider</option>
                    <option value="Institution">Institution</option>
                  </select>
                  <input 
                    type="text" 
                    placeholder="Relation (e.g., Mom)" 
                    className="p-3 border border-gray-200 rounded-lg outline-none"
                    value={newRecipient.relation}
                    onChange={e => setNewRecipient({...newRecipient, relation: e.target.value})}
                  />
              </div>
              <input 
                type="text" 
                placeholder="M-Pesa Number / Paybill" 
                className="w-full p-3 border border-gray-200 rounded-lg focus:ring-2 focus:ring-brand-500 outline-none"
                value={newRecipient.phone}
                onChange={e => setNewRecipient({...newRecipient, phone: e.target.value})}
              />
            </div>
            {addError && (
              <div className="mt-4 p-3 bg-red-50 border border-red-200 rounded-lg flex items-start space-x-2 text-red-700 text-sm">
                <AlertTriangle size={16} className="flex-shrink-0 mt-0.5" />
                <span>{addError}</span>
              </div>
            )}
            <div className="flex justify-end space-x-3 mt-6">
              <button onClick={() => { setShowAddModal(false); setAddError(null); }} className="px-4 py-2 text-gray-500 hover:bg-gray-100 rounded-lg">Cancel</button>
              <button onClick={handleAdd} className="px-4 py-2 bg-brand-600 text-white rounded-lg hover:bg-brand-700">Add & Verify</button>
            </div>
          </div>
        </div>
      )}
    </div>
  );
}