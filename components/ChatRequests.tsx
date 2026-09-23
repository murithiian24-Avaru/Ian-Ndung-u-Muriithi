import React, { useState } from 'react';
import { FundRequest, RequestStatus, Wallet, TransactionCategory } from '../types';
import { analyzeRequest } from '../services/geminiService';
import { MessageSquare, Paperclip, Check, X, Wand2, FileText, Loader2 } from 'lucide-react';
import { formatCurrency } from '../utils/formatCurrency';
import StatusBadge from './ui/StatusBadge';
import Card from './ui/Card';

interface ChatRequestsProps {
  requests: FundRequest[];
  setRequests: (r: FundRequest[]) => void;
  wallet: Wallet;
  setWallet: (w: Wallet) => void;
}

export default function ChatRequests({ requests, setRequests, wallet, setWallet }: ChatRequestsProps) {
  const [selectedRequest, setSelectedRequest] = useState<FundRequest | null>(null);
  const [aiAnalysis, setAiAnalysis] = useState<any>(null);
  const [loadingAi, setLoadingAi] = useState(false);

  const handleSelect = async (req: FundRequest) => {
    setSelectedRequest(req);
    setAiAnalysis(null);
    
    // Auto-trigger AI analysis on selection
    if (req.status === RequestStatus.PENDING) {
        setLoadingAi(true);
        const result = await analyzeRequest(req.reason, req.attachmentUrl);
        setAiAnalysis(result);
        setLoadingAi(false);
    }
  };

  const handleAction = (status: RequestStatus) => {
    if (!selectedRequest) return;
    
    // Update request status
    const updated = requests.map(r => r.id === selectedRequest.id ? { ...r, status } : r);
    setRequests(updated);
    
    // If approved, deduct funds (simplified)
    if (status === RequestStatus.APPROVED) {
        const newWallet = { ...wallet };
        // Check if category has funds, else take from balance
        if (newWallet.allocated[selectedRequest.category] >= selectedRequest.amount) {
            newWallet.allocated[selectedRequest.category] -= selectedRequest.amount;
        } else {
            newWallet.balance -= selectedRequest.amount;
        }
        setWallet(newWallet);
    }
    
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
                        <StatusBadge status={req.status} />
                        <span className="font-bold text-sm">{formatCurrency(req.amount)}</span>
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
                    <Card className="mb-6 !rounded-xl">
                        <div className="flex items-center justify-between mb-4">
                            <h3 className="text-xl font-bold text-gray-900">{selectedRequest.category} Request</h3>
                            <span className="text-2xl font-bold text-brand-600">{formatCurrency(selectedRequest.amount)}</span>
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
                            <div className="bg-brand-50 border border-brand-100 p-4 rounded-lg">
                                <div className="flex items-center space-x-2 mb-2 text-brand-800">
                                    <Wand2 size={18} />
                                    <span className="font-bold text-sm">Gemini Analysis</span>
                                </div>
                                <div className="space-y-2 text-sm text-brand-900">
                                    <p><span className="font-semibold">Category Match:</span> {aiAnalysis.category} (Confidence: {aiAnalysis.confidence}%)</p>
                                    <p><span className="font-semibold">Summary:</span> {aiAnalysis.summary}</p>
                                    <p><span className="font-semibold">Recommendation:</span> <span className="uppercase font-bold">{aiAnalysis.recommendation}</span></p>
                                </div>
                            </div>
                        ) : null}
                    </Card>
                </div>

                {/* Action Footer */}
                {selectedRequest.status === RequestStatus.PENDING && (
                    <div className="p-6 bg-white border-t border-gray-200 flex justify-end space-x-4">
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