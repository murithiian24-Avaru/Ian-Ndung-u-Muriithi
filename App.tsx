import React, { useState, useEffect } from 'react';
import { HashRouter as Router, Routes, Route, Link, useLocation } from 'react-router-dom';
import { LayoutDashboard, Users, Send, MessageSquare, ShieldAlert, History, Menu, X, LogOut } from 'lucide-react';
import Dashboard from './components/Dashboard';
import Recipients from './components/Recipients';
import FundManager from './components/FundManager';
import ChatRequests from './components/ChatRequests';
import Emergency from './components/Emergency';
import { Recipient, Transaction, FundRequest, Wallet, TransactionCategory, RecipientStatus, RequestStatus } from './types';

// Mock Data Initializers
const INITIAL_WALLET: Wallet = {
  balance: 250000, // KES
  currency: 'KES',
  allocated: {
    [TransactionCategory.RENT]: 50000,
    [TransactionCategory.SCHOOL_FEES]: 80000,
    [TransactionCategory.SHOPPING]: 20000,
    [TransactionCategory.UTILITIES]: 10000,
    [TransactionCategory.HEALTHCARE]: 30000,
    [TransactionCategory.ALLOWANCE]: 15000,
    [TransactionCategory.EMERGENCY]: 45000,
    [TransactionCategory.GENERAL]: 0,
  }
};

const INITIAL_RECIPIENTS: Recipient[] = [
  { id: '1', name: 'Mama Sarah', relation: 'Mother', type: 'Family', phone: '+254712345678', status: RecipientStatus.VERIFIED, trustScore: 98 },
  { id: '2', name: 'Nairobi Water Co.', relation: 'Utility', type: 'Service Provider', phone: 'Paybill 555123', status: RecipientStatus.VERIFIED, trustScore: 100 },
  { id: '3', name: 'James Kamau (Landlord)', relation: 'Landlord', type: 'Service Provider', phone: '+254722000111', status: RecipientStatus.PENDING, trustScore: 60 },
  { id: '4', name: 'Alliance High School', relation: 'School', type: 'Institution', phone: 'Paybill 999888', status: RecipientStatus.VERIFIED, trustScore: 100 },
];

const INITIAL_REQUESTS: FundRequest[] = [
  { 
    id: 'req1', 
    requesterId: '1', 
    requesterName: 'Mama Sarah', 
    amount: 5000, 
    category: TransactionCategory.SHOPPING, 
    reason: 'Monthly groceries at Naivas', 
    status: RequestStatus.PENDING, 
    date: '2023-10-25' 
  },
  { 
    id: 'req2', 
    requesterId: '3', 
    requesterName: 'James Kamau', 
    amount: 35000, 
    category: TransactionCategory.RENT, 
    reason: 'October Rent Due', 
    status: RequestStatus.PENDING, 
    date: '2023-10-26',
    attachmentUrl: 'https://picsum.photos/400/600'
  }
];

const SidebarItem = ({ to, icon: Icon, label, active }: { to: string, icon: any, label: string, active: boolean }) => (
  <Link to={to} className={`flex items-center space-x-3 px-4 py-3 rounded-xl transition-all duration-200 ${active ? 'bg-brand-700 text-white shadow-lg' : 'text-gray-400 hover:bg-gray-800 hover:text-white'}`}>
    <Icon size={20} />
    <span className="font-medium">{label}</span>
  </Link>
);

const MobileNav = ({ isOpen, close }: { isOpen: boolean, close: () => void }) => {
  const location = useLocation();
  if (!isOpen) return null;
  return (
    <div className="fixed inset-0 z-50 bg-gray-900 bg-opacity-95 flex flex-col p-6 space-y-4 md:hidden">
      <div className="flex justify-between items-center mb-8">
        <h2 className="text-2xl font-bold text-white">The Haven</h2>
        <button onClick={close}><X className="text-white" /></button>
      </div>
      <SidebarItem to="/" icon={LayoutDashboard} label="Dashboard" active={location.pathname === '/'} />
      <SidebarItem to="/recipients" icon={Users} label="Trusted Recipients" active={location.pathname === '/recipients'} />
      <SidebarItem to="/funds" icon={Send} label="Controlled Funds" active={location.pathname === '/funds'} />
      <SidebarItem to="/requests" icon={MessageSquare} label="Chat & Requests" active={location.pathname === '/requests'} />
      <SidebarItem to="/emergency" icon={ShieldAlert} label="Emergency Mode" active={location.pathname === '/emergency'} />
    </div>
  );
};

export default function App() {
  const [wallet, setWallet] = useState<Wallet>(INITIAL_WALLET);
  const [recipients, setRecipients] = useState<Recipient[]>(INITIAL_RECIPIENTS);
  const [requests, setRequests] = useState<FundRequest[]>(INITIAL_REQUESTS);
  const [isMobileNavOpen, setMobileNavOpen] = useState(false);
  const [activeTab, setActiveTab] = useState('/');

  // Simulate routing for active tab highlighting
  const LocationTracker = () => {
    const location = useLocation();
    useEffect(() => {
      setActiveTab(location.pathname);
      setMobileNavOpen(false);
    }, [location]);
    return null;
  };

  return (
    <Router>
      <LocationTracker />
      <div className="flex h-screen bg-gray-100 overflow-hidden font-sans">
        
        {/* Sidebar (Desktop) */}
        <aside className="hidden md:flex flex-col w-64 bg-gray-900 text-white p-6 shadow-2xl">
          <div className="flex items-center space-x-3 mb-10 text-brand-500">
            <div className="w-8 h-8 rounded-full bg-brand-500 flex items-center justify-center">
              <span className="text-white font-bold text-lg">H</span>
            </div>
            <span className="text-2xl font-bold tracking-tight text-white">THE HAVEN</span>
          </div>
          
          <nav className="flex-1 space-y-2">
            <SidebarItem to="/" icon={LayoutDashboard} label="Dashboard" active={activeTab === '/'} />
            <SidebarItem to="/funds" icon={Send} label="Controlled Funds" active={activeTab === '/funds'} />
            <SidebarItem to="/recipients" icon={Users} label="Trusted Recipients" active={activeTab === '/recipients'} />
            <SidebarItem to="/requests" icon={MessageSquare} label="Chat & Requests" active={activeTab === '/requests'} />
            <div className="pt-8">
               <SidebarItem to="/emergency" icon={ShieldAlert} label="Emergency Mode" active={activeTab === '/emergency'} />
            </div>
          </nav>

          <div className="mt-auto pt-6 border-t border-gray-800">
            <button className="flex items-center space-x-3 text-gray-400 hover:text-white transition">
              <LogOut size={20} />
              <span>Sign Out</span>
            </button>
          </div>
        </aside>

        {/* Mobile Header */}
        <div className="md:hidden fixed top-0 w-full bg-gray-900 text-white z-40 p-4 flex justify-between items-center shadow-md">
           <span className="text-xl font-bold">THE HAVEN</span>
           <button onClick={() => setMobileNavOpen(true)}><Menu /></button>
        </div>
        <MobileNav isOpen={isMobileNavOpen} close={() => setMobileNavOpen(false)} />

        {/* Main Content Area */}
        <main className="flex-1 overflow-y-auto p-4 md:p-8 mt-16 md:mt-0 no-scrollbar relative">
          <Routes>
            <Route path="/" element={<Dashboard wallet={wallet} requests={requests} />} />
            <Route path="/recipients" element={<Recipients recipients={recipients} setRecipients={setRecipients} />} />
            <Route path="/funds" element={<FundManager wallet={wallet} setWallet={setWallet} recipients={recipients} />} />
            <Route path="/requests" element={<ChatRequests requests={requests} setRequests={setRequests} wallet={wallet} setWallet={setWallet} />} />
            <Route path="/emergency" element={<Emergency wallet={wallet} recipients={recipients} />} />
          </Routes>
        </main>
      </div>
    </Router>
  );
}