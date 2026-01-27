import React, { useState } from 'react';
import { Wallet, Recipient } from '../types';
import { AlertTriangle, Lock, PhoneCall, ShieldAlert } from 'lucide-react';

interface EmergencyProps {
  wallet: Wallet;
  recipients: Recipient[];
}

export default function Emergency({ wallet, recipients }: EmergencyProps) {
  const [active, setActive] = useState(false);
  const [countdown, setCountdown] = useState(5);
  const [mode, setMode] = useState<'IDLE' | 'ARMED' | 'RELEASED'>('IDLE');

  const handlePress = () => {
    if (mode === 'IDLE') {
        setMode('ARMED');
    } else if (mode === 'ARMED') {
        // Cancel
        setMode('IDLE');
        setCountdown(5);
    }
  };

  // Simulated Effect for release
  React.useEffect(() => {
    let timer: ReturnType<typeof setTimeout>;
    if (mode === 'ARMED' && countdown > 0) {
        timer = setTimeout(() => setCountdown(c => c - 1), 1000);
    } else if (mode === 'ARMED' && countdown === 0) {
        setMode('RELEASED');
    }
    return () => clearTimeout(timer);
  }, [mode, countdown]);

  const emergencyContact = recipients.find(r => r.type === 'Family') || recipients[0];

  return (
    <div className="max-w-2xl mx-auto text-center pt-10">
      <div className="mb-8">
        <ShieldAlert size={64} className="mx-auto text-red-600 mb-4" />
        <h1 className="text-3xl font-bold text-gray-900">Emergency Mode</h1>
        <p className="text-gray-600 mt-2">
            Instantly release funds to your primary trusted contact. <br/>
            Use only in critical situations (Medical, Security, Travel).
        </p>
      </div>

      <div className="bg-white p-8 rounded-3xl shadow-xl border border-red-100 relative overflow-hidden">
        {mode === 'RELEASED' ? (
             <div className="py-12">
                <div className="w-24 h-24 bg-green-100 rounded-full flex items-center justify-center mx-auto mb-6">
                    <PhoneCall className="text-green-600" size={40} />
                </div>
                <h2 className="text-2xl font-bold text-gray-900 mb-2">Funds Released</h2>
                <p className="text-gray-600 mb-6">
                    KES 45,000 sent to <strong>{emergencyContact?.name}</strong>.
                    <br/>Confirmation code: KES-EMG-9921
                </p>
                <button 
                    onClick={() => { setMode('IDLE'); setCountdown(5); }}
                    className="text-gray-400 hover:text-gray-600 underline"
                >
                    Reset System
                </button>
             </div>
        ) : (
            <>
                <div className="mb-8 p-4 bg-red-50 rounded-xl border border-red-100 flex items-center justify-center space-x-3 text-red-800">
                    <AlertTriangle size={20} />
                    <span className="font-medium">Primary Contact: {emergencyContact?.name} ({emergencyContact?.phone})</span>
                </div>

                <button
                    onClick={handlePress}
                    className={`
                        w-48 h-48 rounded-full border-8 shadow-2xl transition-all duration-300 flex flex-col items-center justify-center
                        ${mode === 'ARMED' 
                            ? 'bg-red-600 border-red-400 scale-110 animate-pulse' 
                            : 'bg-white border-red-100 hover:border-red-200 hover:bg-red-50'
                        }
                    `}
                >
                    {mode === 'ARMED' ? (
                        <>
                            <span className="text-4xl font-bold text-white mb-1">{countdown}</span>
                            <span className="text-white text-sm font-medium uppercase tracking-widest">Release in</span>
                            <span className="text-white/80 text-xs mt-2">Tap to Cancel</span>
                        </>
                    ) : (
                        <>
                            <div className="w-20 h-20 bg-red-100 rounded-full flex items-center justify-center mb-2">
                                <Lock className="text-red-600" size={32} />
                            </div>
                            <span className="text-red-900 font-bold text-lg">HOLD TO RELEASE</span>
                        </>
                    )}
                </button>
                
                {mode === 'IDLE' && (
                     <p className="mt-8 text-sm text-gray-400">
                        Tap to arm the emergency release system.
                    </p>
                )}
            </>
        )}
      </div>
    </div>
  );
}