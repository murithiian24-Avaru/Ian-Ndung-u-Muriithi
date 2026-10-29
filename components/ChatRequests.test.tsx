import React from 'react';
import { describe, it, expect, vi, beforeEach } from 'vitest';
import { render, screen } from '@testing-library/react';
import userEvent from '@testing-library/user-event';
import ChatRequests from './ChatRequests';
import { FundRequest, RequestStatus, Wallet, TransactionCategory } from '../types';

vi.mock('../services/geminiService', () => ({
  analyzeRequest: vi.fn().mockResolvedValue({
    recommendation: 'Approve',
    category: 'Shopping',
    confidence: 85,
    summary: 'Valid grocery request.',
  }),
}));

function createMockWallet(): Wallet {
  return {
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
}

function createMockRequests(): FundRequest[] {
  return [
    {
      id: 'req1',
      requesterId: '1',
      requesterName: 'Mama Sarah',
      amount: 5000,
      category: TransactionCategory.SHOPPING,
      reason: 'Monthly groceries at Naivas',
      status: RequestStatus.PENDING,
      date: '2023-10-25',
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
      attachmentUrl: 'https://picsum.photos/400/600',
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
}

describe('ChatRequests', () => {
  it('renders the request list', () => {
    const setRequests = vi.fn();
    const setWallet = vi.fn();
    render(
      <ChatRequests
        requests={createMockRequests()}
        setRequests={setRequests}
        wallet={createMockWallet()}
        setWallet={setWallet}
      />
    );

    expect(screen.getByText('Requests')).toBeInTheDocument();
    expect(screen.getAllByText('Mama Sarah').length).toBeGreaterThanOrEqual(1);
    expect(screen.getByText('James Kamau')).toBeInTheDocument();
  });

  it('shows placeholder message when no request is selected', () => {
    const setRequests = vi.fn();
    const setWallet = vi.fn();
    render(
      <ChatRequests
        requests={createMockRequests()}
        setRequests={setRequests}
        wallet={createMockWallet()}
        setWallet={setWallet}
      />
    );

    expect(screen.getByText('Select a request to view details')).toBeInTheDocument();
  });

  it('displays request status badges', () => {
    const setRequests = vi.fn();
    const setWallet = vi.fn();
    render(
      <ChatRequests
        requests={createMockRequests()}
        setRequests={setRequests}
        wallet={createMockWallet()}
        setWallet={setWallet}
      />
    );

    const pendingBadges = screen.getAllByText('Pending');
    expect(pendingBadges.length).toBeGreaterThanOrEqual(2);
    expect(screen.getByText('Approved')).toBeInTheDocument();
  });

  it('shows request details when a request is clicked', async () => {
    const setRequests = vi.fn();
    const setWallet = vi.fn();
    const user = userEvent.setup();
    render(
      <ChatRequests
        requests={createMockRequests()}
        setRequests={setRequests}
        wallet={createMockWallet()}
        setWallet={setWallet}
      />
    );

    await user.click(screen.getByText('Monthly groceries at Naivas'));

    expect(screen.getByText(/Shopping Request/)).toBeInTheDocument();
    // KES 5,000 appears in both the list and the detail view
    const amountElements = screen.getAllByText('KES 5,000');
    expect(amountElements.length).toBeGreaterThanOrEqual(2);
    expect(screen.getByText('"Monthly groceries at Naivas"')).toBeInTheDocument();
  });

  it('shows approve and decline buttons for pending requests', async () => {
    const setRequests = vi.fn();
    const setWallet = vi.fn();
    const user = userEvent.setup();
    render(
      <ChatRequests
        requests={createMockRequests()}
        setRequests={setRequests}
        wallet={createMockWallet()}
        setWallet={setWallet}
      />
    );

    await user.click(screen.getByText('Monthly groceries at Naivas'));

    expect(screen.getByText('Approve & Pay')).toBeInTheDocument();
    expect(screen.getByText('Decline')).toBeInTheDocument();
  });

  it('calls setRequests when approving a request', async () => {
    const setRequests = vi.fn();
    const setWallet = vi.fn();
    const user = userEvent.setup();
    render(
      <ChatRequests
        requests={createMockRequests()}
        setRequests={setRequests}
        wallet={createMockWallet()}
        setWallet={setWallet}
      />
    );

    await user.click(screen.getByText('Monthly groceries at Naivas'));
    await user.click(screen.getByText('Approve & Pay'));

    expect(setRequests).toHaveBeenCalledTimes(1);
    const updatedRequests = setRequests.mock.calls[0][0];
    const approvedReq = updatedRequests.find((r: FundRequest) => r.id === 'req1');
    expect(approvedReq.status).toBe(RequestStatus.APPROVED);
  });

  it('calls setWallet to deduct funds when approving from category allocation', async () => {
    const setRequests = vi.fn();
    const setWallet = vi.fn();
    const user = userEvent.setup();
    render(
      <ChatRequests
        requests={createMockRequests()}
        setRequests={setRequests}
        wallet={createMockWallet()}
        setWallet={setWallet}
      />
    );

    await user.click(screen.getByText('Monthly groceries at Naivas'));
    await user.click(screen.getByText('Approve & Pay'));

    expect(setWallet).toHaveBeenCalledTimes(1);
    const newWallet = setWallet.mock.calls[0][0];
    // Shopping had 20000, deducting 5000 should give 15000
    expect(newWallet.allocated[TransactionCategory.SHOPPING]).toBe(15000);
  });

  it('calls setRequests when declining a request', async () => {
    const setRequests = vi.fn();
    const setWallet = vi.fn();
    const user = userEvent.setup();
    render(
      <ChatRequests
        requests={createMockRequests()}
        setRequests={setRequests}
        wallet={createMockWallet()}
        setWallet={setWallet}
      />
    );

    await user.click(screen.getByText('Monthly groceries at Naivas'));
    await user.click(screen.getByText('Decline'));

    expect(setRequests).toHaveBeenCalledTimes(1);
    const updatedRequests = setRequests.mock.calls[0][0];
    const rejectedReq = updatedRequests.find((r: FundRequest) => r.id === 'req1');
    expect(rejectedReq.status).toBe(RequestStatus.REJECTED);
  });

  it('does not deduct funds when declining a request', async () => {
    const setRequests = vi.fn();
    const setWallet = vi.fn();
    const user = userEvent.setup();
    render(
      <ChatRequests
        requests={createMockRequests()}
        setRequests={setRequests}
        wallet={createMockWallet()}
        setWallet={setWallet}
      />
    );

    await user.click(screen.getByText('Monthly groceries at Naivas'));
    await user.click(screen.getByText('Decline'));

    expect(setWallet).not.toHaveBeenCalled();
  });

  it('displays request amounts in the list', () => {
    const setRequests = vi.fn();
    const setWallet = vi.fn();
    render(
      <ChatRequests
        requests={createMockRequests()}
        setRequests={setRequests}
        wallet={createMockWallet()}
        setWallet={setWallet}
      />
    );

    expect(screen.getByText('KES 5,000')).toBeInTheDocument();
    expect(screen.getByText('KES 35,000')).toBeInTheDocument();
    expect(screen.getByText('KES 2,000')).toBeInTheDocument();
  });

  it('renders with empty request list', () => {
    const setRequests = vi.fn();
    const setWallet = vi.fn();
    render(
      <ChatRequests
        requests={[]}
        setRequests={setRequests}
        wallet={createMockWallet()}
        setWallet={setWallet}
      />
    );

    expect(screen.getByText('Requests')).toBeInTheDocument();
    expect(screen.getByText('Select a request to view details')).toBeInTheDocument();
  });
});
