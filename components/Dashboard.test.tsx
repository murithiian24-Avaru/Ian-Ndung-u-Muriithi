import React from 'react';
import { describe, it, expect, vi } from 'vitest';
import { render, screen } from '@testing-library/react';
import Dashboard from './Dashboard';
import { Wallet, FundRequest, TransactionCategory, RequestStatus } from '../types';

// Mock recharts to avoid rendering issues in jsdom
vi.mock('recharts', () => ({
  PieChart: ({ children }: { children: React.ReactNode }) => <div data-testid="pie-chart">{children}</div>,
  Pie: () => <div data-testid="pie" />,
  Cell: () => <div />,
  ResponsiveContainer: ({ children }: { children: React.ReactNode }) => <div>{children}</div>,
  Tooltip: () => <div />,
  Legend: () => <div />,
}));

const mockWallet: Wallet = {
  balance: 250000,
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
  },
};

const mockRequests: FundRequest[] = [
  {
    id: 'req1',
    requesterId: '1',
    requesterName: 'Mama Sarah',
    amount: 5000,
    category: TransactionCategory.SHOPPING,
    reason: 'Monthly groceries',
    status: RequestStatus.PENDING,
    date: '2023-10-25',
  },
  {
    id: 'req2',
    requesterId: '3',
    requesterName: 'James Kamau',
    amount: 35000,
    category: TransactionCategory.RENT,
    reason: 'October Rent',
    status: RequestStatus.PENDING,
    date: '2023-10-26',
  },
  {
    id: 'req3',
    requesterId: '1',
    requesterName: 'Mama Sarah',
    amount: 2000,
    category: TransactionCategory.HEALTHCARE,
    reason: 'Medicine',
    status: RequestStatus.APPROVED,
    date: '2023-10-20',
  },
];

describe('Dashboard', () => {
  it('renders the welcome header', () => {
    render(<Dashboard wallet={mockWallet} requests={mockRequests} />);
    expect(screen.getByText('Karibu, David.')).toBeInTheDocument();
    expect(screen.getByText('Here is your financial overview for Kenya.')).toBeInTheDocument();
  });

  it('displays the wallet balance formatted with locale', () => {
    render(<Dashboard wallet={mockWallet} requests={mockRequests} />);
    expect(screen.getByText(/KES 250,000/)).toBeInTheDocument();
  });

  it('shows the correct number of pending requests', () => {
    render(<Dashboard wallet={mockWallet} requests={mockRequests} />);
    // 2 pending requests out of 3
    expect(screen.getByText('2')).toBeInTheDocument();
    expect(screen.getByText('needs review')).toBeInTheDocument();
  });

  it('shows zero pending when no requests are pending', () => {
    const noRequests: FundRequest[] = [];
    render(<Dashboard wallet={mockWallet} requests={noRequests} />);
    expect(screen.getByText('0')).toBeInTheDocument();
  });

  it('renders the pie chart section', () => {
    render(<Dashboard wallet={mockWallet} requests={mockRequests} />);
    expect(screen.getByText('Fund Allocation')).toBeInTheDocument();
    expect(screen.getByTestId('pie-chart')).toBeInTheDocument();
  });

  it('renders recent activity section', () => {
    render(<Dashboard wallet={mockWallet} requests={mockRequests} />);
    expect(screen.getByText('Recent Activity')).toBeInTheDocument();
    expect(screen.getByText('School Fees - Term 3')).toBeInTheDocument();
    expect(screen.getByText("Mom's Allowance")).toBeInTheDocument();
    expect(screen.getByText('Added Funds via Wise')).toBeInTheDocument();
  });

  it('renders the next scheduled payout section', () => {
    render(<Dashboard wallet={mockWallet} requests={mockRequests} />);
    expect(screen.getByText(/Rent: KES 35,000/)).toBeInTheDocument();
    expect(screen.getByText('View Schedule')).toBeInTheDocument();
  });

  it('renders with zero balance wallet', () => {
    const emptyWallet: Wallet = {
      balance: 0,
      currency: 'KES',
      allocated: {
        [TransactionCategory.RENT]: 0,
        [TransactionCategory.SCHOOL_FEES]: 0,
        [TransactionCategory.SHOPPING]: 0,
        [TransactionCategory.UTILITIES]: 0,
        [TransactionCategory.HEALTHCARE]: 0,
        [TransactionCategory.ALLOWANCE]: 0,
        [TransactionCategory.EMERGENCY]: 0,
        [TransactionCategory.GENERAL]: 0,
      },
    };
    render(<Dashboard wallet={emptyWallet} requests={[]} />);
    // Multiple "KES 0" elements exist (balance + recent activity)
    const elements = screen.getAllByText(/KES\s+0/);
    expect(elements.length).toBeGreaterThanOrEqual(1);
    expect(screen.getByText('Total Wallet Balance')).toBeInTheDocument();
  });
});
