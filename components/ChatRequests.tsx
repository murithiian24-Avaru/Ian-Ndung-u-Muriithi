import React, { useState } from 'react';
import { FundRequest, RequestStatus, Wallet, TransactionCategory } from '../types';
import { analyzeRequest, AnalysisResult } from '../services/geminiService';
import { MessageSquare, Paperclip, Check, X, Wand2, FileText, Loader2, AlertTriangle } from 'lucide-react';

interface ChatRequestsProps {
  requests: FundRequest[];
  setRequests: (r: FundRequest[]) => void;
  wallet: Wallet;
  setWallet: (w: Wallet) => void;
}

export default function ChatRequests({ requests, setRequests, wallet, setWallet }: ChatRequestsProps) {
  const [selectedRequest, setSelectedRequest] = useState<FundRequest | null>(null);
  const [aiAnalysis, setAiAnalysis] = useState<AnalysisResult | null>(null);
  const [loadingAi, setLoadingAi] = useState(false);
  const [actionError, setActionError] = useState<string | null>(null);

  const handleSelect = async (req: FundRequest) => {
    setSelectedRequest(req);
    setAiAnalysis(null);
    setActionError(null);
    
    if (req.status === RequestStatus.PENDING) {
        setLoadingAi(true);
        try {
            const result = await analyzeRequest(req.reason, req.attachmentUrl);
            setAiAnalysis(result);
        } catch (error) {
            const message = error instanceof Error ? error.message : "Unknown error";
            setAiAnalysis({
                recommendation: "Manual Review Needed",
                category: TransactionCategory.GENERAL,
                confidence: 0,
                summary: "Analysis could not be completed.",
                error: `Unexpected error: ${message}`
            });
        } finally {
            setLoadingAi(false);
        }
    }
  };

  const handleAction = (status: RequestStatus) => {
    if (!selectedRequest) return;
    setActionError(null);
    
    if (status === RequestStatus.APPROVED) {
        const categoryFunds = wallet.allocated[selectedRequest.category];
        const totalAvailable = categoryFunds + wallet.balance;
        if (selectedRequest.amount > totalAvailable) {
            setActionError(
                `Insufficient funds. Requested KES ${selectedRequest.amount.toLocaleString()} but only KES ${totalAvailable.toLocaleString()} available (KES ${categoryFunds.toLocaleString()} in ${selectedRequest.category} + KES ${wallet.balance.toLocaleString()} unallocated).`
            );
            return;
        }

        const newWallet = { ...wallet };
        if (newWallet.allocated[selectedRequest.category] >= selectedRequest.amount) {
            newWallet.allocated[selectedRequest.category] -= selectedRequest.amount;
        } else {
            const remainder = selectedRequest.amount - newWallet.allocated[selectedRequest.category];
            newWallet.allocated[selectedRequest.category] = 0;
            newWallet.balance -= remainder;
        }
        setWallet(newWallet);
    }
    
    const updated = requests.map(r => r.id === selectedRequest.id ? { ...r, status } : r);
    setRequests(updated);
    setSelectedRequest(null);
  };

  return (
    <div className="flex h-[calc(100vh-140px)] bg-white rounded-2xl shadow-sm border border-gray-100 overflow-hidden">
      
      {/* Request List */}
      <div className="w-1/3 border-r border-gray-100 flex flex-col">
        <div className="p-4 border-b border-gray-100 bg-gray-50">
            <h2 className="font-bold text-gray-800">Requests</h2>
        </div>
        <div className="overflow-y-auto flex-1">
            {requests.map(req => (
                <div 
                    key={req.id} 
                    onClick={() => handleSelect(req)}
                    className={`p-4 border-b border-gray-50 cursor-pointer hover:bg-gray-50 transition ${selectedRequest?.id === req.id ? 'bg-brand-50 border-l-4 border-l-brand-500' : ''}`}
                >
                    <div className="flex justify-between items-start mb-1">
                        <span className="font-bold text-sm text-gray-900">{req.requesterName}</span>
                        <span className="text-xs text-gray-500">{req.date}</span>
                    </div>
                    <p className="text-sm text-gray-600 line-clamp-1">{req.reason}</p>
                    <div className="mt-2 flex justify-between items-center">
                        <span className={`text-xs px-2 py-1 rounded-full ${
                            req.status === RequestStatus.PENDING ? 'bg-amber-100 text-amber-700' :
                            req.status === RequestStatus.APPROVED ? 'bg-green-100 text-green-700' :
                            'bg-gray-100 text-gray-600'
                        }`}>
                            {req.status}
                        </span>
                        <span className="font-bold text-sm">KES {req.amount.toLocaleString()}</span>
                    </div>
                </div>
            ))}
        </div>
      </div>

      {/* Chat/Details Area */}
      <div className="w-2/3 flex flex-col bg-gray-50">
        {selectedRequest ? (
            <>
                <div className="p-6 flex-1 overflow-y-auto">
                    <div className="bg-white p-6 rounded-xl shadow-sm mb-6">
                        <div className="flex items-center justify-between mb-4">
                            <h3 className="text-xl font-bold text-gray-900">{selectedRequest.category} Request</h3>
                            <span className="text-2xl font-bold text-brand-600">KES {selectedRequest.amount.toLocaleString()}</span>
                        </div>
                        <p className="text-gray-700 mb-6 text-lg">"{selectedRequest.reason}"</p>
                        
                        {selectedRequest.attachmentUrl && (
                            <div className="mb-6 p-4 border border-gray-200 rounded-lg flex items-center space-x-4 bg-gray-50">
                                <div className="bg-gray-200 p-2 rounded">
                                    <FileText className="text-gray-600" />
                                </div>
                                <div>
                                    <p className="font-medium text-sm">Attachment Included</p>
                                    <p className="text-xs text-blue-600 cursor-pointer hover:underline">View Invoice/Receipt</p>
                                </div>
                            </div>
                        )}

                        {/* AI Analysis Section */}
                        {loadingAi ? (
                            <div className="flex items-center space-x-2 text-brand-600 animate-pulse">
                                <Loader2 className="animate-spin" size={18} />
                                <span className="text-sm font-medium">AI Analyzing Request & Documents...</span>
                            </div>
                        ) : aiAnalysis ? (
                            <div className={`${aiAnalysis.error ? 'bg-red-50 border-red-200' : 'bg-brand-50 border-brand-100'} border p-4 rounded-lg`}>
                                <div className={`flex items-center space-x-2 mb-2 ${aiAnalysis.error ? 'text-red-800' : 'text-brand-800'}`}>
                                    {aiAnalysis.error ? <AlertTriangle size={18} /> : <Wand2 size={18} />}
                                    <span className="font-bold text-sm">{aiAnalysis.error ? 'Analysis Error' : 'Gemini Analysis'}</span>
                                </div>
                                {aiAnalysis.error && (
                                    <p className="text-sm text-red-700 mb-2">{aiAnalysis.error}</p>
                                )}
                                <div className={`space-y-2 text-sm ${aiAnalysis.error ? 'text-red-900' : 'text-brand-900'}`}>
                                    <p><span className="font-semibold">Category Match:</span> {aiAnalysis.category} (Confidence: {aiAnalysis.confidence}%)</p>
                                    <p><span className="font-semibold">Summary:</span> {aiAnalysis.summary}</p>
                                    <p><span className="font-semibold">Recommendation:</span> <span className="uppercase font-bold">{aiAnalysis.recommendation}</span></p>
                                </div>
                            </div>
                        ) : null}
                    </div>
                </div>

                {/* Action Footer */}
                {selectedRequest.status === RequestStatus.PENDING && (
                    <div className="p-6 bg-white border-t border-gray-200">
                    {actionError && (
                        <div className="mb-4 p-3 bg-red-50 border border-red-200 rounded-lg flex items-center space-x-2 text-red-700 text-sm">
                            <AlertTriangle size={16} className="flex-shrink-0" />
                            <span>{actionError}</span>
                        </div>
                    )}
                    <div className="flex justify-end space-x-4">
                        <button 
                            onClick={() => handleAction(RequestStatus.REJECTED)}
                            className="px-6 py-3 border border-red-200 text-red-600 rounded-xl hover:bg-red-50 font-medium flex items-center"
                        >
                            <X size={20} className="mr-2" /> Decline
                        </button>
                        <button 
                            onClick={() => handleAction(RequestStatus.APPROVED)}
                            className="px-6 py-3 bg-brand-600 text-white rounded-xl hover:bg-brand-700 font-bold shadow-lg flex items-center"
                        >
                            <Check size={20} className="mr-2" /> Approve & Pay
                        </button>
                    </div>
                    </div>
                )}
            </>
        ) : (
            <div className="flex-1 flex flex-col items-center justify-center text-gray-400">
                <MessageSquare size={48} className="mb-4 opacity-20" />
                <p>Select a request to view details</p>
            </div>
        )}
      </div>
    </div>
  );
}