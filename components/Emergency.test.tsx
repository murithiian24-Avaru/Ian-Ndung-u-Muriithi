import React from 'react';
import { describe, it, expect, vi, beforeEach, afterEach } from 'vitest';
import { render, screen, act, fireEvent } from '@testing-library/react';
import Emergency from './Emergency';
import { Wallet, Recipient, TransactionCategory, RecipientStatus } from '../types';

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

const mockRecipients: Recipient[] = [
  {
    id: '1',
    name: 'Mama Sarah',
    relation: 'Mother',
    type: 'Family',
    phone: '+254712345678',
    status: RecipientStatus.VERIFIED,
    trustScore: 98,
  },
  {
    id: '2',
    name: 'Nairobi Water Co.',
    relation: 'Utility',
    type: 'Service Provider',
    phone: 'Paybill 555123',
    status: RecipientStatus.VERIFIED,
    trustScore: 100,
  },
];

function advanceCountdown(seconds: number) {
  for (let i = 0; i < seconds; i++) {
    act(() => { vi.advanceTimersByTime(1000); });
  }
}

describe('Emergency', () => {
  beforeEach(() => {
    vi.useFakeTimers();
  });

  afterEach(() => {
    vi.useRealTimers();
  });

  it('renders the emergency mode heading', () => {
    render(<Emergency wallet={mockWallet} recipients={mockRecipients} />);

    expect(screen.getByText('Emergency Mode')).toBeInTheDocument();
    expect(screen.getByText(/Instantly release funds to your primary trusted contact/)).toBeInTheDocument();
  });

  it('shows the primary contact info', () => {
    render(<Emergency wallet={mockWallet} recipients={mockRecipients} />);

    expect(screen.getByText(/Mama Sarah/)).toBeInTheDocument();
    expect(screen.getByText(/\+254712345678/)).toBeInTheDocument();
  });

  it('starts in IDLE mode with the hold to release button', () => {
    render(<Emergency wallet={mockWallet} recipients={mockRecipients} />);

    expect(screen.getByText('HOLD TO RELEASE')).toBeInTheDocument();
    expect(screen.getByText('Tap to arm the emergency release system.')).toBeInTheDocument();
  });

  it('transitions to ARMED mode on button click', () => {
    render(<Emergency wallet={mockWallet} recipients={mockRecipients} />);

    fireEvent.click(screen.getByText('HOLD TO RELEASE'));

    expect(screen.getByText('5')).toBeInTheDocument();
    expect(screen.getByText('Release in')).toBeInTheDocument();
    expect(screen.getByText('Tap to Cancel')).toBeInTheDocument();
  });

  it('counts down from 5 in ARMED mode', () => {
    render(<Emergency wallet={mockWallet} recipients={mockRecipients} />);

    fireEvent.click(screen.getByText('HOLD TO RELEASE'));
    expect(screen.getByText('5')).toBeInTheDocument();

    act(() => { vi.advanceTimersByTime(1000); });
    expect(screen.getByText('4')).toBeInTheDocument();

    act(() => { vi.advanceTimersByTime(1000); });
    expect(screen.getByText('3')).toBeInTheDocument();

    act(() => { vi.advanceTimersByTime(1000); });
    expect(screen.getByText('2')).toBeInTheDocument();

    act(() => { vi.advanceTimersByTime(1000); });
    expect(screen.getByText('1')).toBeInTheDocument();
  });

  it('transitions to RELEASED mode after countdown reaches 0', () => {
    render(<Emergency wallet={mockWallet} recipients={mockRecipients} />);

    fireEvent.click(screen.getByText('HOLD TO RELEASE'));

    // Advance stepwise to allow each setTimeout to fire and re-register
    advanceCountdown(6);

    expect(screen.getByText('Funds Released')).toBeInTheDocument();
    expect(screen.getByText(/KES 45,000 sent to/)).toBeInTheDocument();
    expect(screen.getByText(/Mama Sarah/)).toBeInTheDocument();
    expect(screen.getByText(/KES-EMG-9921/)).toBeInTheDocument();
  });

  it('cancels ARMED mode on second button click', () => {
    render(<Emergency wallet={mockWallet} recipients={mockRecipients} />);

    fireEvent.click(screen.getByText('HOLD TO RELEASE'));
    expect(screen.getByText('5')).toBeInTheDocument();

    act(() => { vi.advanceTimersByTime(1000); });
    expect(screen.getByText('4')).toBeInTheDocument();

    fireEvent.click(screen.getByText('Tap to Cancel'));

    expect(screen.getByText('HOLD TO RELEASE')).toBeInTheDocument();
  });

  it('can reset after funds are released', () => {
    render(<Emergency wallet={mockWallet} recipients={mockRecipients} />);

    fireEvent.click(screen.getByText('HOLD TO RELEASE'));
    advanceCountdown(6);

    expect(screen.getByText('Funds Released')).toBeInTheDocument();

    fireEvent.click(screen.getByText('Reset System'));

    expect(screen.getByText('HOLD TO RELEASE')).toBeInTheDocument();
  });

  it('uses first recipient if no family type exists', () => {
    const nonFamilyRecipients: Recipient[] = [
      {
        id: '2',
        name: 'Nairobi Water Co.',
        relation: 'Utility',
        type: 'Service Provider',
        phone: 'Paybill 555123',
        status: RecipientStatus.VERIFIED,
        trustScore: 100,
      },
    ];
    render(<Emergency wallet={mockWallet} recipients={nonFamilyRecipients} />);

    expect(screen.getByText(/Nairobi Water Co./)).toBeInTheDocument();
  });
});
